##
# Anti Flyby v2.0.1
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
#   R.I.P. Mom
#
# My Website - http://mc.purehype.net:81/
# Have a bug?  http://mc.purehype.net:81/bugzilla/
##

##
# This script is used to ban people that annoyingly do flyby's aka revolving door aka
# they join then part the channel within several seconds.
##

##
# The history log has been moved to the very bottom of this script.
##

##
# Commands (DCC)
##
# chanset <#channel> mc.antiflyby <time>
#   Set time to the amount of seconds the user must stay in the specific channel
#   before part'n.  If the user leaves after join'n under the set seconds here, (s)he
#   will be in contempt of a 'flyby'.  Setting this to 0 (default) will disable the
#   script for the particular channel.
##

##
# Settings
##

# What flagged users do you want to exempt from the script?  Set to "" to exempt
# no-one.  Flag format: <global>|<channel>
set mc_afb(exempt) "b|"

# How long do you want the user to be banned?
#  -1 == don't ban
#   0 == server ban, not an actual ban entree in the bot
#  Any number above 0 is considered the number of min's the user is banned in the
#  bot's banlist.  Put an ! in front of the number for it to be a sticky ban, ie set
#  mc_afb(ban) !30
set mc_afb(ban) !240

# Set this to the ban mask type you what,
#      0 - *!user@host.domain
#      1 - *!*user@host.domain
#      2 - *!*@host.domain
#      3 - *!*user@*.domain
#      4 - *!*@*.domain
#      5 - nick!user@host.domain
#      6 - nick!*user@host.domain
#      7 - nick!*@host.domain
#      8 - nick!*user@*.domain
#      9 - nick!*@*.domain
#     You can also specify a type of 10 to 19 which correspond to masks 0 to 9.
#     But if the host.domain is a;
#       hostname = Instead of using a * wildcard to replace portions of the
#                  host.domain, it replaces the numbers in the host.domain with
#                  a '?' (question mark) wildcard.
#       ip       = It will mask as normal, with no '?' (question mark)
#                  replacements as does hostname.
set mc_afb(bant) 2

# If a user in found in violation of a flyby, what do you want to tell that user?
# The first word in this is the method in witch you want to get your message across
# either NOTICE or PRIVMSG.  Setting this to "" will disable this function.
# Replacment variables:
#   %chan == The channel the flyby happened in.
set mc_afb(msg) "PRIVMSG You have been banned from %chan for doing a flyby.  The ban will lift in 2 hours."

# What's the reason for the ban?  This info will appear when pulling a .bans listing
# in the bot, and as the kick message if the user comes back and he's still in the
# ban list.
set mc_afb(reason) "Anti Flyby"


## SVS Client (Script Version Service) v3.0 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if there
# is a newer version of this script available.  This will only notify users of the ne
# version via a note.  It's up to the owner of the bot to download, adjust settings
# then install the script.

# If a newer version is found, whom do you want to notify?  The notification is sent
# via a note.  Seperate each user with a space, or set this to "" to disable SVS
# notification.  For those whom know TCL; do not put this in list format, keep it in
# string format.
set mc_afb(svs:notify) "MC_8"

# Would you like to restrict the concept of a new version to stable releases only?
#   0 = No, inform of both stable and beta release versions.
#   1 = Yes, inform of only stable release versions.
set mc_afb(svs:mode) 0


##
# TCL Coding below, do not proceed.
##

#Script:mc_afb

set mc_afb(script)      "Anti Flyby"
set mc_afb(version)     "v2.0.1"
set mc_afb(svs:script)  "antiflyby"
set mc_afb(svs:version) "002000001000"
set mc_afb(svs:server)  "mc.purehype.net"
set mc_afb(svs:port)    "81"
set mc_afb(svs:get)     "/svs_client_interface.tcl"
set mc_afb(svs:query)   "svs=$mc_afb(svs:script)&version=$mc_afb(svs:version)"

catch {unset temp}
if {![info exists numversion] || ($numversion < "1050500")} {
	set temp(tag) "$mc_afb(script) $mc_afb(version)"
	putlog "$temp(tag) by MC_8 will only work on eggdrop 1.5.5 or greater."
	putlog "$temp(tag)  will not work with eggdrop $version."
	putlog "$temp(tag)  not loaded."
	return 1
}

setudef int mc.antiflyby

# Error system, v2.0
proc mc:afb:error {bindproc error {arg ""}} {
	global mc_afb version lastbind
	putlog "Error in script $mc_afb(script) $mc_afb(version)."
	putlog "       Last bind: $lastbind"
	putlog "       Procedure: $bindproc"
	putlog "            Args: $arg"
	putlog " Eggdrop version: $version"
	putlog "     TCL version: [info tclversion]"
	putlog "  TCL Patchlevel: [info patchlevel]"
	putlog "*** Please tell MC_8 about this BUG!  Visit        "
	putlog "*** http://mc.purehype.net:81/bugzilla/ to do so.  "
	putlog "*** Please include the next line in the bug report."
	error $error
}

proc mc:afb:errchk {command arg} {
	if {[catch {eval $command $arg} return]} {
		mc:afb:error $command $return $arg
		return 0
	}
	return $return
}
# ^

bind part - * mc:afb:part
proc mc:afb:part {nick uhost hand chan {msg ""}} {
	return [mc:afb:errchk mc:afb:part_ [list $nick $uhost $hand $chan $msg]]
}
proc mc:afb:part_ {nick uhost hand chan {msg ""}} {
	global mc_afb
	if {[isbotnick $nick]} {return 0}
	set temp(:cache:time) [mc:afb:chanint $chan mc.antiflyby]
	set temp(:cache:botisop) [botisop $chan]
	if {!$temp(:cache:time) || !$temp(:cache:botisop) ||
	    ([expr [clock seconds]-[getchanjoin $nick $chan]] > $temp(:cache:time)) ||
	    ([matchattr $hand $mc_afb(exempt) $chan] && ($mc_afb(exempt) != ""))} {
		return 0
	}
	set banmask [mc:afb:masktype $nick!$uhost $mc_afb(bant)]
	if {$mc_afb(reason) == ""} {
		set reason "Anti Flyby"
	} else {
		set reason $mc_afb(reason)
	}
	if {[string match !* $mc_afb(ban)]} {
		set option "sticky"
	} else {
		set option "none"
	}
	set actions ""
	set temp(:cache:stl_ban) [string trimleft $mc_afb(ban) !]
	if {$temp(:cache:stl_ban) > "-1"} {
		set i 0
		if {$temp(:cache:stl_ban) > "0"} {
			newchanban $chan $banmask Anti-Flyby $reason $temp(:cache:stl_ban) $option
			set i 1
		}
		if {$temp(:cache:botisop)} {
			pushmode $chan +b $banmask
			set i 1
		}
		if {$i} {
			lappend actions "banned $banmask"
		}
	}
	set temp(:cache:method) [string toupper [lindex [split $mc_afb(msg) " "] 0]]
	set temp(:cache:msg) [join [lrange [split $mc_afb(msg) " "] 1 end] " "]
	if {[regexp -- {^(NOTICE|PRIVMSG)$} $temp(:cache:method)]} {
		set temp(:cache:msg) [mc:afb:replace $temp(:cache:msg) [list %chan $chan]]
		puthelp "$temp(:cache:method) $nick :$temp(:cache:msg)"
		lappend actions "$temp(:cache:method)'d $nick"
	}
	if {$actions == ""} {
		lappend actions "nothing done"
	}
	set temp(1) "Detected flyby from $nick for $chan"
	putlog "$mc_afb(script): $temp(1); [join $actions ", "]"
}

# v1.1
proc mc:afb:replace {text subs} {
	if {![catch {string map -nocase $subs $text} output]} {return $output}
	for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
		set temp(re_syntax) {([\\\*\+\?\{\}\,\(\)\:\[\]\.\^\$\=\!\|])}
		regsub -all -- $temp(re_syntax) [lindex $subs $i] {\\\1} temp(temp)
		regsub -all -- $temp(temp) $text [lindex $subs [expr $i+1]] text
	}; return $text
}

# v1.3
proc mc:afb:masktype {nuhost type} {
	set ident_max-length 9
	set host_max-length 63
	scan $nuhost {%[^!]!%s} nick uhost
	set temp(split_uhost) [split $uhost @]
	set temp(1) [expr [llength $temp(split_uhost)]-2]
	set ident [join [lrange $temp(split_uhost) 0 $temp(1)] @]
	set host [lindex $temp(split_uhost) end]
	set maskhost 1
	if {[regexp -- {^1[0-9]$} $type]} {
		set temp(w) {([0-9][0-9]?[0-9]?)}
		set temp(x) "^$temp(w)\\.$temp(w)\\.$temp(w)\\.$temp(w)\$"
		if {!(([regexp -- $temp(x) $host temp(1) a b c d]) &&
		     ($a > 0 && $a <= 255 && $b <= 255 && $c <= 255 && $d <= 255))} {
			regsub -all -- {[0-9]} $host ? host
			set maskhost 0
		}
		set type [string index $type 1]
	}
	if {[regexp -- {^[0-4]$} $type]} {set nick "*"}
	if {[regexp -- {^[2479]$} $type]} {set ident "*"}
	if {[regexp -- {^[1368]$} $type]} {regsub -- {^~?(.*)$} $ident *\\1 ident}
	if {[regexp -- {^[3489]$} $type]} {
		if {$maskhost} {set host [lindex [split [maskhost $host] @] end]}
	}
	if {[set cache(x) [string length $ident]] > ${ident_max-length}} {
		set ident "*[string range $ident [expr $cache(x)-${ident_max-length}] end]"
	}
	if {[set cache(x) [string length $host]] > ${host_max-length}} {
		set host "*[string range $host [expr $cache(x)-${host_max-length}] end]"
	}
	return [format "%s!%s@%s" $nick $ident $host]
}


## SVS v3.0
set mc_afb(svs:client_version) "v3.0"
if {![info exists mc_afb(svs:mode)] ||
    ![regexp -- {^(1|0)$} $mc_afb(svs:mode)]} {
	set mc_afb(svs:mode) 0
}
if {![info exists mc_afb(svs:notify)]} {
	if {![info exists owner]} {set owner ""}
	set mc_afb(svs:notify) $owner
}

bind time - "00 00 *" mc:afb:do_svs
proc mc:afb:do_svs {{args ""}} {
	global mc_afb
	if {[catch {
	        socket -async $mc_afb(svs:server) $mc_afb(svs:port)
	           } sid]} {
		putloglev d * "$mc_afb(script): SVS socket error: $sid"
		return 1
	}

	# This block of code is to get a standard User-Agent line of information, as
	# proposed in http://www.mozilla.org/build/revised-user-agent-strings.html
	foreach array_name [list platform os osVersion machine] {
		set temp($array_name) [lindex [array get tcl_platform $array_name] 1]
	}
	switch -- $temp(platform) {
		windows {
			switch -- $temp(os) {
				Windows {set temp(2) Win$temp(osVersion)}
				"Windows 95" {
					if {$temp(osVersion) < "4.10"} {
						set temp(2) Win95
					} else {
						set temp(2) Win98
					}
				}
				"Windows 98" {set temp(2) Win98}
				"Windows NT" {
					if {$temp(osVersion) >= "5.0"} {
						set temp(2) "Windows NT $temp(osVersion)"
					} else {
						set temp(2) WinNT$temp(osVersion)
					}
				}
				default {
					set temp(2) "$temp(os) $temp(osVersion)"
				}
			}
		}
		unix {
			set temp(2) "unix $temp(machine)"
		}
		macintosh {
			set temp(2) $temp(machine)
		}
		default {
			set temp(2) "$temp(os) $temp(osVersion) $temp(machine)"
		}
	}
	set temp(user_agent) "Mozilla/5.001 ($temp(platform); U; $temp(2); en) "
	append temp(user_agent) "Gecko/25250101 $mc_afb(svs:script)/"
	append temp(user_agent) "$mc_afb(svs:version) SVS_Client/"
	append temp(user_agent) "$mc_afb(svs:client_version)"
	# ^

	fconfigure $sid -blocking 0 -buffering line
	set tout [after 60000 "mc:afb:svs_talk $sid timeout"]
	fileevent $sid readable "mc:afb:svs_talk $sid $tout"
	puts $sid "GET $mc_afb(svs:get)?$mc_afb(svs:query) HTTP/1.0\
	         \nHost: $mc_afb(svs:server):$mc_afb(svs:port)\
	         \nUser-Agent: $temp(user_agent)\n"
	flush $sid
}

proc mc:afb:svs_talk {sid tout} {
	global mc_afb
	set array [list svs temp $sid]
	if {$tout == "timeout"} {
		set temp(1) "$mc_afb(svs:server):$mc_afb(svs:port)"
		putloglev d * \
			"$mc_afb(script): SVS Warning: Timed out connecting to $temp(1)."
		catch {unset mc_afb($array)}
		close $sid
		return 0
	}
	if {[eof $sid]} {
		catch {unset mc_afb($array)}
		close $sid
		return 1
	}
	gets $sid get
	after cancel $tout
	if {![info exist mc_afb($array)]} {
		if {$get == ""} {set mc_afb($array) 1}
		return -1
	}
	if {($get == "") || [catch {llength $get}]} {
		return -2
	}
	switch -- [lindex $get 0] {
		003 {
			set temp(reply) [lrange $get 1 end]
			set temp(reply:0) [lindex $temp(reply) 0]
			set temp(reply:1) [lindex $temp(reply) 1]
			set temp(reply:2) [lindex $temp(reply) 2]
			set temp(reply:3) [lindex $temp(reply) 3]
			set temp(reply:4) [lindex $temp(reply) 4]
			set temp(reply:5) [lindex $temp(reply) 5]
			if {$temp(reply:0) != $mc_afb(svs:script)} {
				set temp(1) "wanted $mc_afb(svs:script), got $temp(reply:0)"
				putloglev d * "$mc_afb(script): SVS Error: $temp(1)"
				unset mc_afb($array)
				close $sid
				return -3
			}
			if {$mc_afb(svs:mode)} {
				set temp(svs:version) [string range $mc_afb(svs:version) 0 8]999
			} else {
				set temp(svs:version) [string range $mc_afb(svs:version) 0 11]
			}
			if {$temp(reply:1) > $temp(svs:version)} {
				set temp(note) $temp(reply:5)
				regsub -all -- %0 $temp(note) $temp(reply:0) temp(note)
				regsub -all -- %1 $temp(note) $temp(reply:1) temp(note)
				regsub -all -- %2 $temp(note) $temp(reply:2) temp(note)
				regsub -all -- %3 $temp(note) $temp(reply:3) temp(note)
				regsub -all -- %4 $temp(note) $temp(reply:4) temp(note)
				regsub -all -- %version $temp(note) $mc_afb(version) temp(note)
				foreach temp(to) [split $mc_afb(svs:notify) ",; "] {
					if {[string trim $temp(to)] == ""} {continue}
					regsub -- %nick $temp(note) $temp(to) temp(note2)
					set temp(lunotes) [notes $temp(to) -[notes $temp(to)]]]
					if {[string match *$temp(note2)* $temp(lunotes)]} {
						set temp(found_note) 0
						foreach temp(unote) $temp(lunotes) {
							if {$temp(note2) == [lindex $temp(unote) 2]} {
								set temp(found_note) 1
								break
							}
						}
						if {$temp(found_note)} {continue}
					}
					set temp(error) "sending note to $temp(to) -> "
					switch -- [sendnote SVS $temp(to) $temp(note2)] {
						0 {
							if {![validuser $temp(to)]} {
								append temp(error) "invalid user"
							} else {append temp(error) "unknown error"}
							putloglev d * \
								"$mc_afb(script): SVS sendnote error: $temp(error)"
						}
						3 {
							append temp(error) "notebox too full"
							putloglev d * \
								"$mc_afb(script): SVS sendnote error: $temp(error)"
						}
					}
				}
			}
			unset mc_afb($array)
			close $sid
			return 2
		}
	}
}
## ^

putlog "$mc_afb(script) $mc_afb(version) by MC_8 loaded."

##
# History  ( <Fixed by> - [Found by] - <Info> )
##
# v2.0.1 (09.11.02)
#  MC_8 -        - Moved history to the bottom.
#  MC_8 -        - Upgraded SVS client.  v2.0 -> v3.0
#  MC_8 -        - Upgraded error catching system.  v1.0 -> v2.0
#  MC_8 -        - Upgraded masktype proc.  v1.0 -> v1.3
#  MC_8 - Pieter - Fixed 'Tcl error [mc:afb:part]: no such channel record' when bot
#                  parted from the channel due to a -chan situation.
#                  Bugzilla number:  111
#
# v2.0 (02.12.02)
#  MC_8 - - Bassed the script off eggdrop's internal 'getchanjoin' procedure, in turn
#           removed all binds except for part.
#  MC_8 - - Upgraded replace proc.  v1.0 -> v1.1.
#  MC_8 - - Recoded the script to be more efficient and cache pro calls.
#  MC_8 - - Added error catching system.
#  MC_8 - - Rewrote findchanuser proc and changed it's name to getnick.
#  MC_8 - - Added a central list proc.
#  MC_8 - - Reworte join, part, nick, and punish procs.
#  MC_8 - - Rewrote filt proc (text filtering procedure).
#  MC_8 - - Reworte chanintinfo proc and changed it's name to chanint.
#  MC_8 - - Removed now unused findip, replace, slength, sindex, srange chanflagison,
#           and unfilt procs.
#  MC_8 - - Rewrote the masktype proc (ban masking procedure).
#  MC_8 - - Changed channel int set from antiflyby to mc.antiflyby.
#  MC_8 - - Upgraded SVS client.  v1.2 -> v2.0.
#
# v1.1.2 (07.02.01)
#  MC_8 - TU - Fixed 'Tcl error [mc:afb:join]: invalid command name
#              "mc:limit:srange"'.
#
# v1.1.1 (06.10.01)
#  MC_8 - HTH       - Problem with bantype's greater than 9.
#  MC_8 - anonymous - Rewrote the nick filtering system, was still getting problems
#                     with special charactered nicks.
#  MC_8 -           - Rewrote the masktype procedure a little bit, expected bugs.
#
# v1.1 (03.06.01)
#  MC_8 - Strydor   - Fixed special character problems with nicks (similar to
#                     Grafx-man's findings).
#  MC_8 -           - Upgraded SVS client.  v1.0 -> v1.2
#  MC_8 - Grafx-man - Every nick with a special character in there nick, such as
#                     "Bob}{Fox" was being treated as if they were doing a flyby,
#                     even if they parted after being on the channel for days on end.
#
# v1.0 (01.14.01)
#  MC_8 - M` - Inital Release.
##

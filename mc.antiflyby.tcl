##
# Anti Flyby v2.1
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
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
# chanset <channel> mc.antiflyby.must_stay <time>
#   Set time to the amount of seconds the user must stay in the specific channel
#   before part'n.  If the user leaves after join'n under the set seconds here, (s)he
#   will be in contempt of a 'flyby'.  Setting this to 0 (default) will disable the
#   script for the particular channel.
#
# chanset <channel> mc.antiflyby.max_hop_time <time>
#   This goes in conjunction with `max_hop_limit`.  How many hops in how many seconds
#   should be considered punishable?  Set how many seconds here.
#
# chanset <channel> mc.antiflyby.max_hop_limit <number>
#   How many hops in how many seconds should be considered punishable?  Set how many
#   hop's here.  Setting this to 0, default, means no hop limit (ie, you within
#   `must_stay` just once then this script will punish them).
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
# either NOTICE or PRIVMSG.  One message per line.  If you specify more than 1 line,
# the messages will be randomly chosen.  If you specify no messages in here, it
# effectively disables this feature -- ie, set mc_afb(msg) {}
# Replacment variables:
#   %chan == The channel the flyby happened in.
set mc_afb(msg) {
	PRIVMSG You have been banned from %chan for doing a flyby.  The ban will lift in 2 hours.
	PRIVMSG You are now banned on %chan for doing a flyby!  The ban will lift in 2 hours.
	PRIVMSG Flyby's suck, your now banned on %chan for 2 hours.
}

# What's the reason for the ban?  This info will appear when pulling a .bans listing
# in the bot, and as the kick message if the user comes back and he's still in the
# ban list.
set mc_afb(reason) "Anti Flyby"


## SVS Client (Script Version Service) v3.1 ##
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
set mc_afb(version)     "v2.1"
set mc_afb(svs:script)  "antiflyby"
set mc_afb(svs:version) "002001000000"
set mc_afb(svs:server)  "mc.svs.purehype.net"
set mc_afb(svs:port)    "81"
set mc_afb(svs:get)     "/index.tcl"
set mc_afb(svs:query)   "svs=$mc_afb(svs:script)&version=$mc_afb(svs:version)"

catch {unset temp}
if {![info exists numversion] || ($numversion < "1050500")} {
	set temp(tag) "$mc_afb(script) $mc_afb(version)"
	putlog "$temp(tag) by MC_8 will only work on eggdrop 1.5.5 or greater."
	putlog "$temp(tag)  will not work with eggdrop $version."
	putlog "$temp(tag)  not loaded."
	return 1
}

setudef int mc.antiflyby.must_stay
setudef int mc.antiflyby.max_hop_limit
setudef int mc.antiflyby.max_hop_time

# Error system, v3.0
proc mc:afb:error {command error arg} {
	global mc_afb version lastbind errorInfo
	putlog "Error in script $mc_afb(script) $mc_afb(version)."
	putlog "    Error System: v3.0"
	putlog "       Last Bind: [expr {[info exists lastbind] ? $lastbind : "-NULL-"}]"
	putlog "         Command: $command"
	putlog "       Arguments: $arg"
	putlog "       Error Msg: $error"
	putlog "    Egg. Version: [expr {[info exists version] ? $version : "-NULL-"}]"
	putlog "     TCL Version: [info tclversion]"
	putlog "  TCL Patchlevel: [info patchlevel]"
	putlog "*** Please submit this bug so MC_8 can fix it.  Visit"
	putlog "*** http://mc.purehype.net:81/bugzilla/ to properly report the bug."
	putlog "*** Please include ALL info. in the bug report, including the next(s)."
	error $errorInfo
}

proc mc:afb:errchk {command arg} {
	if {![catch {eval $command $arg} return]} {return $return}
	mc:afb:error $command $return $arg
	return 0
}
# ^

bind join - * mc:afb:join
proc mc:afb:join {nick uhost handle channel} {
	return [mc:afb:errchk mc:afb:join_ [list $nick $uhost $handle $channel]]
}
proc mc:afb:join_ {nick uhost handle channel} {
	if {[isbotnick $nick]} {mc:afb:hop_limit $nick $channel clr}
}

bind part - * mc:afb:part
proc mc:afb:part {nick uhost hand chan {msg ""}} {
	return [mc:afb:errchk mc:afb:part_ [list $nick $uhost $hand $chan $msg]]
}
proc mc:afb:part_ {nick uhost hand chan {msg ""}} {
	global mc_afb
	if {[isbotnick $nick]} {return 0}
	set temp(:cache:time) [mc:afb:chanint $chan mc.antiflyby.must_stay]
	set temp(:cache:botisop) [botisop $chan]
	if {(!$temp(:cache:time)) || (!$temp(:cache:botisop)) ||
	    ([expr [clock seconds]-[getchanjoin $nick $chan]] > $temp(:cache:time)) ||
	    ([matchattr $hand $mc_afb(exempt) $chan] && ($mc_afb(exempt) != "")) ||
	    (![mc:afb:hop_limit $nick $chan eval])} {
		return 0
	}
	if {![mc:afb:hop_limit $nick $chan eval]} {return 0}
	set banmask [mc:afb:maskhostbytype $nick!$uhost $mc_afb(bant)]
	if {$mc_afb(reason) == ""} {set reason "Anti Flyby"} \
	else {set reason $mc_afb(reason)}
	if {[string match !* $mc_afb(ban)]} {set option "sticky"} \
	else {set option "none"}
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
	set temp(:cache:msg) ""
	foreach temp(i) [split $mc_afb(msg) \n] {
		set temp(i) [string trim $temp(i) " \t"]
		if {$temp(i) != ""} {
			lappend temp(:cache:msg) $temp(i)
		}
	}
	set temp(:cache:llength) [llength $temp(:cache:msg)]
	if {$temp(:cache:llength)} {
		set temp(:cache:msg) [lindex $temp(:cache:msg) [rand $temp(:cache:llength)]]
		set temp(:cache:smsg) [split $temp(:cache:msg) " "]
		set temp(:cache:method) [string toupper [lindex $temp(:cache:smsg) 0]]
		set temp(:cache:msg) [join [lrange $temp(:cache:smsg) 1 end]]
		if {[regexp -- {^(NOTICE|PRIVMSG)$} $temp(:cache:method)]} {
			set temp(:cache:msg) [mc:afb:replace $temp(:cache:msg) [list %chan $chan]]
			puthelp "$temp(:cache:method) $nick :$temp(:cache:msg)"
			lappend actions "$temp(:cache:method)'d $nick"
		}
	}
	if {$actions == ""} {
		lappend actions "nothing done"
	}
	set temp(1) "Detected flyby from $nick for $chan"
	putlog "$mc_afb(script): $temp(1); [join $actions ", "]"
}

proc mc:afb:hop_limit {nick channel command} {
	global mc_afb
	if {$command != "clr"} {
		if {![validchan $channel] ||
		    ![mc:afb:chanint $channel mc.antiflyby.must_stay]} {return 0}
		if {![mc:afb:chanint $channel mc.antiflyby.max_hop_limit]} {return 1}
	}

	set nick [string tolower $nick]
	set channel [string tolower $channel]
	set array_name "hop [list $nick $channel]"
	switch -- $command {
		eval {
			mc:afb:hop_limit $nick $channel inc
			set temp() [mc:afb:chanint $channel mc.antiflyby.max_hop_limit]
			if {$mc_afb($array_name) >= $temp()} {return 1} else {return 0}
		}
		inc {
			if {![info exists mc_afb($array_name)]} {set mc_afb($array_name) 1} \
			else {incr mc_afb($array_name)}
			set temp() [mc:afb:chanint $channel mc.antiflyby.max_hop_time]
			utimer $temp() [list mc:afb:hop_limit $nick $channel dec]
		}
		dec {
			if {[info exists mc_afb($array_name)]} {incr mc_afb($array_name) -1}
			if {$mc_afb($array_name) <= "0"} {unset mc_afb($array_name)}
		}
		clr {
			foreach array [array names "hop *"] {
				if {[lindex $array 1] == $channel} {unset mc_afb($array)}
			}
		}
		default {error "Invalid command, '$command'."}
	}
}


## More Tools quick procs.
## -- http://mc.purehype.net:81/script_info.tcl?script=moretools

# mc:afb:badargs <args> <min_llength> <max_llength|end> <argNames>
#     version:
#       v1.0
proc mc:afb:badargs {{args ""}} {
	if {[llength $args] < 4} {
		error {
			wrong # args: should be "mc:afb:badargs args min_llength max_llength argNames"
		}
	}

	set index 0
	foreach varName [list args min max names] {
		set check_$varName [lindex $args $index]
		incr index
	}

	if {[regexp -- {([^0-9])} $check_min -> bad]} {
		error "bad number \"$bad\" in: $check_min"
	}
	if {[regexp -- {([^0-9])} $check_max -> bad] && ($check_max != "end")} {
		error "bad number \"$bad\" in: $check_max"
	}

	# Make sure $check_args is in list format, if not then make it so.
	# Were not going to use mc:afb:2list here, don't want to evoke a 'too many nested
	# calls to Tcl_EvalObj' error since 'mc:afb:2list' uses on this proc.
	if {[catch {llength $check_args} llength]} {
		set check_args [split $check_args]
		set llength $check_args
	}

	if {($llength < $check_min) || (($llength != "end") && ($llength > $check_max))} {
		if {[info level] == "1"} {return 1}
		error "wrong # args: should be \"[lindex [info level -1] 0] $check_names\""
	}; return 0
}

# mc:afb:2list <text>
#     version:
#       v1.0
proc mc:afb:2list {{args ""}} {
	mc:afb:badargs $args 1 1 "text"
	mc:afb:unlist $args text

	return [expr {([catch {llength $text}])?[split $text]:$text}]
}

# mc:afb:unlist <argsList> [varName1] [varName2] ... [varNameN]
#     version:
#       v1.0
proc mc:afb:unlist {{args ""}} {
	mc:afb:badargs $args 1 end "argsList ?varName varName ...?"
	set argList [lindex $args 0]
	set argList [expr {([catch {llength $argList}])?[split $argList]:$argList}]
	set argNames [lrange $args 1 end]
	if {![llength $argNames]} {
		return [expr {(![catch {llength $argList}])?
			[join $argList]:$argList}]
	}
	for {set index 0} {$index < [llength $argNames]} {incr index 1} {
		set argName     [lindex $argNames $index]
		set argListItem [lindex $argList  $index]

		set argName_ [expr {([catch {llength $argName}])?[split $argName]:$argName}]
		set setTo   [lindex $argName_ 1]
		set argName [lindex $argName_ 0]

		if {$argName == ""} {continue}

		upvar 1 $argName var

		if {[expr $index+1] > [llength $argList]} {
			if {[llength $argName_] == "2"} {set var $setTo}
		} else {
			if {$argName == "args"} {
				set var [lrange $argList $index end]
				incr index [expr [llength $var]-1]
			} else {set var $argListItem}
		}
	}; return $index
}

# chanint <channel> <flag>
#     version:
#       v3.2
proc mc:afb:chanint {{args ""}} {
	mc:afb:badargs $args 2 2 "channel integer_flag"
	mc:afb:unlist $args channel flag

	set flag [string tolower $flag]

	if {![validchan $channel]} {error "no such channel record"}

	# Try the 'channel' commands' 'get' option first, it's faster since it is written
	# in C by the eggdrop development team.
	if {![catch {channel get $channel $flag} output]} {return $output}

	foreach chaninfo [string tolower [channel info $channel]] {
		# Using mc:afb:2list here because it's only in string format.  I told the eggdrop
		# development team of this error, but have yet to see them fix it.
		set chaninfo [mc:afb:2list $chaninfo]

		set name [join [expr {([info tclversion] >= "8.1")?
			[lrange $chaninfo 0 end-1]:
			[lrange $chaninfo 0 [expr [llength $chaninfo]-2]]}]]

		if {$name == $flag} {return [lindex $chaninfo end]}
	}; return -1
}

# mc:afb:replace [switches] <text> <substitutions>
#     version:
#       v1.3
proc mc:afb:replace {{args ""}} {
	mc:afb:badargs $args 2 4 "?switches? text substitutions"
	set switches ""
	for {set i 0} {[string match -* [set arg [lindex $args $i]]]} {incr i} {
		if {![regexp -- {^-(nocase|-)$} $arg -> switch]} {
			error "bad switch \"$arg\": must be -nocase, or --"
		}
		if {$switch == "-"} {
			incr i
			break
		}; lappend switches $switch
	}
	set nocase [expr {([lsearch -exact $switches "nocase"] >= "0") ? 1 : 0}]
	set text [lindex $args $i]
	set substitutions [lindex $args [expr $i+1]]
	mc:afb:badargs [lrange $args $i end] 2 2 "?switches? text substitutions"

	# Check to see if $substitutions is in list format, if not make it so.
	set substitutions [mc:afb:2list $substitutions]

	if {[info tclversion] >= "8.1"} {
		return [expr {($nocase)?
			[string map -nocase $substitutions $text]:
			[string map $substitutions $text]}]
	}

	set re_syntax {([][\\\*\+\?\{\}\,\(\)\:\.\^\$\=\!\|])}
	foreach {a b} $substitutions {
		regsub -all -- $re_syntax $a {\\\1} a
		if {$nocase} {regsub -all -nocase -- $a $text $b text} \
		else {regsub -all -- $a $text $b text}
	}; return $text
}

# maskhostbytype <nick!ident@host.domain> [type]
#     version:
#       v2.0
proc mc:afb:maskhostbytype {{args ""}} {
	mc:afb:badargs $args 1 2 "nick!ident@host.domain ?type?"
	mc:afb:unlist $args nuhost type


	set type [expr {($type == "")?5:$type}]
	if {![regexp -- {^1?[0-9]$} $type]} {
		set valid "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {or 19}"
		error "bad type \"$type\": must be [join $valid ", "]"
	}

	# Define the maximum length the ircd allows for an ident.  Standard is 9, however I
	# made it to a variable incase someone wants to change it up.
	set ident_max-length 9

	# Define the maximum length the ircd allows for a hostname/ ip.  Standard is 63,
	# however I made it to a variable incase someone wants to change it up.
	set host_max-length 63

	if {![regexp -- {^(.*?)!((.*)@(.*))$} $nuhost -> nick uhost ident host]} {
		error "invalid nick!ident@host.domain: $nuhost"
	}

	set maskhost 1
	if {[string length $type] == "2"} {
		# Type must be 10-19.
		if {[info tclversion] < "8.1"} {
			set re_syntax_1 {([12][0-9][0-9]|[1-9][0-9]|[1-9])}
			set re_syntax_2 {([12][0-9][0-9]|[1-9][0-9]|[0-9])}
		} else {
			set re_syntax_1 {([12]\d{2}|[1-9][0-9]|[1-9])}
			set re_syntax_2 {([12]\d{2}|[1-9][0-9]|[0-9])}
		}
		set re_syntax ^$re_syntax_1\\.$re_syntax_2\\.$re_syntax_2\\.$re_syntax_2\$

		if {![regexp -- $re_syntax $host]} {
			regsub -all -- {[0-9]} $host ? host
			set maskhost 0
		}; set type [string index $type 1]
	}

	# Previous version used regexp instead of these string matches.  String match in
	# this case is ~3 microseconds faster.
	if {[string match {[0-4]} $type]} {set nick *}
	if {[string match {[2479]} $type]} {set ident *}
	if {[string match {[1368]} $type]} {regsub -- {^~?(.*)$} $ident *\\1 ident}
	if {[string match {[3489]} $type] && $maskhost} {
		set host [lindex [split [maskhost $host] @] end]
	}

	if {[set length [string length $ident]] > ${ident_max-length}} {
		set ident *[string range $ident [expr $length-${ident_max-length}] end]
	}
	if {[set length [string length $host]] > ${host_max-length}} {
		set host *[string range $host [expr $length-${host_max-length}] end]
	}

	return $nick!$ident@$host
}

## End of More Tools quick procs.


## SVS v3.1
set mc_afb(svs:client_version) "v3.1"
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
	mc:afb:do_svs_ $mc_afb(svs:server) $mc_afb(svs:port) $mc_afb(get)
}

proc mc:afb:do_svs_ {svs_server svs_port svs_get} {
	global mc_afb tcl_platform
	if {[catch {
	        socket -async $svs_server $svs_port
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
	set tout [after 60000 "mc:afb:svs_talk $sid timeout $svs_server $svs_port"]
	fileevent $sid readable "mc:afb:svs_talk $sid $tout"
	puts $sid "GET $svs_get?$mc_afb(svs:query) HTTP/1.0\
	         \nHost: $svs_server:$svs_port\
	         \nUser-Agent: $temp(user_agent)\n"
	flush $sid
}

proc mc:afb:svs_talk {sid tout {svs_server ""} {svs_port ""}} {
	global mc_afb
	set array [list svs temp $sid]
	if {$tout == "timeout"} {
		set temp(1) "$svs_server:$svs_port"
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
		200 {
			set temp(host) [lindex $get 1]
			set temp(port) [lindex $get 2]
			set temp(get) [lindex $get 3]
			set temp(cache) "$temp(host) at $temp(port)"
			putloglev d * "$mc_afb(script): SVS is being redirected to $temp(cache)."
			mc:afb:do_svs_ $temp(host) $temp(port) $temp(get)
			close $sid
			return 200
		}
		003 {
			set temp(reply) [lrange $get 1 end]
			for {set number 0} {$number <= 5} {incr number} {
				set temp(reply:$number) [lindex $temp(reply) $number]
			}
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
# v2.1 (10.09.02)
#  MC_8 -         - Upgraded SVS Client.  v3.0 -> v3.1
#  MC_8 -         - Added `max_hop_time` dcc setting.
#  MC_8 - heber   - Added `max_hop_limit` dcc setting.  (bugzilla # 160)
#  MC_8 -         - Renamed 'mc.antiflyby' dcc setting to 'mc.antiflyby.must_stay'.
#  MC_8 -         - Fixed another 'invalid command name "2list"'.
#  MC_8 - heber   - Fixed 'random limit must be greater than zero'.  (bugzilla # 151)
#  MC_8 - blood_x - Fixed 'invalid command name "mc:afb:maskhostbytype"'.
#                   (bugzilla # 140)
#  MC_8 -         - Upgraded Error Catching System.  v2.0 -> v3.0
#  MC_8 - heber   - Fixed 'invalid command name "badargs"'.  (bugzilla # 126)
#  MC_8 - skuum   - Added ability to specify random responses via the 'mc_afb(msg)'
#                   setting.  (bugzilla # 111)
#  MC_8 -         - Upgraded `masktype` tcl command, name changed to
#                   `maskhostbytype`.  v1.3 -> v2.0
#  MC_8 -         - Upgraded the `replace` tcl command.  v1.1 -> v1.3
#  MC_8 -         - Added `unlist` tcl command.  none -> v1.0
#  MC_8 -         - Added `2list` tcl command.  none -> v1.0
#  MC_8 -         - Added `badargs` tcl command.  none -> v1.0
#  MC_8 - blood_x - Fixed 'invalid command name "mc:afb:chanint"'.  (bugzilla # 121)
#
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

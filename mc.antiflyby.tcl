##
# Anti Flyby v2.0
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
# My SVS Website - http://mc.purehype.net:81/
# Have a bug?  http://mc.purehype.net:81/bugzilla/
# TCL Mailing list - http://mc.purehype.net:81/maillist/
##

##
# This script is used to ban people that anoyingly do flyby's aka
# revolving door aka they join then part the channel within several
# seconds.
##

##
# History  ( <Fixed by> - [Found by] - <Info> )
##
# v2.0 (02.12.02)
#  MC_8 - - Bassed the script off eggdrop's internal 'getchanjoin' 
#           procedure, in turn removed all binds except for part.
#  MC_8 - - Upgraded replace proc from v1.0 to v1.1.
#  MC_8 - - Recoded the script to be more effecent and cache pro calls.
#  MC_8 - - Added error catching system.
#  MC_8 - - Rewrote findchanuser proc and changed it's name to getnick.
#  MC_8 - - Added a central list proc.
#  MC_8 - - Reworte join, part, nick, and punish procs.
#  MC_8 - - Rewrote filt proc (text filtering procedure).
#  MC_8 - - Reworte chanintinfo proc and changed it's name to chanint.
#  MC_8 - - Removed now unused findip, replace, slength, sindex, srange
#           chanflagison, and unfilt procs.
#  MC_8 - - Rewrote the masktype proc (ban masking procedure).
#  MC_8 - - Changed channel int set from antiflyby to mc.antiflyby.
#  MC_8 - - Upgraded SVS from v1.2 to v2.0.
#
# v1.1.2 (07.02.01)
#  MC_8 - TU - Tcl error [mc:afb:join]: invalid command name 
#              "mc:limit:srange"
#
# v1.1.1 (06.10.01)
#  MC_8 - HTH       - Problem with bantype's greater than 9.
#  MC_8 - anonymous - Rewrote the nick filtering system, was still 
#                     getting problems with special charactered nicks.
#  MC_8 -           - Rewrote the masktype procedure a little bit, 
#                     expected bugs.
#
# v1.1 (03.06.01)
#  MC_8 - Strydor   - Fixed special character problems with nicks 
#                     (simular to Grafx-man's findings.
#  MC_8 -           - Upgraded SVS from v1.0 to v1.2
#  MC_8 - Grafx-man - Every nick with a special character in there 
#                     nick, such as "Bob}{Fox" was being treated as if 
#                     they were doing a flyby, even if they parted 
#                     after being on the channel for days on end.
#
# v1.0 (01.14.01)
#  MC_8 - M` - Inital Release.
##

##
# Commands
##
# DCC:
#  chanset <#channel> mc.antiflyby <time>
#    Set time to the amount of seconds the user must must stay in the 
#    specific channel before part'n.  If the user leaves after join'n 
#    under the set seconds here, (s)he will be in contempt of a 
#    'flyby'.  Setting this to 0 (default) will disable the script for 
#    the particular channel.
##

##
# Settings
##

# What flagged users do you want to exempt from the script?
# Set to "" to exempt no-one.
# Flag format: <global>|<channel>
set mc_afb(exempt) "b|"

# How long do you want the user to be banned?
#  -1 == don't ban
#   0 == server ban, not an actual ban entrie in the bot
#  Any number above 0 is considered the number of min's the user
#  is banned in the bot's banlist.  Put an ! infront of the number for
#  it to be a sticky ban, ie set mc_afb(ban) !30
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
#     You can also specify a type of 10 to 19 which correspond to masks
#     0 to 9.  But if the host.domain is a;
#       hostname = Instead of using a * wildcard to replace portions of 
#                  the host.domain, it replaces the numbers in the 
#                  host.domain with a '?' (question mark) wildcard.
#       ip       = It will mask as normal, with no '?' (question mark)
#                  replacments as does hostname.
set mc_afb(bant) 2

# If a user in found in violation of a flyby, what do you want to tell 
# that user?  The first word in this is the mothod in witch you want to 
# get your message accross, either NOTICE or PRIVMSG.  Setting this to 
# "" will disable this function.
# Replacment veriables:
#   %chan == The channel the flyby happened in.
set mc_afb(msg) "PRIVMSG You have been banned from %chan for doing a flyby.  The ban will lift in 2 hours."

# What's the reason for the ban?  This info will apear when pulling a 
# .bans listing in the bot, and as the kick message if the user comes 
# back and he's still in the ban list.
set mc_afb(reason) "Anti Flyby"


## MC SVS (Script Version Service) v2.0 ##
# [0=no/1=yes] Do you want the bot to connection to MC_8's SVS to see
# if there are newer versions of this script avilable?  It will only
# tell you -- It's up to you to get the newest version (I decided not
# to auto update the code, there may be new features in the newest
# script that may require your attention).
set mc_afb(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_afb(svs:check) 0   ;#This is at Midnight
#  set mc_afb(svs:check) 5   ;#This is at 5am
#  set mc_afb(svs:check) 13  ;#This is at 1pm
#  set mc_afb(svs:check) 23  ;#This is at 11pm
set mc_afb(svs:check) 3

# Upon finding a newer version of this script, who do you want this
# script to send a note to telling them of this newer version? If more
# than 1 user is to be notified, seperate each user with a ' ' (space).
set mc_afb(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or
# just stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_afb(svs:stableonly) 0


##
# TCL Coding below, do not proceed.
##

#Script:mc_afb

set mc_afb(script)      "Anti Flyby"
set mc_afb(version)     "v2.0"
set mc_afb(svs:script)  "antiflyby"
set mc_afb(svs:version) "002000000000"
set mc_afb(svs:server)  "mc.purehype.net"
set mc_afb(svs:port)    "81"
set mc_afb(svs:get)     "/"
set mc_afb(svs:query)   "svs=$mc_afb(svs:script)&version=$mc_afb(svs:version)"

if {$numversion < "1050500"} {
 putlog "$mc_afb(script) $mc_afb(version) by MC_8 will only work on eggdrop 1.5.5 or greater."
 putlog "$mc_afb(script) $mc_afb(version)  will not work with eggdrop $version."
 putlog "$mc_afb(script) $mc_afb(version)  not loaded."
 return 1
}

setudef int mc.antiflyby

#v1.0
proc mc:afb:error {bindproc error {arg ""}} {
 global mc_afb version lastbind
 putlog "Error in script $mc_afb(script) $mc_afb(version)."
 putlog "        Last bind: $lastbind"
 putlog "        Procedure: $bindproc"
 putlog "             Args: $arg"
 putlog "  Eggdrop version: $version"
 putlog "      TCL version: [info tclversion]"
 putlog "*** Please tell MC_8 about this BUG!  Visit        "
 putlog "*** http://mc.purehype.net:81/bugzilla/ to do so.  "
 putlog "*** Please include the next line in the bug report."
 error $error
}

proc mc:afb:errchk {command arg} {
 if {[catch {eval $command $arg} return]} {
  mc:afb:error $command $return $arg; return 0
 }; return $return
}

bind part - * mc:afb:part
proc mc:afb:part {nick uhost hand chan {msg ""}} {
 return [mc:afb:errchk mc:afb:part_ [list $nick $uhost $hand $chan $msg]]
}
proc mc:afb:part_ {nick uhost hand chan {msg ""}} {
 global mc_afb
 set temp(:cache:time) [mc:afb:chanint $chan mc.antiflyby]
 set temp(:cache:botisop) [botisop $chan]
 if {(!$temp(:cache:time)) || (!$temp(:cache:botisop)) ||
     ([expr [clock seconds]-[getchanjoin $nick $chan]] > $temp(:cache:time)) ||
     (([matchattr $hand $mc_afb(exempt) $chan]) && ($mc_afb(exempt) != ""))} {return 0}
 set banmask [mc:afb:masktype $nick!$uhost $mc_afb(bant)]
 if {$mc_afb(reason) == ""} {set reason "Anti Flyby"} else {set reason $mc_afb(reason)}
 if {[string match !* $mc_afb(ban)]} {set option "sticky"} else {set option "none"}
 set actions ""
 set temp(:cache:stl_ban) [string trimleft $mc_afb(ban) !]
 if {$temp(:cache:stl_ban) > "-1"} {
  set i 0
  if {$temp(:cache:stl_ban) > "0"} {
   newchanban $chan $banmask Anti-Flyby $reason %temp(:cache:stl_ban) $option; set i 1
  }
  if {$temp(:cache:botisop)} {putserv "MODE $chan +b $banmask"; set i 1}
  if {$i} {lappend actions "banned $banmask"}
 }
 set temp(:cache:method) [string toupper [lindex [split $mc_afb(msg) " "] 0]]
 set temp(:cache:msg) [join [lrange [split $mc_afb(msg) " "] 1 end] " "]
 if {[regexp -- {^(NOTICE|PRIVMSG)$} $temp(:cache:method)]} {
  set temp(:cache:msg) [mc:afb:replace $temp(:cache:msg) [list %chan $chan]]
  puthelp "$temp(:cache:method) $nick :$temp(:cache:msg)"
  lappend actions "$temp(:cache:method)'d $nick"
 }
 if {$actions == ""} {lappend actions "nothing done"} 
 putlog "$mc_afb(script):  Detected flyby from $nick for $chan;  [join $actions ", "]"
}

# v1.1
proc mc:afb:replace {text subs} {
 if {![catch {string map -nocase $subs $text} output]} {return $output}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- {([\\\*\+\?\{\}\,\(\)\:\[\]\.\^\$\=\!\|])} [lindex $subs $i] {\\\1} temp(temp)
  regsub -all -- $temp(temp) $text [lindex $subs [expr $i+1]] text
 }; return $text
}

# v1.0
proc mc:afb:masktype {hostmask type} {
 set ident_max-length 9
 set host_max-length 63
 scan $hostmask {%[^!]!%[^@]@%s} nick ident host
 set maskhost 1
 if {[regexp -- {^1[0-9]$} $type]} {
  if {!([regexp -- {^([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)\.([0-9][0-9]?[0-9]?)$} $host temp a b c d] && ($a > 0 && $a < 255 && $b < 255 && $c < 255 && $d < 255))} {
   regsub -all {[0-9]} $host "?" host
   set maskhost 0
  };set type [string index $type 1]
 }
 if {[regexp -- {^[0-4]$} $type]} {set nick "*"}
 if {[regexp -- {^[2479]$} $type]} {set ident "*"}
 if {[regexp -- {^[1368]$} $type]} {set ident "*[string trimleft $ident ~]"}
 if {[regexp -- {^[3489]$} $type]} {if {$maskhost} {scan [maskhost $host] {%[^@]@%s} temp host}}
 if {[string length $ident] > ${ident_max-length}} {
  set ident "*[string range $ident [expr [string length $ident]-${ident_max-length}] end]"
 }
 if {[string length $host] > ${host_max-length}} {
  set host "*[string range $host [expr [string length $host]-${host_max-length}] end]"
 }; return [format "%s!%s@%s" $nick $ident $host]
}

# v2.0
proc mc:afb:chanint {channel int} {
 set cache(chaninfo) [string tolower [channel info $channel]]
 regsub -all -- {([\\\{\}\[\]\"])} [string tolower $int] {\\\1} int
 if {[set temp(i) [lsearch -glob $cache(chaninfo) "$int *"]] == "-1"} {return -1}
 return [lindex [split [lindex $cache(chaninfo) $temp(i)] " "] 1]
}

## SVS v2.0
if {(![info exists mc_afb(svs:enabled)]) ||
    (![regexp -- {^(0|1)$} $mc_afb(svs:enabled)])} {set mc_afb(svs:enabled) 0}
if {(![info exists mc_afb(svs:check)]) ||
    ([regexp -- {[^0-9]} $mc_afb(svs:check)])} {set mc_afb(svs:check) 0}
if {![info exists mc_afb(svs:notify)]} {set mc_afb(svs:notify) $owner}
if {(![info exists mc_afb(svs:stableonly)]) ||
    (![regexp -- {^(0|1)$} $mc_afb(svs:stableonly)])} {set mc_afb(svs:stableonly) 0}
foreach bind [binds mc:afb:svs:time] {
 unbind [lindex $bind 0] [lindex $bind 1] [lindex $bind 2] [lindex $bind 4]
}
foreach command [info commands mc:afb:svs:time] {rename $command ""}
if {$mc_afb(svs:enabled)} {
 if {($mc_afb(svs:check) > "23") || ($mc_afb(svs:check) < "0")} {set mc_afb(svs:check) 00}
 if {[string length $mc_afb(svs:check)] == "1"} {set mc_afb(svs:check) 0$mc_afb(svs:check)}
 bind time - "00 $mc_afb(svs:check) *" mc:afb:svs:time
 proc mc:afb:svs:time {{args ""}} {
  global mc_afb
  if {[catch {socket -async $mc_afb(svs:server) $mc_afb(svs:port)} sid]} {;\
   putlog "SVS Error\[$mc_afb(svs:script)/$mc_afb(svs:version)\]:  $sid"
   return 1
  }
  fconfigure $sid -blocking 0 -buffering line
  set tout [after 60000 "mc:afb:svs:interface $sid timeout"]
  fileevent $sid readable "mc:afb:svs:interface $sid $tout"
  puts $sid "GET $mc_afb(svs:get)?$mc_afb(svs:query) HTTP/1.0\
           \nHost: $mc_afb(svs:server)\n"
  flush $sid
 }
}
proc mc:afb:svs:interface {sid tout} {
 global mc_afb
 if {$tout == "timeout"} {
  putlog "SVS Warning\[$mc_afb(svs:script)/$mc_afb(svs:version)\]:  SVS Server timed out."
  close $sid
  return 0
 }; after cancel $tout
 set temp 0
 while {![eof $sid]} {
  gets $sid get
  if {$temp < "2"} {
   if {$get == ""} {incr temp; if {$temp == "1"} {set temp 2}}
   continue
  }; if {$get == ""} {continue}
  switch -- [lindex $get 0] {
   003 {
    set reply [lrange $get 1 end]
    if {[lindex $reply 0] != $mc_afb(svs:script)} {
     putlog "SVS Error\[$mc_afb(svs:script)/$mc_afb(svs:version)\]:  SVS Server sent wrong info, got [lindex $reply 0]"
     break   
    }
    if {$mc_afb(svs:stableonly)} {
     set temp [string range $mc_afb(svs:version) 0 8]999
    } else {set temp [string range $mc_afb(svs:version) 0 11]}
    if {[lindex $reply 1] > $temp} {
     set note [lindex $reply 5]
     regsub -- %0 $note [lindex $reply 0] note
     regsub -- %1 $note [lindex $reply 1] note
     regsub -- %2 $note [lindex $reply 2] note
     regsub -- %3 $note [lindex $reply 3] note
     regsub -- %4 $note [lindex $reply 4] note
     regsub -- %version $note $mc_afb(version) note
     foreach to [split $mc_afb(svs:notify) ",; "] {
      if {$to == ""} {continue}
      regsub -- %nick $note $to outnote
      if {[string match *$outnote* [set unotes [notes $to -[notes $to]]]]} {
       set temp 0
       foreach unote $unotes {
        if {$outnote == [lindex $unote 2]} {set temp 1; break}
       }; if {$temp} {continue}
      }
      switch -- [sendnote SVS $to $outnote] {
       0 {
        if {![validuser $notify]} {set x "invalid user"} else {set x "unknown error"}
        putlog "SVS Error\[$mc_afb(svs:script)/$mc_afb(svs:version)\]:  Trying to send note to $to, $x."
       }
       3 {putlog "SVS Error\[$mc_afb(svs:script)/$mc_afb(svs:version)\]:  Trying to send note to $to, notebox too full!"}
      }
     }
    }
   }
  }
 }; close $sid
}
## ^

putlog "$mc_afb(script) $mc_afb(version) by MC_8 loaded."

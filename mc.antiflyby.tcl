##
# Anti Flyby v1.1.2 by by MC_8 - Carl M. Gregory <gregory@worldinter.net>
#  This script will only work on eggdrop 1.5+ series.
#
# If you have any questions/comments/idea's, please email me!
# ( Include the script name and version in the title, if you do email me. )
#
# My SVS Website - http://mc.purehype.net/
##

##
# This script is used to ban people that anoyingly do flyby's aka
# revolving door aka they join then part the channel within several
# seconds.
##

##
# History
##
# v1.1.2 (07.02.01)
#  MC_8 - TU - Tcl error [mc:afb:join]: invalid command name "mc:limit:srange"
#
# v1.1.1 (06.10.01)
#  MC_8 - HTH - Problem with bantype's greater than 9.
#  MC_8 - anonymous - Rewrote the nick filtering system, was still getting problems
#                     with special charactered nicks.
#  MC_8 - Rewrote the masktype procedure a little bit, expected bugs.
#
# v1.1 (03.06.01)
#  MC_8 - Strydor - Fixed special character problems with nicks (simular to Grafx-man's
#                   findings.
#  MC_8 - Upgraded SVS to v1.2
#  MC_8 - Grafx-man - Every nick with a special character in there nick, such as "Bob}{Fox"
#                     was being treated as if they were doing a flyby, even if they parted
#                     after being on the channel for days on end.
#
# v1.0 (01.14.01)
#  MC_8 - M` - Inital Release.
##

##
# Settings
##

# Note:
#  There is one setting you set from dcc chat with the bot using .chanset.
#   antiflyby <time> This is the time in which they user must at least be in the
#                    channel.  If the user partys under this time, he will be
#                    considered as doing a flyby.  The time is in seconds.
#                    Set the time to 0 (default) if you do not want flyby protection
#                    on the particular channel.
#
#  Example from dcc chat with the bot:
#   .chanset #channel antiflyby 3

# Who do you want exempt from this?  Based off flags, <global>|<channel>
set mc_afb(exempt) "nob|no"

# How long do you want the user to be baned?
#  -1 == don't ban
#   0 == server ban, not an actual ban entrie in the bot
#  Any numbers above 0 are considered the number of min's the user
#  is baned in the bot's banlist.  Put an ! infront of the number for
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
#     You can also specify a type of 10 to 19 which correspond to masks 0 to 9, but
#     instead of using a * wildcard to replace portions of the host.domain, it uses ?
#     wildcards to replace the numbers in the address.
set mc_afb(bant) 2

# Do you want to tell the user anything via privmsg?
# %chan will be replaced with the channel this is pertaning to.
# set to "" if you do not want to /msg the user anything.
set mc_afb(msg) "You have been baned from %chan for doing a flyby.  The ban will lift in 2 hours."

# What's the reason for the ban?  This info will apear when pulling a .bans listing
# in the bot, and as the kick message if the user comes back and he's still in the 
# ban list.
set mc_afb(reason) "Anti Flyby"


## MC SVS (Script Version Server) v1.2 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mc_afb(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_afb(svs:check) 0  ;#This is at Midnight
#  set mc_afb(svs:check) 5  ;#This is at 5am
#  set mc_afb(svs:check) 13  ;#This is at 1pm
#  set mc_afb(svs:check) 23  ;#This is at 11pm
set mc_afb(svs:check) 3

# Upon finding a newer version, who do you want to notify via note?
# Only the admin of the bot should really be worried about these notes,
# there the ones that keep everything up to par on the bots.
# Seperate each user with a " " (space).
set mc_afb(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_afb(svs:stableonly) 0

##

##
# Coding 
##
set mc_afb(version) v1.1.2
set mc_afb(svs:script) "antiflyby 001001002000"
set mc_afb(svs:server) "mc.purehype.net 8085"

if {$numversion < "1050000"} {
 putlog "Anti Flyby $mc_afb(version) by MC_8 is for eggdrop 1.5+ series only."
 putlog "Anti Flyby $mc_afb(version) will not work with eggdrop $version."
 putlog "Anti Flyby $mc_afb(version) not loaded."
 return 1
};setudef int antiflyby

bind join - * mc:afb:join
proc mc:afb:join {nick uhost hand chan} {
 global mc_afb;set chan [string tolower $chan]
 if {[matchattr $hand $mc_afb(exempt) $chan] ||
     ![set flyby [mc:afb:chanintinfo $chan antiflyby]]} {return 0}
 set mc_afb(!$nick:$chan) 1
 utimer $flyby "catch {unset mc_afb(![mc:afb:filt $nick:$chan])}"
}

bind part - * mc:afb:part
proc mc:afb:part {nick uhost hand chan {msg ""}} {
 global mc_afb;set chan [string tolower $chan]
 if {![info exists mc_afb(!$nick:$chan)] ||
     ![mc:afb:chanintinfo $chan antiflyby]} {return 0}
 catch {unset mc_afb(!$nick:$chan)};mc:afb:inter:punish $nick $uhost $chan
}

bind nick - * mc:afb:nick
proc mc:afb:nick {nick uhost hand chan newnick} {
 global mc_afb;set chan [string tolower $chan]
 if {![info exists mc_afb(!$nick:$chan)] ||
     ![set flyby [mc:afb:chanintinfo $chan antiflyby]]} {return 0}
 foreach timer [utimers] {
  if {[string match "*unset mc_afb(!$nick:$chan)*" $timer]} {
   set flyby [lindex $timer 0];killutimer [lindex $timer 2];break
  }
 }
 set mc_afb(!$newnick:$chan) 1
 utimer $flyby "catch {unset mc_afb(![mc:afb:filt $newnick:$chan])}"
 catch {unset mc_afb(!$nick:$chan)}
}

proc mc:afb:inter:punish {nick uhost chan} {
 global mc_afb
 set ban [mc:afb:inter:masktype $nick!$uhost $mc_afb(bant)]
 if {$mc_afb(reason) == ""} {set reason "Anti Flyby"} {set reason $mc_afb(reason)}
 set flag 0
 if {[string index $mc_afb(ban) 0] == "!"} {
  set opt "sticky";set ban_o [string range $mc_afb(ban) 1 e]
 } {set opt "none";set ban_o $mc_afb(ban)}
 if {!$ban_o} {
  pushmode $chan +b $ban;set flag 1
 } elseif {$ban_o > 0} {
  newchanban $chan $ban Anti-Flyby $reason $ban_o $opt
  set flag 1
 };if {[onchan $nick $chan]} {putkick $chan $nick $reason;incr flag 2}
 if {$mc_afb(msg) != ""} {
  puthelp "PRIVMSG $nick :[mc:afb:inter:replace $mc_afb(msg) "%chan $chan"]"
  incr flag 4
 }
 switch -- $flag {
  7 {putlog "Anti Flyby:  Banned $nick ($ban) on $chan.  Kicking and messaging user as well."}
  6 {putlog "Anti Flyby:  Kicking and messaging $nick for doing a flyby on $chan."}
  5 {putlog "Anti Flyby:  Banned $nick ($ban) on $chan.  Also messaged $nick about the flyby."}
  4 {putlog "Anti Flyby:  Messaged $nick about the his/her flyby in $chan."}
  3 {putlog "Anti Flyby:  Banned $nick ($ban) on $chan.  User still in channel, kicking..."}
  2 {putlog "Anti Flyby:  Kicking $nick from $chan."}
  1 {putlog "Anti Flyby:  Banned $nick ($ban) on $chan."}
  0 {putlog "Anti Flyby:  $nick was detected doing a flyby on $chan... for some reason I didn't do anything about it."    }
 }
}

## Moretools masktype
proc mc:afb:inter:masktype {uhost type} {
 if {![string match "*!*@*.*" $uhost]} {
  set nick [lindex [split $uhost "!"] 0]
  if {$nick == ""} {
   set uhost [string range $uhost [expr [string first ! $uhost]+1] e]
   foreach chan [channels] {
    set nick [lindex [mc:afb:inter:findchanuser *$uhost* $chan] 0]
    if {$nick != ""} {break}
   }
   if {$nick == ""} {set uhost $nick!} {set uhost "$nick![gethost $nick]"}
  }
  if {$uhost == "$nick!" || $nothing} {set type "return_nothing"}
 }
 switch -exact $type {
  0 {set ban "*[string range $uhost [string first ! $uhost] e]"}
  1 {set ban "*!*[string trimleft [string range $uhost [expr [string first ! $uhost]+1] e] "~"]"}
  2 {set ban "*!*[string range $uhost [string first @ $uhost] e]"}
  3 {
   set ident [string range $uhost [expr [string first ! $uhost]+1] [expr [string last @ $uhost]-1]]
   set ban "*!*[string trimleft $ident "~"][string range [maskhost $uhost] [string first @ [maskhost $uhost]] e]"
  }
  4 {set ban "*!*[string range [maskhost $uhost] [string last "@" [maskhost $uhost]] e]"}
  5 {set ban $uhost}
  6 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
   set ban "$nick!*[string trimleft $ident "~"][string range $uhost [string last "@" $uhost] e]"
  }
  7 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ban "$nick!*[string range $uhost [string last "@" $uhost] e]"
  }
  8 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
   set ban "$nick!*[string trimleft $ident "~"][string range [maskhost $uhost] [string last "@" [maskhost $uhost]] e]"
  }
  9 {
   set nick [string range $uhost 0 [expr [string first "!" $uhost]-1]]
   set ban "$nick!*[string range [maskhost $uhost] [string last "@" [maskhost $uhost]] e]"
  }
  10 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[mc:afb:inter:findip [string range $host 1 e]] == "0"} {
    set host [mc:afb:inter:replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
    set ban "*!$ident$host"
   } {set ban [mc:afb:inter:masktype $uhost 0]}
  }
  11 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[mc:afb:inter:findip [string range $host 1 e]] == "0"} {
    set host [mc:afb:inter:replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set ident [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]]
    set ban "*!*[string trimleft $ident "~"]$host"
   } {set ban [mc:afb:inter:masktype $uhost 1]}
  }
  12 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[mc:afb:inter:findip [string range $host 1 e]] == "0"} {
    set host [mc:afb:inter:replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set ban "*!*$host"
   } {set ban [mc:afb:inter:masktype $uhost 2]}
  }
  13 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[mc:afb:inter:findip [string range $host 1 e]] == "0"} {set ban [mc:afb:inter:masktype $uhost 11]} {set ban [mc:afb:inter:masktype $uhost 3]}
  }
  14 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[mc:afb:inter:findip [string range $host 1 e]] == "0"} {set ban [mc:afb:inter:masktype $uhost 12]} {set ban [mc:afb:inter:masktype $uhost 4]}
  }
  15 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[mc:afb:inter:findip [string range $host 1 e]] == "0"} {
    set host [mc:afb:inter:replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set rest [string range $uhost 0 [expr [string last "@" $uhost]-1]]
    set ban $rest$host
   } {set ban [mc:afb:inter:masktype $uhost 5]}
  }
  16 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[mc:afb:inter:findip [string range $host 1 e]] == "0"} {
    set host [mc:afb:inter:replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set rest "[string range $uhost 0 [expr [string first "!" $uhost]-1]]!*[string trimleft [string range $uhost [expr [string first "!" $uhost]+1] [expr [string last "@" $uhost]-1]] "~"]"
    set ban $rest$host
   } {set ban [mc:afb:inter:masktype $uhost 6]}
  }
  17 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[mc:afb:inter:findip [string range $host 1 e]] == "0"} {
    set host [mc:afb:inter:replace $host "1 ? 2 ? 3 ? 4 ? 5 ? 6 ? 7 ? 8 ? 9 ? 0 ?"]
    set rest "[string range $uhost 0 [expr [string first "!" $uhost]-1]]!*"
    set ban $rest$host 
   } {set ban [mc:afb:inter:masktype $uhost 7]}
  }
  18 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[mc:afb:inter:findip [string range $host 1 e]] == "0"} {set ban [mc:afb:inter:masktype $uhost 16]} {set ban [mc:afb:inter:masktype $uhost 8]}
  }
  19 {
   set host [string range $uhost [string last "@" $uhost] e]
   if {[mc:afb:inter:findip [string range $host 1 e]] == "0"} {set ban [mc:afb:inter:masktype $uhost 17]} {set ban [mc:afb:inter:masktype $uhost 9]}
  }
  return_nothing {set ban ""}
  default {set ban "*!*[string range $uhost [string first "@" $uhost] e]"}
 }
 set _nick [lindex [split $ban !] 0]
 set _ident [string range $ban [expr [string first ! $ban]+1] [expr [string last @ $ban]-1]]
 set _host [string range $ban [expr [string last @ $ban]+1] e]
 if {$_ident != [set temp [string range $_ident [expr [string length $_ident]-9] e]]} {
  set _ident *[string trimleft $temp *]
 }
 if {$_host != [set temp [string range $_host [expr [string length $_host]-63] e]]} {
  set _host *[string trimleft $temp *]
 } ; return $_nick!$_ident@$_host
}
proc mc:afb:inter:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}
proc mc:afb:inter:findchanuser {hostmask channel} {
 if {![validchan $channel]} {return -code error "no such channel record"} ; set buffer ""
 set hostmask [string tolower $hostmask]
 foreach user [chanlist $channel] {
  if {[string match $hostmask [string tolower $user![getchanhost $user $channel]]]} {
   append buffer " $user"
  }
 };return [string range $buffer] 1 e]
}
proc mc:afb:inter:findip {args} {
 catch {unset mc_found_ip}
 if {![string match *.*.*.* $args]} {return 0}
 foreach arg $args {
  if {[string match *.*.*.* $arg]} {
   set mc_testa [split $arg "."] ; set i 0
   while {[llength $mc_testa] != $i} {
    set mc_test [lrange $mc_testa $i end]
    if {[string length [lindex $mc_test 1]]<4 && [string length [lindex $mc_test 2]]<4} {
     if {[lindex $mc_test 1] < 256 && [lindex $mc_test 2] < 256 && [lindex $mc_test 1] >= 0 && [lindex $mc_test 2] >= 0} {
      set first "abcdefghi"
      if {[string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 1]] <= 9 && [string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 1]] >= 0} {
       set first [string range [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 1] end]
       if {[string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 2]] <= 9 && [string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 2]] >= 0} {
        set first [string range [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 2] end]
        if {[string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 3]] <= 9 && [string index [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 3]] >= 0} {
         set first [string range [lindex $mc_test 0] [expr [string length [lindex $mc_test 0]] - 3] end]
        }
       }
      }
      set second [lindex $mc_test 1] ; set third [lindex $mc_test 2] ; set fourth "abcdefghi"
      if {[string index [lindex $mc_test 3] 0] <= 9 && [string index [lindex $mc_test 3] 0] >= 0} {
       set fourth [string index [lindex $mc_test 3] 0]
       if {[string index [lindex $mc_test 3] 1] <= 9 && [string index [lindex $mc_test 3] 1] >= 0} {
        set fourth $fourth[string index [lindex $mc_test 3] 1]
        if {[string index [lindex $mc_test 3] 2] <= 9 && [string index [lindex $mc_test 3] 2] >= 0} {
         set fourth $fourth[string index [lindex $mc_test 3] 2]
        }
       }
      }
      if {($first < 256) && ($second < 256) && ($third < 256) &&
          ($fourth < 256) && ($first > 0) && ($second > 0) &&
          ($third > 0) && ($fourth > 0) && ([string index $first 0] > 0) &&
          ([string index $second 0] > 0) && ([string index $third 0] > 0) &&
          ([string index $fourth 0] > 0)} {
       if {[info exists mc_found_ip]} {
        set mc_found_ip "$mc_found_ip $first.$second.$third.$fourth"
       } {set mc_found_ip $first.$second.$third.$fourth}
      }
     }
    } ; incr i +1
   }
  }
 } ; if {[info exists mc_found_ip]} {return $mc_found_ip} {return 0}
}
## ^

## sindex procedures (by MC_8 & guppy)
proc mc:afb:slength {str} {return [llength $str]}
proc mc:afb:sindex {str index} {return [lindex [split $str] $index]}
proc mc:afb:srange {str s e} {return [lrange [split $str] $s $e]}
proc mc:afb:filt {data} {
 return [join [split [join [split [join [split [join [split [join [split [join [split $data \\] \\\\] \[] \\\[] \]] \\\]] \}] \\\}] \{] \\\{] \"] \\\"]
}
proc mc:afb:unfilt {data} {
 regsub -all -- \\\\\\\[ $data \[ data;regsub -all -- \\\\\\\] $data \] data;regsub -all -- \\\\\\\} $data \} data
 regsub -all -- \\\\\\\{ $data \{ data;regsub -all -- \\\\\\\" $data \" data;regsub -all -- \\\\\\\\ $data \\ data;return $data
}
## sindex end

proc mc:afb:chanflagison {chan flag} {
 foreach info [string tolower [channel info [string tolower $chan]]] {
  if {[string range $info 1 e] == [string tolower $flag]} {
   if {[string index $info 0] == "-"} {
    return 0
   } elseif {[string index $info 0] == "+"} {
    return 1
   } else {return 2}
  }
 };return -1
}

## chanintinfo
proc mc:afb:chanintinfo {chan flag} {
 foreach info [string tolower [channel info $chan]] {
  if {[lindex $info 0] == [string tolower $flag]} {
   return [mc:afb:srange $info 1 e]
  }
 };return ""
}
## ^

if {$mc_afb(svs:enabled)} {
 if {($mc_afb(svs:check) > "23") || ($mc_afb(svs:check) < "0")} {set mc_afb(svs:check) 00}
 if {[string length $mc_afb(svs:check)] == "1"} {set mc_afb(svs:check) 0$mc_afb(svs:check)}
 if {$mc_afb(svs:stableonly)} {
  set mc_afb(svs:script) [string range $mc_afb(svs:script) 0 [expr [string length $mc_afb(svs:script)]-4]]999
 }
 catch {unbind time - "00 $mc_afb(svs:oldcheck) * * *" mc:afb:svs:time}
 set mc_afb(svs:oldcheck) $mc_afb(svs:check)
 bind time - "00 $mc_afb(svs:check) * * *" mc:afb:svs:time
 proc mc:afb:svs:time {min hour day month year} {
  global mc_afb
  catch {control [connect [lindex $mc_afb(svs:server) 0] [lindex $mc_afb(svs:server) 1]] mc:afb:svs:interface}
 }
}
proc mc:afb:svs:interface {idx args} {
 global mc_afb;set args [join $args]
 switch -- [lindex $args 0] {
  "" {return 1}
  000 {putdcc $idx q}
  002 {putdcc $idx [lindex $mc_afb(svs:script) 0]}
  003 {
   set args [lrange $args 1 e]
   if {[lindex $args 0] != [lindex $mc_afb(svs:script) 0]} {return 0}
   putdcc $idx q
   if {[lindex $args 1] > [lindex $mc_afb(svs:script) 1]} {
    set note [mc:afb:svs:replace [lindex $args 7] "%0 {[lindex $args 0]} %1 {[lindex $args 1]} %2 {[lindex $args 2]}"]
    set note [mc:afb:svs:replace $note "%3 {[lindex $args 3]} %4 {[lindex $args 4]} %5 {[lindex $args 5]}"]
    set note [mc:afb:svs:replace $note "%6 {[lindex $args 6]} %8 {[lindex $args 8]} %version {$mc_afb(version)}"]
    set note [mc:afb:svs:replace $note "%9 {[lindex $args 9]} %10 {[lindex $args 10]} %11 {[lindex $args 11]}"]
    set note [mc:afb:svs:replace $note "%12 {[lindex $args 12]} %13 {[lindex $args 13]} %14 {[lindex $args 14]}"]
    set note [mc:afb:svs:replace $note "%15 {[lindex $args 15]} %16 {[lindex $args 16]} %17 {[lindex $args 17]}"]
    set note [mc:afb:svs:replace $note "%18 {[lindex $args 18]} %19 {[lindex $args 19]} %20 {[lindex $args 20]}"]
    foreach notify [join [split $mc_afb(svs:notify) ",;"]] {
     set outnote [mc:afb:svs:replace $note "%nick {$notify}"]
     if {[string match "*$outnote*" "[notes $notify -[notes $notify]]"]} {
      set cont 0
      foreach unote [notes $notify -[notes $notify]] {
       if {$outnote == [lindex $unote 2]} {set cont 1;break}
      };if {$cont} {continue}
     }
     switch -- [sendnote SVS $notify $outnote] {
      0 {putlog "MC SVS for [lindex $mc_afb(svs:script) 0] had some errors updating $notify on current version of script; unknown reason!"}
      3 {putlog "MC SVS for [lindex $mc_afb(svs:script) 0] had some errors updating $notify on current version of script; notebox too full!"}
     }
    }
   }
  }
 };return 0
}
proc mc:afb:svs:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

putlog "Anti Flyby $mc_afb(version) by MC_8 loaded."

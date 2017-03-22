#!/usr/bin/expect -f
spawn telnet gotsvl3030.got.volvocars.net
expect -re "login"
send "mgunjal\n"
expect -re "Password"
send "jan@2013\n"
#interact
sleep 2
send "/data01/bppunisr/uniserv/restart.sh\n"
sleep 2
send "exit\n"
interact
#sleep 2

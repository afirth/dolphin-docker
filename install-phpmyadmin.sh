#!/usr/bin/expect -f

set timeout -1
spawn apt-get install -y phpmyadmin 
expect "Web server to reconfigure automatically:" 
send "1\r" 
expect "Configure database for phpmyadmin with dbconfig-common?" 
send "y\r" 
expect "Password of the database's administrative user:" 
send "\r" 
expect "MySQL application password for phpmyadmin:" 
send "\r" 


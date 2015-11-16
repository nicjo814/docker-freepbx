#!/bin/sh
rm -f /var/run/fail2ban/fail2ban.sock
/etc/init.d/fail2ban start


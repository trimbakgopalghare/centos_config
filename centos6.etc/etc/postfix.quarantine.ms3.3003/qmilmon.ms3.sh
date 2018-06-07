#!/bin/sh

/bin/rm -f /var/run/quarantine_log_milter.ms3.sock

pid=$(/bin/ps ax | grep "/var/run/quarantine_log_milter.ms3.sock" | awk '{print $1}')
/bin/kill -9 $pid

/usr/bin/gcc -D_REENTRANT -o /etc/postfix.quarantine.ms3.3003/quarantine_log_milter /etc/postfix.quarantine.ms3.3003/quarantine_log_milter.c  -lmilter -lresolv  -lnsl -lpthread `mysql_config --include` `mysql_config --libs`

#/usr/bin/gcc -D_REENTRANT -o milter -DMEMWATCH -DMEMWATCH_STDIO milter.c  memwatch.c -lmilter -lresolv  -lnsl -lpthread `mysql_config --include` `mysql_config --libs`

/etc/postfix.quarantine.ms3.3003/quarantine_log_milter -p /var/run/quarantine_log_milter.ms3.sock &

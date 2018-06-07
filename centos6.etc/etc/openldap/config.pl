#!/usr/bin/perl
#
# Configuration File.
# Add all the config params in this file.

use warnings;

$MAILSERVE_DB_HOST = '192.168.1.187';
$MAILSERVE_DB_USER = 'mailserve';
$MAILSERVE_DB_PWD = 'mail1234';

$second=1800;#(60x30=1800, 1800=30 minutes)

($sec, $min, $hour, $mday, $mon, $year) = localtime(time());

$current_time=sprintf '%d-%02d-%02d %02d:%02d:%02d', 1900+$year, 1+$mon, $mday, $hour, $min, $sec;


#For calculating 30 min time before current time.

($sec, $min, $hour, $mday, $mon, $year) = localtime(time()-$second);

$time=sprintf '%d-%02d-%02d %02d:%02d:%02d', 1900+$year, 1+$mon, $mday, $hour, $min, $sec;


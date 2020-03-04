#!/bin/bash
time=`date '+%H:%M'`
echo $time > /tmp/scan_cron.tmp
cron=$(cat /var/log/cron | grep $time | grep /list/list_zabbix)
echo $cron > /tmp/scan_cron.tmp
ckeck_cron=$(cat /tmp/scan_cron.tmp | grep $time | wc -l)
echo $ckeck_cron > /tmp/scan_cron.tmp

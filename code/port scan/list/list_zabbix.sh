#!/bin/bash
#every day mv and tar log
#change name
d1=$(date '+%Y-%m-%d')
#check file date whether yesterday
d2=$(date  '+%b %d' --date="-1 day")
#check tar file whether More than 1 month
d3=$(date '+%Y-%m-%d' --date="-1 month")
log_var=$(ls -al /opt/port_scan_log/scan.log | awk '{print $6,$7}')
if [ "$d2" = "$log_var" ];then
     mv /opt/port_scan_log/scan.log /opt/port_scan_log/$d1.log
     tar zcvf /opt/port_scan_log/oldlog/$d1.tar.gz /opt/port_scan_log/$d1.log 
     #del chang name scan.log
     rm -rf /opt/port_scan_log/$d1.log 
     #del old 1 month
     rm -rf /opt/port_scan_log/oldlog/$d3.tar.gz
fi

#set Whether script is interrupted(start)
check_action=1
echo $check_action > /tmp/scan_check_action.tmp

#set file
server_fileip="/list/server/server_iplist.txt" 
server_filename="/list/server/server_namelist.txt" 
server_fileport="/list/server/server_portlist.txt" 
cdn_fileip="/list/cdn/cdn_iplist.txt" 
cdn_filename="/list/cdn/cdn_namelist.txt" 
cdn_fileport="/list/cdn/cdn_portlist.txt" 
robot_fileip="/list/robot/robot_iplist.txt"
robot_filename="/list/robot/robot_namelist.txt"
robot_fileport="/list/robot/robot_portlist.txt"
other_fileip="/list/other/other_iplist.txt"
other_filename="/list/other/other_namelist.txt"
other_fileport="/list/other/other_portlist.txt"

exec 3< $server_filename
exec 4< $server_fileport
exec 5< $server_fileip
exec 6< $cdn_filename
exec 7< $cdn_fileport
exec 8< $cdn_fileip
exec 9< $robot_filename
exec 10< $robot_fileport
exec 11< $robot_fileip
exec 12< $other_filename
exec 13< $other_fileport
exec 14< $other_fileip

#clean /tmp/scan.tmp
cat /dev/null > /tmp/scan.tmp
#clean /tmp/scan_alert.tmp
cat /dev/null > /tmp/scan_alert.tmp
#clean /tmp/scan_log.tmp 
cat /dev/null > /tmp/scan_log.tmp 
#clean /tmp/scan_no_online.tmp
cat /dev/null > /tmp/scan_no_online.tmp
#log time ex:2019-11-19 11:06:14
d4=`date '+%Y-%m-%d %H:%M:%S'`
echo ===========$d4============= >> /opt/port_scan_log/scan.log

#=========================此為偵掃====================================

#live
while read line3<& 3 && read line4<& 4 && read line5<& 5
do
     mkdir -p /opt/port_scan_log/temporarily/live/$line5
     echo $line3 > /opt/port_scan_log/temporarily/live/$line5/$line5-name.txt &
     echo $line5 > /opt/port_scan_log/temporarily/live/$line5/$line5-ip.txt &
     nmap -T4 -p$line4 $line5 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' > /opt/port_scan_log/temporarily/live/$line5/$line5-port.txt &
     nmap -T4 -p$line4 $line5 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' | grep filtered | wc -l > /opt/port_scan_log/temporarily/live/$line5/$line5.tmp &
done 

#cdn
while read line6<& 6 && read line7<& 7 && read line8<& 8
do
     mkdir -p /opt/port_scan_log/temporarily/cdn/$line8
     echo $line6 > /opt/port_scan_log/temporarily/cdn/$line8/$line8-name.txt &
     echo $line8 > /opt/port_scan_log/temporarily/cdn/$line8/$line8-ip.txt &
     nmap -T4 -sA -Pn -p$line7 $line8 | awk '/unfiltered|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' > /opt/port_scan_log/temporarily/cdn/$line8/$line8-port.txt &
     nmap -T4 -sA -Pn -p$line7 $line8 | awk '/unfiltered|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' | grep unfiltered > /opt/port_scan_log/temporarily/cdn/$line8/$line8.tmp &
done

#採集器
while read line9<& 9 && read line10<& 10 && read line11<& 11
do
     mkdir -p /opt/port_scan_log/temporarily/robot/$line11
     echo $line9 > /opt/port_scan_log/temporarily/robot/$line11/$line11-name.txt &
     echo $line11 > /opt/port_scan_log/temporarily/robot/$line11/$line11-ip.txt &
     nmap -T4 -p$line10 $line11 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' > /opt/port_scan_log/temporarily/robot/$line11/$line11-port.txt &  
     nmap -T4 -p$line10 $line11 | awk '/unfiltered|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' | grep filtered | wc -l > /opt/port_scan_log/temporarily/robot/$line11/$line11.tmp &
done

#other scan
# while read line12<& 12 && read line13<& 13 && read line14<& 14
# do
     # mkdir -p /opt/port_scan_log/temporarily/other/$line14
     # echo $line12 > /opt/port_scan_log/temporarily/other/$line14/$line14-name.txt &
     # echo $line14 > /opt/port_scan_log/temporarily/other/$line14/$line14-ip.txt &
     # nmap -T4 -p$line13 $line14 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' > /opt/port_scan_log/temporarily/other/$line14/$line14-port.txt &  
     # nmap -T4 -p$line13 $line14 | awk '/unfiltered|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' | grep filtered | wc -l > /opt/port_scan_log/temporarily/other/$line14/$line14.tmp &
#done

wait 
echo "Done"

#=========================此為判斷====================================
exec 3< $server_filename
exec 4< $server_fileport
exec 5< $server_fileip
exec 6< $cdn_filename
exec 7< $cdn_fileport
exec 8< $cdn_fileip
exec 9< $robot_filename
exec 10< $robot_fileport
exec 11< $robot_fileip
exec 12< $other_filename
exec 13< $other_fileport
exec 14< $other_fileip

#live
while read line3<& 3 && read line4<& 4 && read line5<& 5
do
     var_live=$(cat /opt/port_scan_log/temporarily/live/$line5/$line5.tmp)
     # echo $var_live
     # echo "var_live" $var_live --測試用的
     if [ "$var_live" -ne 3 ];then         
          if [ "$var_live" -lt 1 ];then
               var_no_online=1
               echo $var_no_online > /tmp/scan_no_online.tmp 
               echo $line3 >> /tmp/scan.tmp 
               echo $line5 >> /tmp/scan.tmp            
          else
               var_no_online=1
               echo $var_no_online > /tmp/scan_alert.tmp 
               echo $line3 >> /tmp/scan.tmp 
               echo $line5 >> /tmp/scan.tmp 
               nmap -T4 -p$line4 $line5 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' | grep open >> /tmp/scan.tmp                       
          fi
     else
          var_no_online=0
          echo $var_no_online > /tmp/scan_alert.tmp 
     fi
done 

#cdn
while read line6<& 6 && read line7<& 7 && read line8<& 8
do
     cdn_var=$(cat /opt/port_scan_log/temporarily/cdn/$line8/$line8.tmp)
     # echo "cdn_var" $cdn_var --測試用的
     if [ "$cdn_var" ];then
          cdn_var=1
          echo $cdn_var > /tmp/scan_alert.tmp
          echo $line6 >> /tmp/scan.tmp 
          echo $line8 >> /tmp/scan.tmp 
          nmap -T4 -sA -Pn -p$line7 $line8 | awk '/unfiltered|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' | grep unfiltered  >> /tmp/scan.tmp             
     else
          cdn_var=0   
          echo $cdn_var > /tmp/scan_alert.tmp                 
     fi
done

#採集器
while read line9<& 9 && read line10<& 10 && read line11<& 11
do
     robot_var=$(cat /opt/port_scan_log/temporarily/robot/$line11/$line11.tmp)
     # echo "robot_var" $robot_var --測試用的
     if [ "$robot_var" -ne 2 ];then              
          if [ "$robot_var" -lt 1 ];then
               robot_var_no_online=1
               echo $robot_var_no_online > /tmp/scan_no_online.tmp 
               echo $line9 >> /tmp/scan.tmp 
               echo $line11 >> /tmp/scan.tmp            
          else
               robot_var=1
               echo $robot_var > /tmp/scan_alert.tmp 
               echo $line9 >> /tmp/scan.tmp 
               echo $line11 >> /tmp/scan.tmp 
               nmap -T4 -p$line10 $line11 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' | grep open >> /tmp/scan.tmp             
          fi   
          robot_var=0    
          echo $robot_var > /tmp/scan_alert.tmp              
     fi
done

#=========================此為log產出====================================
exec 3< $server_filename
exec 4< $server_fileport
exec 5< $server_fileip
exec 6< $cdn_filename
exec 7< $cdn_fileport
exec 8< $cdn_fileip
exec 9< $robot_filename
exec 10< $robot_fileport
exec 11< $robot_fileip
exec 12< $other_filename
exec 13< $other_fileport
exec 14< $other_fileip

#live
while read line3<& 3 && read line4<& 4 && read line5<& 5
do
     cat /opt/port_scan_log/temporarily/live/$line5/$line5-name.txt >> /opt/port_scan_log/scan.log
     cat /opt/port_scan_log/temporarily/live/$line5/$line5-ip.txt >> /opt/port_scan_log/scan.log
     sed -i -e 's/54952/mysql:&/; s/54952/ssh:&/; s/54952/mysql:&/; s/54952/fikker:&/; s/54952/ssh:&/; s/54952/ssh:&/; s/54952/mysql:&/; s/54952/mysql:&/; s/54952/mysql:&/; s/54952/mysql:&/; s/54952/mysql:&/; s/33652/mysql:&/; s/54952/redis:&/; s/54952/redis:&/; s/54952/redis:&/; s/54952/redis:&/;'  /opt/port_scan_log/temporarily/live/$line5/$line5-port.txt
     cat /opt/port_scan_log/temporarily/live/$line5/$line5-port.txt >> /opt/port_scan_log/scan.log
     echo "" >> /opt/port_scan_log/scan.log
done 

#cdn
while read line6<& 6 && read line7<& 7 && read line8<& 8
do
     cat /opt/port_scan_log/temporarily/cdn/$line8/$line8-name.txt >> /opt/port_scan_log/scan.log
     cat /opt/port_scan_log/temporarily/cdn/$line8/$line8-ip.txt >> /opt/port_scan_log/scan.log
     sed -i -e 's/54952/mysql:&/; s/54952/ssh:&/; s/54952/mysql:&/; s/54952/fikker:&/; s/54952/ssh:&/; s/54952/ssh:&/; s/54952/mysql:&/; s/54952/mysql:&/; s/54952/mysql:&/; s/54952/mysql:&/; s/54952/mysql:&/; s/33652/mysql:&/; s/54952/redis:&/; s/54952/redis:&/; s/54952/redis:&/; s/54952/redis:&/;'  /opt/port_scan_log/temporarily/cdn/$line8/$line8-port.txt
     cat /opt/port_scan_log/temporarily/cdn/$line8/$line8-port.txt >> /opt/port_scan_log/scan.log
     echo "" >> /opt/port_scan_log/scan.log
done

#採集器
while read line9<& 9 && read line10<& 10 && read line11<& 11
do
     cat /opt/port_scan_log/temporarily/robot/$line11/$line11-name.txt >> /opt/port_scan_log/scan.log
     cat /opt/port_scan_log/temporarily/robot/$line11/$line11-ip.txt >> /opt/port_scan_log/scan.log
     sed -i -e 's/54952/mysql:&/; s/54952/ssh:&/; s/54952/mysql:&/; s/54952/fikker:&/; s/54952/ssh:&/; s/54952/ssh:&/; s/54952/ssh:&/; s/54952/mysql:&/; s/54306/mysql:&/; s/54952/mysql:&/; s/54952/mysql:&/; s/54952/mysql:&/; s/54952/mysql:&/; s/33652/mysql:&/; s/54952/redis:&/; s/54952/redis:&/; s/54952/redis:&/; s/54952/redis:&/;'  /opt/port_scan_log/temporarily/robot/$line11/$line11-port.txt
     cat /opt/port_scan_log/temporarily/robot/$line11/$line11-port.txt >> /opt/port_scan_log/scan.log
     echo "" >> /opt/port_scan_log/scan.log
done

#=========================此為log產出====================================
#set Whether script is interrupted(end)
check_action=0
echo $check_action > /tmp/scan_check_action.tmp
#判斷是否機器是否關機或網路不穩導致無法nmap到
no_online=/tmp/scan_no_online.tmp
no_online=$(cat $no_online)
if [ "$no_online" = 1 ];then
 sed -i '1s/^/====請確定伺服器是否關機或網路不穩導致無法nmap到====\n/' /tmp/scan.tmp
fi
#判斷port是否open
alert=/tmp/scan_alert.tmp 
alert=$(cat $alert)
if [ "$alert" = 1 ];then
 sed -i '1s/^/====請確定port是否open====\n/' /tmp/scan.tmp
fi
#display tg
list=$(cat /tmp/scan.tmp)
curl -X POST "tg api" -d "chat_id=-13119152318&text=$list"
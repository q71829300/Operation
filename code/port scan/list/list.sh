#!/bin/bash
server_fileip="/list/server/server_iplist.txt" 
server_filename="/list/server/server_namelist.txt" 
server_fileport="/list/server/server_portlist.txt" 
cdn_fileip="/list/cdn/cdn_iplist.txt" 
cdn_filename="/list/cdn/cdn_namelist.txt" 
cdn_fileport="/list/cdn/cdn_portlist.txt" 
other_fileip="/list/other/other_iplist.txt" 
other_filename="/list/other/other_namelist.txt" 
other_fileport="/list/other/other_portlist.txt" 
robot_fileip="/list/robot/robot_iplist.txt"
robot_filename="/list/robot/robot_namelist.txt"
robot_fileport="/list/robot/robot_portlist.txt"


function choose {
read -p "請選擇要做的事 1:偵掃 2:新增 3:刪除 4:確認預設偵掃清單:" choose
     if [ ${choose} = 1 ];then
     scan
     elif [ ${choose} = 2 ];then
     add 
     elif [ ${choose} = 3 ];then
     del 
     elif [ ${choose} = 4 ];then
     check      
     fi
     
}

function scan {
read -p "輸入要偵掃的類別 1:live 2:cdn 3:other 4:robot:" type_server
     if [ ${type_server} = 1 ];then
     live
     elif [ ${type_server} = 2 ];then
     cdn 
     elif [ ${type_server} = 3 ];then
     other 
     elif [ ${type_server} = 4 ];then
     robot      
     fi
}

function del_ip {
     while [ 1  ]
     do
          echo $ip|egrep -q '^([0-9]{1,3}\.){3}[0-9]{1,3}$'
          if [ $? -eq 0 ];then
               valid=1
               for number in ${ip//./ }
               do
                    if [ $number -gt 255 ];then
                         valid=0
                         break
                    fi
               done

               if [ $valid -eq 1 ]
                    then break
               fi
          fi
          read -p "錯誤格式請重新輸入:" ip
     done
}
#----------------------------------------------------------------------------------------------------------------------------------------
#scan
function live {
     read -p "輸入要掃的特定port或是全偵掃(預設port) ex:80 or 80,443 or all:" port
     exec 3< $server_filename
     exec 4< $server_fileport
     exec 5< $server_fileip

     if [ ${port} = "all"  ];then
          cat /dev/null > /tmp/scan.tmp
          cat /dev/null > /tmp/scan2.tmp
          while read line3<& 3 && read line4<& 4 && read line5<& 5
          do
               var_name=$line3
               var_ip=$line5
               var_port=$(nmap -p$line4 $line5 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g')
               var_all=$var_name,$var_ip,$var_port
               echo $var_all > /tmp/scan.tmp                    
               #nmap -p$line4 $line5 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' 
               sed -i -e 's/54633/mysql:&/; s/54633/ssh:&/; s/54633/mysql:&/; s/54633/fikker:&/; s/54633/ssh:&/; s/54633/ssh:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/33652/mysql:&/; s/35756/redis:&/; s/52162/redis:&/; s/35758/redis:&/; s/35765/redis:&/;'  /tmp/scan.tmp
               #跟上面一樣的功能 sed -i -e "s/54633/ssh:&/"  -e "s/54633/ssh:&/"  /tmp/scan.tmp
               var=$(nmap -p$line4 $line5 | awk '/open|unfiltered/' | wc -l)
               if [ ${var} != 0 ];then
                    var_name=$line3
                    var_ip=$line5
                    var_port=$(nmap -p$line4 $line5 |grep tcp | awk '{print $1,$2}' | sed 's/\/tcp//g' | sed 's/ /:/g')
                    var_all=$var_name,$var_ip,$var_port
                    echo $var_all >> /tmp/scan2.tmp
                    echo "" >> /tmp/scan2.tmp
               fi
               exec 6< /tmp/scan.tmp
          while read line6<& 6
          do
               echo $line6
          done
          echo ""
          done 
          echo ================以下為有open的，如果沒有就不會顯示================
          cat /tmp/scan2.tmp
     else 
          cat /dev/null > /tmp/scan.tmp
          while read line3<& 3 && read line4<& 4 && read line5<& 5
          do
               var_name=$line3
               var_ip=$line5
               var_port=$(nmap -p${port} $line5 |grep tcp | awk '{print $1,$2}' | sed 's/\/tcp//g' | sed 's/ /:/g')
               var_all=$var_name,$var_ip,$var_port
               echo $var_all
               var=$(nmap -p${port} $line5 |grep open | wc -l)
               echo "" 
               if [ ${var} != 0 ];then
                    var_name=$line3
                    var_ip=$line5
                    var_port=$(nmap -p${port} $line5 |grep tcp | awk '{print $1,$2}' | sed 's/\/tcp//g' | sed 's/ /:/g')
                    var_all=$var_name,$var_ip,$var_port
                    echo $var_all >> /tmp/scan.tmp
                    echo "" >> /tmp/scan.tmp
               fi
          done 
          echo ================以下為有open的，如果沒有就不會顯示================
          cat /tmp/scan.tmp
     fi
}
function cdn {
     read -p "輸入要掃的特定port或是全偵掃(預設port) ex:80 or 80,443 or all:" port
     exec 3< $cdn_filename
     exec 4< $cdn_fileport
     exec 5< $cdn_fileip

     if [ all = ${port} ];then
          cat /dev/null > /tmp/scan.tmp
          cat /dev/null > /tmp/scan2.tmp
          while read line3<& 3 && read line4<& 4 && read line5<& 5
          do
               var_name=$line3
               var_ip=$line5
               var_port=$(nmap -sA -Pn -p$line4 $line5 | awk '/unfiltered|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g')
               var_all=$var_name,$var_ip,$var_port
               echo $var_all > /tmp/scan.tmp                    
               #nmap -p$line4 $line5 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' 
               sed -i -e 's/54633/mysql:&/; s/54633/ssh:&/; s/54633/mysql:&/; s/54633/fikker:&/; s/54633/ssh:&/; s/54633/ssh:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/33652/mysql:&/; s/35756/redis:&/; s/52162/redis:&/; s/35758/redis:&/; s/35765/redis:&/;'  /tmp/scan.tmp
               #跟上面一樣的功能 sed -i -e "s/54633/ssh:&/"  -e "s/35156/ssh:&/"  /tmp/scan.tmp
               var=$(nmap -sA -Pn -p$line4 $line5 | awk '/unfiltered|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' | grep unfiltered | wc -l)
               if [ ${var} != 0 ];then
                    var_name=$line3
                    var_ip=$line5
                    var_port=$(nmap -p$line4 $line5 |grep tcp | awk '{print $1,$2}' | sed 's/\/tcp//g' | sed 's/ /:/g')
                    var_all=$var_name,$var_ip,$var_port
                    echo $var_all >> /tmp/scan2.tmp
                    echo "" >> /tmp/scan2.tmp
               fi
               exec 6< /tmp/scan.tmp
          while read line6<& 6
          do
               echo $line6
          done
          echo ""
          done 
          echo ================以下為有open的，如果沒有就不會顯示================
          cat /tmp/scan2.tmp
     else
          cat /dev/null > /tmp/scan.tmp
          while read line3<& 3 && read line4<& 4 && read line5<& 5
          do
               var_name=$line3
               var_ip=$line5
               var_port=$(nmap -p${port} $line5 |grep tcp | awk '{print $1,$2}' | sed 's/\/tcp//g' | sed 's/ /:/g')
               var_all=$var_name,$var_ip,$var_port
               echo $var_all
               var=$(nmap -p${port} $line5 |grep open | wc -l)
               echo "" 
               if [ ${var} != 0 ];then
                    var_name=$line3
                    var_ip=$line5
                    var_port=$(nmap -p${port} $line5 |grep tcp | awk '{print $1,$2}' | sed 's/\/tcp//g' | sed 's/ /:/g')
                    var_all=$var_name,$var_ip,$var_port
                    echo $var_all >> /tmp/scan.tmp
                    echo "" >> /tmp/scan.tmp
               fi
          done 
          echo ================以下為有open的，如果沒有就不會顯示================
          cat /tmp/scan.tmp
     fi
}
function other {
     read -p "輸入要掃的特定port或是全偵掃(預設port) ex:80 or 80,443 or all:" port
     exec 3< $other_filename
     exec 4< $other_fileport
     exec 5< $other_fileip

     if [ all = ${port} ];then
          cat /dev/null > /tmp/scan.tmp
          cat /dev/null > /tmp/scan2.tmp
          while read line3<& 3 && read line4<& 4 && read line5<& 5
          do
               var_name=$line3
               var_ip=$line5
               var_port=$(nmap -p$line4 $line5 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g')
               var_all=$var_name,$var_ip,$var_port
               echo $var_all > /tmp/scan.tmp                    
               #nmap -p$line4 $line5 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' 
               sed -i -e 's/54633/mysql:&/; s/54633/ssh:&/; s/54633/mysql:&/; s/54633/fikker:&/; s/54633/ssh:&/; s/54633/ssh:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/33652/mysql:&/; s/35756/redis:&/; s/52162/redis:&/; s/35758/redis:&/; s/35765/redis:&/;'  /tmp/scan.tmp
               #跟上面一樣的功能 sed -i -e "s/54633/ssh:&/"  -e "s/54633/ssh:&/"  /tmp/scan.tmp
               var=$(nmap -p$line4 $line5 | awk '/open|unfiltered/' | wc -l)
               if [ ${var} != 0 ];then
                    var_name=$line3
                    var_ip=$line5
                    var_port=$(nmap -p$line4 $line5 |grep tcp | awk '{print $1,$2}' | sed 's/\/tcp//g' | sed 's/ /:/g')
                    var_all=$var_name,$var_ip,$var_port
                    echo $var_all >> /tmp/scan2.tmp
                    echo "" >> /tmp/scan2.tmp
               fi
               exec 6< /tmp/scan.tmp
          while read line6<& 6
          do
               echo $line6
          done
          echo ""
          done 
          echo ================以下為有open的，如果沒有就不會顯示================
          cat /tmp/scan2.tmp
     else
          cat /dev/null > /tmp/scan.tmp
          while read line3<& 3 && read line4<& 4 && read line5<& 5
          do
               var_name=$line3
               var_ip=$line5
               var_port=$(nmap -p${port} $line5 |grep tcp | awk '{print $1,$2}' | sed 's/\/tcp//g' | sed 's/ /:/g')
               var_all=$var_name,$var_ip,$var_port
               echo $var_all
               var=$(nmap -p${port} $line5 |grep open | wc -l)
               echo "" 
               if [ ${var} != 0 ];then
                    var_name=$line3
                    var_ip=$line5
                    var_port=$(nmap -p${port} $line5 |grep tcp | awk '{print $1,$2}' | sed 's/\/tcp//g' | sed 's/ /:/g')
                    var_all=$var_name,$var_ip,$var_port
                    echo $var_all >> /tmp/scan.tmp
                    echo "" >> /tmp/scan.tmp
               fi
          done 
          echo ================以下為有open的，如果沒有就不會顯示================
          cat /tmp/scan.tmp
     fi
}
function robot {
     read -p "輸入要掃的特定port或是全偵掃(預設port) ex:80 or 80,443 or all:" port
     exec 3< $robot_filename
     exec 4< $robot_fileport
     exec 5< $robot_fileip

     if [ all = ${port} ];then
          cat /dev/null > /tmp/scan.tmp
          cat /dev/null > /tmp/scan2.tmp
          while read line3<& 3 && read line4<& 4 && read line5<& 5
          do
               var_name=$line3
               var_ip=$line5
               var_port=$(nmap -p$line4 $line5 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g')
               var_all=$var_name,$var_ip,$var_port
               echo $var_all > /tmp/scan.tmp                    
               #nmap -p$line4 $line5 | awk '/open|closed|filtered/' | sed 's/unknown//g' | sed 's/unknown//g' |  sed 's/ //g' | awk -F/tcp  'BEGIN{OFS=":"}{print $1,$2}' | sed 's/mysql//g' 
               sed -i -e 's/54633/mysql:&/; s/54633/ssh:&/; s/54633/mysql:&/; s/54633/fikker:&/; s/54633/ssh:&/; s/54633/ssh:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/54633/mysql:&/; s/33652/mysql:&/; s/35756/redis:&/; s/52162/redis:&/; s/35758/redis:&/; s/35765/redis:&/;'  /tmp/scan.tmp
               #跟上面一樣的功能 sed -i -e "s/35356/ssh:&/"  -e "s/35156/ssh:&/"  /tmp/scan.tmp
               var=$(nmap -p$line4 $line5 | awk '/open|unfiltered/' | wc -l)
               if [ ${var} != 0 ];then
                    var_name=$line3
                    var_ip=$line5
                    var_port=$(nmap -p$line4 $line5 |grep tcp | awk '{print $1,$2}' | sed 's/\/tcp//g' | sed 's/ /:/g')
                    var_all=$var_name,$var_ip,$var_port
                    echo $var_all >> /tmp/scan2.tmp
                    echo "" >> /tmp/scan2.tmp
               fi
               exec 6< /tmp/scan.tmp
          while read line6<& 6
          do
               echo $line6
          done
          echo ""
          done 
          echo ================以下為有open的，如果沒有就不會顯示================
          cat /tmp/scan2.tmp
     else
          cat /dev/null > /tmp/scan.tmp
          while read line3<& 3 && read line4<& 4 && read line5<& 5
          do
               var_name=$line3
               var_ip=$line5
               var_port=$(nmap -p${port} $line5 |grep tcp | awk '{print $1,$2}' | sed 's/\/tcp//g' | sed 's/ /:/g')
               var_all=$var_name,$var_ip,$var_port
               echo $var_all
               var=$(nmap -p${port} $line5 |grep open | wc -l)
               echo "" 
               if [ ${var} != 0 ];then
                    var_name=$line3
                    var_ip=$line5
                    var_port=$(nmap -p${port} $line5 |grep tcp | awk '{print $1,$2}' | sed 's/\/tcp//g' | sed 's/ /:/g')
                    var_all=$var_name,$var_ip,$var_port
                    echo $var_all >> /tmp/scan.tmp
                    echo "" >> /tmp/scan.tmp
               fi
          done 
          echo ================以下為有open的，如果沒有就不會顯示================
          cat /tmp/scan.tmp
     fi
}
#----------------------------------------------------------------------------------------------------------------------------------------
#add

function add {
     read -p "輸入要新增的類別 1:live 2:cdn 3:other 4:robot:" type_server
     if [ ${type_server} = 1 ];then
     live_add
     elif [ ${type_server} = 2 ];then
     cdn_add
     elif [ ${type_server} = 3 ];then
     other_add 
     elif [ ${type_server} = 4 ];then
     robot_add      
     fi     
}

function live_add {
     echo ""
     echo ================新增前查看================
     exec 3< $server_filename
     exec 4< $server_fileport
     exec 5< $server_fileip
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     live_del_look=$line3,$line5,$line4
     echo $live_del_look
     done 
     echo ""
     read -p "輸入要增加的名稱:" name
     read -p "輸入要增加的ssh,mysql,redis port:" port
     read -p "輸入要增加的ip": ip
     del_ip
     echo ${name} >> $server_filename
     echo ${port} >> $server_fileport
     echo ${ip} >> $server_fileip

     exec 3< $server_filename
     exec 4< $server_fileport
     exec 5< $server_fileip
     echo ""
     echo ===新增後檢查===
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     live_del_look=$line3,$line5,$line4
     echo $live_del_look
     done
}
function cdn_add {
     echo ""
     echo ================新增前查看================
     exec 3< $cdn_filename
     exec 4< $cdn_fileport
     exec 5< $cdn_fileip
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     cdn_del_look=$line3,$line5,$line4
     echo $cdn_del_look
     done 
     echo ""
     read -p "輸入要增加的名稱:" name
     read -p "輸入要增加的ssh,fikker port:" port
     read -p "輸入要增加的ip": ip
     del_ip
     echo ${name} >> $cdn_filename
     echo ${port} >> $cdn_fileport
     echo ${ip} >> $cdn_fileip

     exec 3< $cdn_filename
     exec 4< $cdn_fileport
     exec 5< $cdn_fileip
     echo ""
     echo ================新增後檢查================
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     cdn_del_look=$line3,$line5,$line4
     echo $cdn_del_look
     done 
}
function other_add {
     echo ""
     echo ================新增前查看================
     exec 3< $other_filename
     exec 4< $other_fileport
     exec 5< $other_fileip
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     other_del_look=$line3,$line5,$line4
     echo $other_del_look
     done 
     echo ""
     read -p "輸入要增加的名稱:" name
     read -p "輸入要增加的ssh,mysql,redis port:" port
     read -p "輸入要增加的ip": ip
     del_ip
     echo ${name} >> $other_filename
     echo ${port} >> $other_fileport
     echo ${ip} >> $other_fileip
  
     exec 3< $other_filename
     exec 4< $other_fileport
     exec 5< $other_fileip
     echo ""
     echo ================新增後檢查================
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     other_del_look=$line3,$line5,$line4
     echo $other_del_look
     done 
}
function robot_add {
     echo ""
     echo ================新增前查看================
     exec 3< $robot_filename
     exec 4< $robot_fileport
     exec 5< $robot_fileip
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     robot_del_look=$line3,$line5,$line4
     echo $robot_del_look
     done 
     echo ""
     read -p "輸入要增加的名稱:" name
     read -p "輸入要增加的ssh,mysql,redis port:" port
     read -p "輸入要增加的ip": ip
     del_ip
     echo ${name} >> $robot_filename
     echo ${port} >> $robot_fileport
     echo ${ip} >> $robot_fileip

     exec 3< $robot_filename
     exec 4< $robot_fileport
     exec 5< $robot_fileip
     echo ""
     echo ================新增後檢查================
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     robot_del_look=$line3,$line5,$line4
     echo $robot_del_look
     done  
}

#----------------------------------------------------------------------------------------------------------------------------------------
#del

function del {
     read -p "輸入要刪除的類別 1:live 2:cdn 3:other 4:robot:" type_server
     if [ ${type_server} = 1 ];then
     live_del
     elif [ ${type_server} = 2 ];then
     cdn_del
     elif [ ${type_server} = 3 ];then
     other_del 
     elif [ ${type_server} = 4 ];then
     robot_del      
     fi     
}

function live_del {
     echo ""
     echo ================刪除前查看================
     exec 3< $server_filename
     exec 4< $server_fileport
     exec 5< $server_fileip
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     live_del_look=$line3,$line5,$line4
     echo $live_del_look
     done 
     echo ""
     read -p "輸入要刪除的的ip:" ip
     del_ip
     var=$(grep -n "${ip}" $server_fileip | awk -F: '{print $1}')
     echo $var
     var=""$var"d"
     sed -i $var $server_filename
     sed -i $var $server_fileport
     sed -i $var $server_fileip

     exec 3< $server_filename
     exec 4< $server_fileport
     exec 5< $server_fileip
     echo ""
     echo ===刪除後檢查===
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     live_del_look=$line3,$line5,$line4
     echo $live_del_look
     done
}
function cdn_del {
     echo ""
     echo ================刪除前查看================
     exec 3< $cdn_filename
     exec 4< $cdn_fileport
     exec 5< $cdn_fileip
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     cdn_del_look=$line3,$line5,$line4
     echo $cdn_del_look
     done 
     echo ""
     read -p "輸入要刪除的的ip:" ip
     del_ip
     var=$(grep -n "${ip}" $cdn_fileip | awk -F: '{print $1}')
     echo $var
     var=""$var"d"
     sed -i $var $cdn_filename
     sed -i $var $cdn_fileport
     sed -i $var $cdn_fileip

     exec 3< $cdn_filename
     exec 4< $cdn_fileport
     exec 5< $cdn_fileip
     echo ""
     echo ================刪除後檢查================
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     cdn_del_look=$line3,$line5,$line4
     echo $cdn_del_look
     done   
}
function other_del {
     echo ""
     echo ================刪除前查看================
     exec 3< $other_filename
     exec 4< $other_fileport
     exec 5< $other_fileip
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     other_del_look=$line3,$line5,$line4
     echo $other_del_look
     done 
     echo ""
     read -p "輸入要刪除的的ip:" ip
     del_ip
     var=$(grep -n "${ip}" $other_fileip | awk -F: '{print $1}')
     # echo $var
     var=""$var"d"
     sed -i $var $other_filename
     sed -i $var $other_fileport
     sed -i $var $other_fileip

     exec 3< $other_filename
     exec 4< $other_fileport
     exec 5< $other_fileip
     echo ""
     echo ================刪除後檢查================
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     other_del_look=$line3,$line5,$line4
     echo $other_del_look
     done   
}
function robot_del {
     echo ""
     echo ================刪除前查看================
     exec 3< $robot_filename
     exec 4< $robot_fileport
     exec 5< $robot_fileip
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     robot_del_look=$line3,$line5,$line4
     echo $robot_del_look
     done 
     echo ""
     read -p "輸入要刪除的的ip:" ip
     del_ip
     var=$(grep -n "${ip}" $robot_fileip | awk -F: '{print $1}')
     # echo $var
     var=""$var"d"
     sed -i $var $robot_filename
     sed -i $var $robot_fileport
     sed -i $var $robot_fileip

     exec 3< $robot_filename
     exec 4< $robot_fileport
     exec 5< $robot_fileip
     echo ""
     echo ================刪除後檢查================
     while read line3<& 3 && read line4<& 4 && read line5<& 5
     do
     robot_del_look=$line3,$line5,$line4
     echo $robot_del_look
     done  
}
#----------------------------------------------------------------------------------------------------------------------------------------
#check
function check {
     exec 3< $server_filename
     exec 4< $server_fileport
     exec 5< $server_fileip     
     exec 6< $cdn_filename
     exec 7< $cdn_fileport
     exec 8< $cdn_fileip
     exec 9< $robot_filename
     exec 10< $robot_fileport
     exec 11< $robot_fileip     
     echo ===live===
     while read line3<& 3 && read line4<& 4 && read line5<& 5 
     do
     live_var=$line3,$line5,$line4
     echo $live_var
     echo ""
     done 
     echo ""
     echo ===cdn===     
     while read line6<& 6 && read line7<& 7 && read line8<& 8 
     do
     cdn_var=$line6,$line8,$line7
     echo $cdn_var
     echo ""
     done  
     echo ""
     echo ===robot===     
     while read line9<& 9 && read line10<& 10 && read line11<& 11
     do
     robot_var=$line9,$line11,$line10
     echo $robot_var
     echo ""
     done  
     echo ""              
     
}

choose

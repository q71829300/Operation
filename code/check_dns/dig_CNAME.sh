#!/bin/bash

#獲得NS用腳本

read -p '輸入要檢測NS的檔案名稱:' filename

exec < ${filename}

while read line

do

domain_main=$(dig ${line} CNAME | grep IN | grep CNAME)
#echo ${line}=$(echo ${domain_main}|sed "s/\n//g")  #sed "s/\n//g" 去除換行符號
echo ${domain_main}

done

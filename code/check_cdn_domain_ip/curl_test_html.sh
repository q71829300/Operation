#!/bin/bash


printf '一個域名一行\n'
printf '請把網域名稱清單儲存並且放置於腳本同位置底下list目錄夾\n'
printf '\n'
read -p "請輸入檢測的的檔案名稱(域名清單) :" file_name
printf '\n'
printf '請輸入你要測試的中轉機的IP(就一行) \n'
printf '\n'
read -p "請輸入IP :" chk_ip

csv_file="cdn_chk_$(date +"%Y%m%d%H%M").csv"
html_file="cdn_chk_$(date +"%Y%m%d%H%M").html"


rm -rf tmp/${csv_file}

echo -e "domain_name  , title  , content  , certificate_chk , certificate_day" |tee -a tmp/${csv_file}

exec < list/${file_name}
while read line
do
  title=$(curl -m 3 -s   --resolve ${line}:443:${chk_ip} https://${line}|grep "<title>"|cut -d ">" -f2|cut -d "<" -f1)
  content=$(curl -m 3    --resolve ${line}:443:${chk_ip} https://${line} 2>&1|grep "温馨提示"|cut -d">" -f2|cut -d "：" -f1)
  ssl_mach=$(curl -m 3 -sv --resolve ${line}:443:${chk_ip} https://${line} 2>&1 |grep 'not match'|cut -d" " -f"12,13,16")
  ssl_day=$(curl -m 3 -sv  --resolve ${line}:443:${chk_ip} https://${line} 2>&1 |grep 'expire date:'|awk '{print $4,$5,$6,$7}')


	 if [[ -n "$ssl_mach" ]]; then
            ssl_mach="Null"
#	    echo "${line} certificate與域名不符" >> /tmp/curl_temp
	 fi

	 if [[ -z "${title}" ]] ;then
            title="Null"
#	    echo "${line} title是空值" >> /tmp/curl_temp
         fi

         if [[ -z "${content}" ]] ;then
            content="Null"
#            echo "${line} content is null"  >> /tmp/curl_temp
          else
            content=" "
         fi

    echo -e "${line} , ${title} , ${content}, ${ssl_mach},${ssl_day}" | tee -a tmp/${csv_file}
done

echo   "----------------------------------------------------------"
#檢查ip+8068
title=$(curl -m 1 "http://${chk_ip}:8068" 2>&1|grep "<title>"|cut -d ">" -f2|cut -d "<" -f1)
echo "${title}"

if [[ ! -n "${title}" ]]; then
 echo "請檢查 http://${chk_ip}:8068 是否正常"
 echo -e "${chk_ip}:8068 , Null , , , ," >> tmp/${csv_file}
fi

echo -e '======================================================='

#轉換結果成 html
csvtotable  tmp/${csv_file}  tmp/${html_file}

echo "本次檢查結果網頁查連結"

echo "http://34.92.211.206:19890/cdn_check/tmp/${html_file}"

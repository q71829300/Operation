#!/bin/bash
var=$(cat /tmp/scan_check_action.tmp)
if [ ${var} = 1 ];then
    var2=$(ps aux | grep '/bin/bash -c /list/list_zabbix.sh' | grep -v grep | wc -l)
    if [ ${var2} = 1 ];then
            current=$(date +%M)
            after=$(date +%M)
            until [[ $current = $after ]];do
            current=$(date +%M);
            done;
            var3=$(ps aux | grep '/bin/bash -c /list/list_zabbix.sh' | grep -v grep | wc -l)
        if [ ${var3} = 1 ];then
            echo 1
            date >> /tmp/double_chk_port_scan.log
            echo '檢查3分鐘了 list_zabbix.sh 這個執行進程還在，確定這個進程要執行多久，是否要延長檢查時間' >> /tmp/double_chk_port_scan.log
            echo ""            
        else
            var4=$(cat /tmp/scan_check_action.tmp)
            if [ ${var4} = 0 ];then
                echo 0
            else
                echo 1
                echo '已確定請確定list_zabbix.sh這個執行進程沒在執行，請確定port scan腳本是否有問題' >> /tmp/double_chk_port_scan.log         
                echo "" >> /tmp/double_chk_port_scan.log       
            fi
        fi
    else
        echo 1
        date >> /tmp/double_chk_port_scan.log
        echo '沒有檢查到 list_zabbix.sh 這個執行進程，請確定是否為port scan腳本是否有問題，是否沒有執行完中斷了' >> /tmp/double_chk_port_scan.log
        echo "" >> /tmp/double_chk_port_scan.log
    fi
else  
    echo 0
fi  
#-*- coding:utf-8 -*-
import requests
import json
import argparse
import re
import time
import os
from pprint import pprint
from urllib3.contrib import pyopenssl as reqs
from os import listdir
from os.path import isfile, isdir, join

#證書放置路徑
mypath = '/fikker_crt_add/crt'
#列出目錄下所有檔案
files = listdir(mypath)

#帶參數
parser = argparse.ArgumentParser(description='請帶 -i 參數在加上IP，前面參數為新的CDN IP，後面參數為該CDN的源站IP，範例:python -u "py檔案位置" -cdn 192.168.0.1 -src 192.168.0.2，192.168.0.3')
parser.add_argument('-src',dest='src_ip',metavar='src',help='src', required=True)
parser.add_argument('-cdn',dest='cdn_ip',metavar='cdn',help='cdn', required=False)
args = parser.parse_args()

#下載參數連線後的返回值
def url_get(aurl):
    r = requests.get(aurl)
    return r.text

#判斷是否為IP
def check_ip(cdn, src):
    compile_ip=re.compile('^(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|[1-9])\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)$')
    #判斷有沒有輸入cdn ip
    if cdn == "0":
        #只有源站執行以下動作
        if compile_ip.match(src):
            print('輸入src ip正確')
        else:
            print('輸入src ip格式有錯請重新輸入')
            exit()   
    else:         
        #有源站跟cdn執行以下動作       
        if compile_ip.match(cdn):
            print('輸入cdn ip正確')
            if compile_ip.match(src):
                print('輸入src ip正確')
                # 新增CDN主機
                port = "8058,8068,8086"
                port = port.split(",") 
                cdn_ip=[] 
                sr_ip=[]
                for line in port:
                    sr_ip = src+':'+line
                    sr_ip = [sr_ip]
                    cdn_ip = cdn+':'+line
                    cdn_ip = [cdn_ip]                   
                    time.sleep(3)             
                    addcdn(cdn_ip, sr_ip)
            else:
                print('輸入 srcip格式有錯請重新輸入')
                exit()
        else:
            print('輸入cdn ip格式有錯請重新輸入')
            exit()     

# 循環加CDN伺服器
def addcdn(cdn, src):
    cdn = cdn[0]
    src = src[0]
    url = 'http://fikker_ip/fikker/webcache.fik?'
    # 取得SessionID
    my_data = 'type=sign&cmd=in&Username=admin&Password=abb5678'
    all_url= url+my_data

    json_data = ""
    #r = requests.get(all_url)
    json_data = json.loads(url_get(all_url))
    # 看json原始格式內容
    #pprint(json_data)
    SID=json_data['SessionID']
    #print(SID)

    #会话保持激活(Keep-Alive)30分鐘
    # keep session
    my_data = 'type=sign&cmd=alive&SessionID=' + SID
    all_url = url + my_data
    json_data = json.loads(url_get(all_url))

    #0支持:HTTP, 2支持HTTP + HTTPS
    opt='0'
    url = 'http://fikker_ip/fikker/webcache.fik?type=proxy&cmd=add&'

    #新增cdn
    crt_data = {'Host':cdn,'SSLOpt':opt,'Balance':1,'SessionID':SID}
    #print(my_data)
    #執行post值
    crt = requests.post(url, data=crt_data)
    #傳值回來，判定是否成功
    crt_json_data = json.loads(crt.text)
    crt_retron=crt_json_data['Return']
    if 'True' == crt_retron:
        #新增cdn成功
        print('新增cdn成功:' + cdn)
        rv = crt_json_data['ProxyID']
        #新增源站
        url = 'http://fikker_ip/fikker/webcache.fik?type=upstream&cmd=add&'
        source_data = {'ProxyID':rv,'Host':src,'SSLOpt':opt,'SessionID':SID}
        source = requests.post(url, data=source_data)
        source_json_data = json.loads(source.text)
        source_retron=source_json_data['Return']       
        if 'True' == source_retron:
            #新增源站成功
            print('新增源站成功:' + src)
            print('------------------------------')        
        else:
            #新增源站失敗
            print('新增源站失敗')                
    else:
        #新增cdn失敗
        print('新增cdn失敗')

#轉換參數IP為陣列
def format_src_name(sr_ip):

    format_sr_ip = sr_ip.split(",")
    return format_sr_ip

def format_cdn_name(cdn_ip):

    format_cdn_ip = cdn_ip.split(",")
    return format_cdn_ip

#找出證書檔下有哪些域名
def crt_for_domain(crt, key):
    #add host
    fname = '/fikker_crt_add/crt/' + crt
    with open(fname) as f:
        cert_pem = f.read()
        f.close()  
    fname = '/fikker_crt_add/crt/' + key
    with open(fname) as f:
        cert_key = f.read()
        f.close()        
    x509 = reqs.OpenSSL.crypto.load_certificate(reqs.OpenSSL.crypto.FILETYPE_PEM,cert_pem)

    domain_list=reqs.get_subj_alt_name(x509)
    
    for i in range(len(domain_list)):
        #所有證書的域名
        hurl=domain_list[i]
        # #所有證書的域名    
        # print(hurl)
        # #所有證書名稱    
        # print(crt)    
        # #所有名稱
        # print(cert_pem)
        # print(cert_key)
       
        url = 'http://fikker_ip/fikker/webcache.fik?'
        # 取得SessionID
        my_data = 'type=sign&cmd=in&Username=admin&Password=admin'
        all_url= url+my_data

        json_data = ""
        #r = requests.get(all_url)
        json_data = json.loads(url_get(all_url))
        # 看json原始格式內容
        #pprint(json_data)
        SID=json_data['SessionID']
        #print(SID)

        #会话保持激活(Keep-Alive)30分鐘
        # keep session
        my_data = 'type=sign&cmd=alive&SessionID=' + SID
        all_url = url + my_data
        json_data = json.loads(url_get(all_url))

        #0支持:HTTP, 2支持HTTP + HTTPS
        opt='2'
        url = 'http://fikker_ip/fikker/webcache.fik?type=proxy&cmd=add&'
        
        #新增證書
        crt_data = {'Host':hurl,'SSLOpt':opt,'Balance':1,'SSLCrtContent':cert_pem,'SSLKeyContent':cert_key ,'SessionID':SID}
        #print(my_data)
        #執行post值
        crt = requests.post(url, data=crt_data)
        #傳值回來，判定是否成功
        crt_json_data = json.loads(crt.text)
        crt_retron=crt_json_data['Return']
        if 'True' == crt_retron:
            #新增證書成功
            print('新增證書成功:' + hurl )
            rv = crt_json_data['ProxyID']
            #新增源站
            url = 'http://fikker_ip/fikker/webcache.fik?type=upstream&cmd=add&'
            source_data = {'ProxyID':rv,'Host':src,'SSLOpt':opt,'SessionID':SID}
            source = requests.post(url, data=source_data)
            source_json_data = json.loads(source.text)
            source_retron=source_json_data['Return']       
            if 'True' == source_retron:
                #新增源站成功
                print('新增源站成功:' + src)
                print('------------------------------')
            else:
                #新增源站失敗
                print('新增源站失敗')                
        else:
            #新增證書失敗
            print('新增證書失敗')

if __name__ == "__main__":
    #判斷CDN IP    
    cdn = args.cdn_ip
    if cdn is None:
        print('若需新增cdn ip，請輸入-cdn參數')
        cdn = '0'
        format_cdn = format_cdn_name(cdn)
    else:
        format_cdn = format_cdn_name(cdn)
    #判斷源站ip
    src = args.src_ip
    format_src = format_src_name(src) 
    # 判斷是否為IP
    for v in range(len(format_cdn)):
        check_ip(format_cdn[v], format_src[0])

    #將所有檔案下的關鍵檔案轉成陣列
    #撈取目錄下關於crt檔的檔案
    crt = []
    for f in listdir(mypath): 
        if isfile(join(mypath,f)): 
            if os.path.splitext(f)[1] == '.crt':
                #將值丟給crt_for_domain去篩選該證書檔下有哪些域名
                crt.append(f)               

    #撈取目錄下關於crt檔的檔案
    key = []                    
    for f in listdir(mypath): 
        if isfile(join(mypath,f)):                 
            if os.path.splitext(f)[1] == '.key':    
                key += [f]
    #將陣列轉成一筆一筆字串塞入
    for x in range(len(crt)):            
        crt_for_domain(crt[x], key[x])        
                               














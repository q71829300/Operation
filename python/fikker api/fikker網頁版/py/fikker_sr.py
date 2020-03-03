import time
import os
import pop
import re
import argparse
import pyautogui
from os import listdir
from os.path import isfile, isdir, join
from selenium import webdriver
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By

#帶參數
parser = argparse.ArgumentParser(description='請帶 -i 參數在加上IP，前面參數為新的CDN IP，後面參數為該CDN的源站IP，範例:python -u "py檔案位置" -cdn 129.226.74.121 -src 129.226.74.120')
parser.add_argument('-src',dest='src_ip',metavar='src',help='src', required=True)
parser.add_argument('-cdn',dest='cdn_ip',metavar='cdn',help='cdn', required=False)
args = parser.parse_args()

# 指定要列出所有檔案的目錄
mypath = r"C:\Users\user\Desktop\fikker\source"

#轉換參數IP為陣列
def format_src_name(sr_ip):

    format_sr_ip = sr_ip.split(",")
    return format_sr_ip

def format_cdn_name(cdn_ip):

    format_cdn_ip = cdn_ip.split(",")
    return format_cdn_ip

# 用來填寫表單的function
def text_input(driver, idname, text):

    # 確認欄位id存在
    field = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.ID, idname))
    )
    # 清空並填入欄位
    field.clear()
    field.send_keys(text)

# 等 idname 按鈕出現時，按一下
def wait_then_idclick(driver, idname):

    # 確定按鈕存在
    element = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.ID, idname))
    )
    # 按一下
    element.click()

# 等 idname 按鈕出現時，按一下
def wait_then_xpclick(driver, xpathname):

    # 確定按鈕存在
    element = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, xpathname))
    )
    # 按一下
    element.click()

#判斷是否為IP
def check_ip(cdn, src):
    cdn = cdn[0]
    src = src[0]
    compile_ip=re.compile('^(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|[1-9])\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)$')
    if compile_ip.match(cdn):
        if compile_ip.match(src):
            print('輸入ip正確')
            port = "8058,8068"
            port = port.split(",")  
            sr_ip=[]
            for line in port:
                sr_ip = cdn+':'+line
                sr_ip = [sr_ip] 
                time.sleep(3)             
                opencrlsr(sr_ip, src)
        else:
            print('輸入ip格式有錯請重新輸入')
            exit()
    else:
        print('輸入ip格式有錯請重新輸入')
        exit()            

#判斷源站IP
def file_list_source():
    onlyfiles_source = [ f for f in listdir(mypath) if isfile(join(mypath,f)) if os.path.splitext(f)[1] == '.txt'  ]
    return(onlyfiles_source)  

# 循環加CDN伺服器
def opencrlsr(a, b):
    print(a)
    print(b)
    # #重複動作的地方
    # driver.switch_to.default_content()
    # driver.switch_to.frame("rMain")
    # driver.find_element_by_xpath("//tr[5]/td/img[1]").click()
    # time.sleep(0.1)
    # driver.switch_to.frame("host")
    # time.sleep(0.1)
    # driver.switch_to.frame("msgBOXURL")
    # text_input(driver, 'Host', a)
    # driver.find_element_by_xpath("//*[@id='proxyADDbutton']").click()
    # driver.switch_to.parent_frame()
    # driver.find_element_by_xpath("//*[@id='massage_box']/table/tbody/tr[1]/td[3]/a/span").click()
    # time.sleep(0.5)
    # pyautogui.hotkey('F5')
    # driver.switch_to.default_content()
    # time.sleep(0.5)
    # driver.switch_to.frame("rMain")      
    # time.sleep(0.5)
    # driver.switch_to.frame("host")  
    # time.sleep(0.5)          
    # js="var action=document.documentElement.scrollTop=50000"
    # driver.execute_script(js)
    # time.sleep(0.1)
    # pyautogui.click(572,932)     
    # driver.execute_script(js)   
    # pyautogui.click(733,933)
    # time.sleep(1)
    # driver.switch_to.frame("msgBOXURL")
    # time.sleep(1)
    # text_input(driver, 'Host', b)
    # time.sleep(1)
    # driver.find_element_by_xpath('//*[@id="SSLOpt_Http"]').click()
    # driver.find_element_by_xpath('//*[@id="upstreamADDbutton"]').click()
    # driver.switch_to.parent_frame()
    # driver.find_element_by_xpath('//*[@id="massage_box"]/table/tbody/tr[1]/td[3]/a/span').click() 
    # time.sleep(1)   
    # driver.execute_script(js) 
    # time.sleep(1)
    # pyautogui.click(600,747)
    # time.sleep(1)

if __name__ == "__main__":   
    # # 打開瀏覽器，並到登入的網址
    # driver = webdriver.Chrome("D:\chromedriver.exe")
    # driver.get("http://154.209.233.53:6780/fikker/")
    # # 填入帳號密碼，按確認
    # text_input(driver, 'PASS', 'abb5678')
    # wait_then_xpclick(driver, "//img[@src='image/Login.gif']")
    # wait_then_idclick(driver, 'TR10')
    # time.sleep(0.1)       
    # #server ip
    #判斷CDN IP
    cdn = args.cdn_ip
    format_cdn = format_cdn_name(cdn) 
    #判斷源站ip
    src = args.src_ip
    format_src = format_src_name(src) 
    # 判斷是否為IP
    check_ip(format_cdn, format_src)

# 1. webdriver: 就是瀏覽器的介面，可以操控瀏覽器
# 2. EC、WebDriverWait：我們可以用WebDriverWait等待EC的條件成立，才執行某些動作
# 3. By：寫條件的時候，用By來獲取網頁上的元素
import time
import os
import pop
import argparse
import pyautogui
from os import listdir
from os.path import isfile, isdir, join
from selenium import webdriver
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By


# 指定要列出所有檔案的目錄
mypath = r"C:\Users\user\Desktop\fikker"
mypath2 = r"C:\Users\user\Desktop\fikker\ip"
mypath5 = r"C:\Users\user\Desktop\fikker\source"
mypath6 = r"C:\Users\user\Desktop\fikker\domain"

# 取得所有檔案與子目錄名稱
files = listdir(mypath)

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

#確定要開啟的平台IP，及列出該平台的所有IP
def curl_ip(urlip):
    fullpath = join(mypath2, urlip)
    os.chdir(mypath2)
    f = open(urlip)
    lines = f.readlines()
    return lines

#列出資料夾下的所有檔案及檔案內容
def file_list_crt():
    onlyfiles_crt = [ f for f in listdir(mypath) if isfile(join(mypath,f)) if os.path.splitext(f)[1] == '.crt'  ]
    return(onlyfiles_crt)
       
def file_list_key():
    onlyfiles_key = [ f for f in listdir(mypath) if isfile(join(mypath,f)) if os.path.splitext(f)[1] == '.key'  ]
    return(onlyfiles_key)     

def file_list_source():
    onlyfiles_source = [ f for f in listdir(mypath5) if isfile(join(mypath5,f)) if os.path.splitext(f)[1] == '.txt'  ]
    return(onlyfiles_source)   

def file_list_domain():
    onlyfiles_domain = [ f for f in listdir(mypath6) if isfile(join(mypath6,f)) if os.path.splitext(f)[1] == '.txt'  ]
    return(onlyfiles_domain)  

# 循環加域名、證書、key
def opencrl(a, b, e):
    #源站IP
    j = file_list_source()        
    for p in range(len(j)):  
        os.chdir(mypath5)
        g = open(j[p],'r')
        h = []
        for line in g: 
            h.append(line)    
        # print("域名")
        # print(a)
        # print("證書")
        # print(b)
        # print("key")
        # print(e)

        #重複動作的地方
        driver.switch_to.default_content()
        driver.switch_to.frame("rMain")
        driver.find_element_by_xpath("//tr[5]/td/img[1]").click()
        time.sleep(0.1)
        driver.switch_to.frame("host")
        time.sleep(0.1)
        driver.switch_to.frame("msgBOXURL")
        text_input(driver, 'Host', a)
        driver.find_element_by_xpath("//*[@id='SSLOpt_HttpAndHttps']").click()
        text_input(driver, 'SSLCrtContent', b)
        text_input(driver, 'SSLKeyContent', e)
        driver.find_element_by_xpath("//*[@id='proxyADDbutton']").click()
        driver.switch_to.parent_frame()
        driver.find_element_by_xpath("//*[@id='massage_box']/table/tbody/tr[1]/td[3]/a/span").click()
        pyautogui.hotkey('F5')
        driver.switch_to.default_content()
        time.sleep(0.5)
        driver.switch_to.frame("rMain")      
        time.sleep(0.5)
        driver.switch_to.frame("host")  
        time.sleep(0.5)
        js="var action=document.documentElement.scrollTop=50000"
        driver.execute_script(js)
        time.sleep(0.5)
        pyautogui.click(572,932)     
        time.sleep(0.5)
        driver.execute_script(js)  
        time.sleep(0.5) 
        pyautogui.click(733,933)
        time.sleep(0.5)
        driver.switch_to.frame("msgBOXURL")
        time.sleep(0.5)
        text_input(driver, 'Host', h)
        driver.find_element_by_xpath('//*[@id="upstreamADDbutton"]').click()
        time.sleep(0.5)
        driver.switch_to.parent_frame()
        driver.find_element_by_xpath('//*[@id="massage_box"]/table/tbody/tr[1]/td[3]/a/span').click()   
        time.sleep(0.5) 
        driver.execute_script(js) 
        pyautogui.click(600,747)
        time.sleep(0.5)

            
if __name__ == "__main__": 
    # 打開瀏覽器，並到登入的網址
    driver = webdriver.Chrome("D:\chromedriver.exe")
    driver.get("http://154.209.233.53:6780/fikker/")
    # 填入帳號密碼，按確認
    text_input(driver, 'PASS', 'abb5678')
    wait_then_xpclick(driver, "//img[@src='image/Login.gif']")
    wait_then_idclick(driver, 'TR10')
    time.sleep(0.1)
    c = file_list_crt()
    for x in range(len(c)):
        #證書
        os.chdir(mypath)
        t = open(c[x],'r')
        b = []
        for line in t: 
            b.append(line)
        #key
        d = file_list_key()
        for q in range(len(d)):  
            os.chdir(mypath)
            r = open(d[q],'r')
            e = []
            for line in r: 
                e.append(line) 
        #域名
        domain = file_list_domain()
        for do in range(len(domain)):  
            os.chdir(mypath6)
            dom = open(domain[do],'r')
            for line in dom:                 
                a = [line]                  
                opencrl(a, b, e)   

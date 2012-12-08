## 浏览器检测
* 特征检测
* navigator.userAgent
## userAgent

firefox 3.6.28
Mozilla/5.0 (Windows; U; Windows NT 6.1; zh-CN; rv:1.9.2.28) Gecko/20120306 Firefox/3.6.28

chrome 25.0.1349.2 dev-m
Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.21 (KHTML, like Gecko) Chrome/25.0.1349.2 Safari/537.21

ie 9
Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; InfoPath.3; .NET4.0C; .NET4.0E; BOIE9;ZHCN)

/(mozilla)(?:.*? rv:([\w.]))/

/(webkit)[ \/]([\w.]+)/

//msie 空格 点
/(msie) ([\w.]+)/
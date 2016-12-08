# openresty-china-study
##  注明：此项目主要作为openresty练手项目，源码中留下很多中文注释。 lor版本当前最新；
   
##  先感谢饭总勤劳付出，原地址https://github.com/sumory/openresty-china
 
 
####登陆验证的session方式改为cookie具体步骤；
```
      1. 完善cookie基本方法
          在/lor/lib/middleware/cookie.lua文件  补充set() get() get_all() 等方法 
          
      2. restry-cookie 的代码改动
          在/resty/cookie.lua文件 cookie的值中间不能有空格 这个issue作者已解释 注释72 、73行 
      
      3. 避免明文cookie
           在/kfd/app/libs/utils.lua文件 增加encrypted()方法 decrypted()方法 用作加密 解密 目的是为了避免明文cookie
         
      4. 使用时注意 加密解密
          在/kfd/app/middleware/check_login.lua文件 获取cookie时  注意解密就好了
          在/kfd/app/routes/auth.lua文件           设置cookie时记得加密
```




####传上来的目的只是为了方便学习笔记同步，当做svn git等版本控制使用；



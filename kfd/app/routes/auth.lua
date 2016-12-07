local pairs = pairs
local ipairs = ipairs
local smatch = string.match 
 
 
local cjson = require("cjson")
local utils = require("app.libs.utils")
local pwd_secret = require("app.config.config").pwd_secret
local lor = require("lor.index")
local user_model = require("app.model.user")
local auth_router = lor:Router()
 
--[[
- @desc  测试cookie与session页面     
- @param  path            string   路径
- @param  fn             function  匿名函数 
- return  json
--]]
auth_router:get("/test", function(req, res, next) 
        debug(req.cookie.get_all()); 
 
       local ok, err = req.cookie.set({
		    key = "qq",
		    value =  '4==||==hello zhang==||==123456',
		    path = "/",
		    domain = "new.cn",
		    secure = false, --设置后浏览器只有访问https才会把cookie带过来,否则浏览器请求时不带cookie参数
		    httponly = true, --设置后js 无法读取
		     --expires =  ngx.cookie_time(os.time() + 3600),
		    max_age = 3600, --用秒来设置cookie的生存期。
		    samesite = "Strict",  --或者 Lax 指a域名下收到的cookie 不能通过b域名的表单带过来
		    extension = "a4334aebaece"  --设置好像没起什么作用 
		})
	
        return res:json({success = false,msg = "用户名长度应为4~50位."})
end)

--登陆
auth_router:get("/login", function(req, res, next) 
    return res:render("login")
end)

--注册
auth_router:get("/sign_up", function(req, res, next) 
    return res:render("sign_up")
end)

--处理注册
auth_router:post("/sign_up", function(req, res, next)
    local username = req.body.username 
    local password = req.body.password

    local pattern = "^[a-zA-Z][0-9a-zA-Z_]+$"
    local match, err = smatch(username, pattern)

    if not username or not password or username == "" or password == "" then
        return res:json({
            success = false,
            msg = "用户名和密码不得为空."
        })
    end

    local username_len = string.len(username)
    local password_len = string.len(password)

    if username_len<4 or username_len>50 then
        return res:json({
            success = false,
            msg = "用户名长度应为4~50位."
        })
    end
    
    if password_len<6 or password_len>50 then
        return res:json({
            success = false,
            msg = "密码长度应为6~50位."
        })
    end

    if not match then
       return res:json({
            success = false,
            msg = "用户名只能输入字母、下划线、数字，必须以字母开头."
        })
    end

    local result, err = user_model:query_by_username(username)
    local isExist = false
    if result and not err then
        isExist = true
    end

    if isExist == true then
        return res:json({
            success = false,
            msg = "用户名已被占用，请修改."
        })
    else
        password = utils.encode(password .. "#" .. pwd_secret)
        local avatar = string.sub(username, 1, 1) .. ".png" --取首字母作为默认头像名
        avatar = string.lower(avatar)
        local result, err = user_model:new(username, password, avatar)
        if result and not err then
            return res:json({
                success = true,
                msg = "注册成功."
            })  
        else
            return res:json({
                success = false,
                msg = "注册失败."
            }) 
        end
    end
end)

auth_router:post("/login", function(req, res, next)
    local username = req.body.username 
    local password = req.body.password

    if not username or not password or username == "" or password == "" then
        return res:json({
            success = false,
            msg = "用户名和密码不得为空."
        })
    end

    local isExist = false --用户是否存在
    local userid = 0  --用户uid

    password = utils.encode(password .. "#" .. pwd_secret)
    local result, err = user_model:query(username, password)

    local user = {}
    if result and not err then
        if result and #result == 1 then
            isExist = true
            user = result[1] 
            userid = user.id
        end
    else
        isExist = false
    end

    if isExist == true then 
      
         local ok, err = req.cookie.set({
		    key = "user",
		    value =  utils.encrypted(userid..'--||'.. username ..'--||'.. (user.create_time or ""), pwd_secret),
		    path = "/",
		    --domain = "new.cn",
		    secure = false, --设置后浏览器只有访问https才会把cookie带过来,否则浏览器请求时不带cookie参数
		    httponly = true, --设置后js 无法读取
		     --expires =  ngx.cookie_time(os.time() + 3600),
		    max_age = 86400, --用秒来设置cookie的生存期。
		    samesite = "Strict",  --或者 Lax 指a域名下收到的cookie 不能通过b域名的表单带过来
		    extension = "a4334aeba444e22222222ce"  --设置好像没起什么作用 
		}) 
        return res:json({success = true,msg = "登录成功."})
   
    else
        return res:json({success = false,msg = "用户名或密码错误，请检查!"})
    end
end)


auth_router:get("/logout", function(req, res, next)
    res.locals.login = false
    res.locals.username = ""
    res.locals.userid = 0
    res.locals.create_time = ""
    req.session.destroy()
    res:redirect("/index")
end)


return auth_router


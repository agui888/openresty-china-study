local error = error
local pairs = pairs
local type = type
local setmetatable = setmetatable
local tostring = tostring


local _M = {}

--[[
- @desc   包装 application.lua对象
- @param  function   create_app   匿名函数 
- @param  table    Router   Router类table 
- @param  table    Route    Route类table 
- @param  table   Request   Request类table 
- @param  table   Response  Response类table 
- return  table
--]]
function _M:new(create_app, Router, Route, Request, Response)
    local instance = {}
    instance.router = Router
    instance.route = Route
    instance.request = Request
    instance.response = Response
    instance.fn = create_app  --lor.lua 中的函数
    instance.app = nil
    
    --ngx.say('wrap.lua-->new()--- 1 ');
    
    setmetatable(instance, {
        __index = self,           -- 将_M 变为 instance的父类
        __call = self.create_app  --把table当成函数一样调用 instance() ==> create_app()
    })

    return instance
end

-- 通常,这只用于“ `lor` framework 它自身.
function _M:create_app(options) 
    self.app = self.fn(options)  -- 等同于createApplication()方法
    return self.app
end

function _M:Router(options) 
    --ngx.say('wrap.lua-->Router()----------------------------------------------------------------------组合开始 ');

    options = options or {}
    options.group_router = true
    return self.router:new(options)
end

function _M:Route(path)
    return self.route:new(path)
end

function _M:Request()
    return self.request:new()
end

function _M:Response()
    return self.response:new()
end


return _M
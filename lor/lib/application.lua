local pairs = pairs
local ipairs = ipairs
local type = type
local setmetatable = setmetatable

local Router = require("lor.lib.router.router")
local Request = require("lor.lib.request")
local Response = require("lor.lib.response")
local View = require("lor.lib.view")
local supported_http_methods = require("lor.lib.methods")
local debug = require("lor.lib.debug")


local App = {}

--[[
- @desc   执行
- @param  void   void   void 
- return  table
--]]
function App:new()
    local instance = {}
    instance.cache = {}
    instance.settings = {}
    instance.router = Router:new({})

    setmetatable(instance, {
        __index = self,      -- 将App 变为 instance的父类  
        __call = self.handle  --把table当成函数一样调用 instance() ==> App:handle()
    })
 
    instance:init_method() -- 初始化 给自身新增更多的方法
    return instance
end

--[[
- @desc   执行
- @param  string   path   路径 
- return  void
--]]
function App:run(final_handler)
    local request = Request:new()
    local response = Response:new()

    local enable_view = self:getconf("view enable") --是否开启视图
    if enable_view then
        local view_config = {
            view_enable = enable_view,
            view_engine = self:getconf("view engine"), -- view engine: resty-template or others...
            view_ext = self:getconf("view ext"), -- defautl is "html"
            views = self:getconf("views") -- template files directory
        }

        local view = View:new(view_config)
        response.view = view
    end
 
    self:handle(request, response, final_handler)
end

function App:init(options)
    self:default_configuration(options)
end

function App:default_configuration(options)
    options = options or {}
    
    -- view and template configuration
    if options["view enable"] ~= nil and options["view enable"] == true then
        self:conf("view enable", true)
    else
        self:conf("view enable", false)
    end
    self:conf("view engine", options["view engine"] or "tmpl")
    self:conf("view ext", options["view ext"] or "html")
    self:conf("views", options["views"] or "./app/views/")

    self.locals = {}
    self.locals.settings = self.setttings
end

-- 分派 `req, res` 融于  pipeline.
function App:handle(req, res, callback) 
    local router = self.router
    local done = callback or function(req, res)
        return function(err)
            if err then
                res:status(500):send("unknown error.")
            end
        end
    end

    if not router then
       return done() 
    end

    router:handle(req, res, done)
end

--[[
- @desc   注册中间件
- @param  string   path   路径 
- @param  function   fn   匿名函数 
- return  void
--]]
function App:use(path, fn) 
    self:inner_use(3, path, fn)
end

--[[
- @desc   注册错误中间件
- @param  string   path   路径 
- @param  function   fn   匿名函数 
- return  void
--]]
function App:erroruse(path, fn) 
    self:inner_use(4, path, fn)
end
 
--[[
- @desc   注册
- @param  int   fn_args_length  参数个数
- @param  string   path   路径 
- @param  function   fn   匿名函数 
- return  table
--]]
function App:inner_use(fn_args_length, path, fn)
    local router = self.router
    if path and fn and type(path) == "string" then 
        router:use(path, fn, fn_args_length)  -- 当这种形式调用app:use("/auth", auth_router())
    elseif path and not fn then  
        fn = path 
        path = "/" 
        router:use(path, fn, fn_args_length)  -- 当这种形式调用app:use(function(){....})
    else
        -- 错误使用
    end 
    return self
end

--[[
    初始化 给自身新增更多的方法
      get = true, -- work well
	  post = true, -- work well
	  head = true, -- no test
	  options = true, -- no test
	  put = true, -- work well
	  patch = true, -- no test
	  delete = true, -- work well
	  trace = true, -- no test
	  all = true -- todo:
--]]
function App:init_method()
    for http_method, _ in pairs(supported_http_methods) do
        self[http_method] =  
               function(self, path, fn) 
		            local route = self.router:app_route(path)
		            route[http_method](route, fn) -- like route:get(fn) 
		            return self
		        end
    end
end

function App:all(path, fn)
    local route = self.router:app_route(path) 
    for http_method, _ in pairs(supported_http_methods) do
        route[http_method](route, fn)
    end

    return self
end

--设置配置
function App:conf(setting, val)
    self.settings[setting] = val
    return self
end

--获取配置
function App:getconf(setting)
    return self.settings[setting]
end

--将某项配置开启
function App:enable(setting)
    self.settings[setting] = true
    return self
end

--将某项配置关闭
function App:disable(setting)
    self.settings[setting] = false
    return self
end
 
return App

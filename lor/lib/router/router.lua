local pairs = pairs
local ipairs = ipairs
local type = type
local setmetatable = setmetatable
local getmetatable = getmetatable

local utils = require("lor.lib.utils.utils")
local is_table_empty = utils.is_table_empty
local random = utils.random
local mixin = utils.mixin

local supported_http_methods = require("lor.lib.methods")
local Route = require("lor.lib.router.route")
local Layer = require("lor.lib.router.layer")
local debug = require("lor.lib.debug")


local function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_object = {}
        lookup_table[object] = new_object
        for key, value in pairs(object) do
            new_object[_copy(key)] = _copy(value)
        end
        return setmetatable(new_object, getmetatable(object))
    end
    return _copy(object)
end

local function layer_match(layer, path)
       return layer:match(path) 
end

local function merge_params(params, parent)
    local obj = mixin({}, parent)
    local result =  mixin(obj, params)
    return result
end

local function restore(fn, obj)
    local origin = {
        path = obj['path'],
        query = obj['query'],
        next = obj['next'],
        locals = obj['locals'],
        -- params = obj['params']
    }

    return function(err)
        obj['path'] = origin.path
        obj['query'] = origin.query
        obj['next'] = origin.next
        obj['locals'] = origin.locals
        -- obj['params'] = origin.params -- maybe overrided by layer.params, so no need to keep
        fn(err)
    end
end


local Router = {}

--[[
- @desc   Router类实例  
- @param  table   options 配置   {is_end = false,is_start = true} 
- return  table   返回一个新table  并将Router类设为新table的元方法  
--]]
function Router:new(options)
    local opts = options or {}
    local router = {} 
    router.name =  "origin-router-" .. random(); --产生一个随机数
    router.group_router = opts.group_router -- is a group router
    router.stack = {} -- layer array  

    self:init()   
    setmetatable(router, {
        __index = self,
        __call = self._call,  --把table当成函数一样调用 router() ==> router._call()
        __tostring = function(s)
            local ok, result = pcall(function()
                return "(name:" .. s.name .. "\tstack_length:" .. #s.stack .. ")"
            end)
            if ok then
                return result
            else
                return "router.tostring() error"
            end
        end
    })

    --debug("router.lua#new:", router)
    return router
end



-- a magick for usage like `lor:Router()`, 为不同的路线组生成一个新的路由器
function Router:_call()
    local new_router = clone(self)
    new_router.name = self.name .. ":group-router-" .. random()
    return new_router
end

-- a magick to convert `router()` to `router:handle()`
-- so a router() could be regarded as a `middleware`
function Router:call()
    return function(req, res, next)
        return self:handle(req, res, next)
    end
end 
 
 
-- 分发请求
function Router:handle(req, res, out) 
    local idx = 1
    local stack = self.stack;   ---返回table 所有的路由规则
    local done = restore(out, req);  --返回一个函数
 
      local function next(err)
		        local layer_error = err 
		        if idx > #stack then
		          return  done(layer_error)   --没有加任何规则 退出500 error 
		        end
		
		        local path = req.path
		        if not path then
		          return  done(layer_error)  --没有请求路径 则退出500 error 
		        end
		 
		        local layer, match, route
		        while (not match and idx <= #stack) do 
		            layer = stack[idx];
		            idx = idx + 1;       
		            match = layer_match(layer, path); -- true or false  
		            route = layer.route;  -- 空 或 table 
		            
		            if not match then
		                --继续     请求的路径  在本地没有注册过
		            else
		                if not route then    
		                    --继续   一般都是空
		                else
		                    if layer_error then   --执行next函数是是否有参数  一般都没有
		                        match = false 
		                    else  
		                        local has_method = route:_handles_method(req.method)  --当前请求方法get/post 处理规则 
		                        if not has_method then
		                            match = false   -- 继续  
		                        end
		                    end
		                end
		            end
		        end
		
		        if not match then 
		           return done(layer_error) 
		        end
		 
		        if route then -- 存储路径
		            req.route = route
		            req:set_found(true) -- 表明这个请求不是404的。
		        end
		 
		        if match then  --请求参数合并
		            local merged_params = merge_params(layer.params, req.params)  --相当于php中的array_merge
		            if merged_params and ( not is_table_empty(merged_params)) then
		                req.params = merged_params
		            end
		        end 
		
		        if route then  --执行控制器中的方法
		            layer:handle_request(req, res, next)
		        end
		 
		        if layer_error then 
		            layer:handle_error(layer_error, req, res, next)
		        elseif route then 
		            next()
		        else 
		            layer:handle_request(req, res, next)
		        end 
        end 
 
    req.next = next 
    next()
end
 
--[[
- @desc   新增路由    {is_end = false,is_start = true}
- @param  path            string   路径
- @param  fn             function  匿名函数
- @param  fn_args_length   int     3/4
- return  table
--]]
function Router:use(path, fn, fn_args_length)
    local layer
    if type(fn) == "function" then  
        layer = Layer:new(path, {is_end = false,is_start = true}, fn, fn_args_length)
    else   
        layer = Layer:new(path, {is_end = false,is_start = true}, fn.call(fn), fn_args_length)

        local group_router_stack = fn.stack
        if group_router_stack and not fn.is_repatterned then
            fn.is_repatterned = true 
            for i, v in ipairs(group_router_stack) do
                v.pattern = utils.clear_slash("^/" .. path .. v.pattern)
            end
        end 
    end

    table.insert(self.stack, layer) 
    return self
end
 
--[[
- @desc   新增路由 {is_end = true, is_start = true}
- @param  path            string   路径 
- return  table
--]]
function Router:app_route(path) 
    local route = Route:new(path)
    local layer = Layer:new(path, {is_end = true, is_start = true}, route, 3) 
    layer.route = route 
    table.insert(self.stack, layer) 
    return route
end

--[[
- @desc   新增路由  {is_end = true, is_start = false}
- @param  path            string   路径 
- return  table
--]]
function Router:route(path)
    local route = Route:new(path)
    local layer = Layer:new(path, {is_end = true,is_start = false}, route, 3)
    layer.route = route 
    table.insert(self.stack, layer) 
    return route
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
function Router:init()
    for http_method, _ in pairs(supported_http_methods) do
        self[http_method] = function(s, path, fn)
            local route = s:route(path)
            -- 参数应该明确指定为route，不得省略，否则group_router.test.lua使用lor:Router()语法时无法传递route
            route[http_method](route, fn)
            return s
        end
    end
end


return Router
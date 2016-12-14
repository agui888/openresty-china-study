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
- @desc   过滤处理中间件 
- @param  req            table    请求对象
- @param  res            table    响应对象
- @param  out            function  匿名函数 
- return  table
--]]
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
		 
		        local layerObj, match, route
		        while (not match and idx <= #stack) do 
		            layerObj = stack[idx];
		            idx = idx + 1;
		            match = layer_match(layerObj, path); -- true or false  
		            route = layerObj.route;  -- 空 或 table 
		            
		            if not match then
		                --继续     请求的路径  在本地没有注册过
		            else
		                if not route then    
		                    --继续  
		                else
		                    if layer_error then   --执行next函数是是否有参数  一般都没有
		                        match = false 
		                    else  
		                        local has_method = route:_handles_method(req.method)  --当前这个http请求方式本地是否有注入过 
		                        if not has_method then
		                            match = false   -- 如果没有注册    标记为没有找到合适的中间件
		                        end
		                    end
		                end
		            end
		        end
		         
		        if not match then  --没有找到合适的中间件
		           return done(layer_error) 
		        end
		 
		        if route then --如果是组的形式发过来的请求
		            req.route = route
		            req:set_found(true) -- 表明这个请求不是404的。
		        end
		 
		        if match then  --请求参数合并
		            local merged_params = merge_params(layerObj.params, req.params)  --相当于php中的array_merge
		            if merged_params and ( not is_table_empty(merged_params)) then
		                req.params = merged_params
		            end
		        end 
		
		        if route then  --执行控制器中的方法
		            layerObj:handle_request(req, res, next)
		        end
		 
		        if layer_error then 
		            layerObj:handle_error(layer_error, req, res, next)
		        elseif route then 
		            next()
		        else 
		            --不是组 当个形式中间件 发过来的请求
		            layerObj:handle_request(req, res, next)
		        end 
        end 
 
    req.next = next 
    next()
end


--[[
- @desc   Router类实例  
- @param  table   options 配置   {is_end = false,is_start = true} 
- return  table   返回一个新table  并将Router类设为新table的元方法  
--]]
function Router:new(options) 
    --ngx.say('router.lua-->new()----Router-table被实例化--4'); 
    local opts = options or {}
    local router = {} 
    router.name =  "origin-router-" .. random(); --产生一个随机数
    router.group_router = opts.group_router -- 是否是一组路由 比如在auth.lua下面的所有算作一组
    router.stack = {} -- layer array  
  
    self:init();
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
 
    return router
end
 
--[[   
- @desc   克隆一个对象,不同的路游组(router实例)不被其他路由污染
- @param  void     void   void
- return  table
--]] 
function Router:_call()
    local new_router = clone(self) 
          new_router.name = self.name .. ":group-router-" .. random();  
            --ngx.say(' ******************************************'.. new_router.name ..'******************** '); 
          return new_router
end


--[[
- @desc   新增路由组时 “组”也是一个中间件 用来做Layer:new的第三个参数
- @param  void     void   void
- return  function
--]] 
function Router:call()   
    return function(req, res, next)
          --ngx.say('router.lua---call---------------匹配到组名时---不执行-继续回调进入下一层--注意这里的self变了-------------111'); 
         return self:handle(req, res, next) 
    end
end 

--[[
    初始化 给自身新增更多的方法
      get = function(s, path, fn)
	            local route = s:route(path)
	            route[http_method](route, fn)
	            return s
            end, 
            
	  post = fn, -- work well
	  head = fn, -- no test
	  options = fn, -- no test
	  put = fn, -- work well
	  patch = fn, -- no test
	  delete = fn, -- work well
	  trace = fn, -- no test
	  all = fn -- todo:
--]]
function Router:init()
     --ngx.say('router.lua-->init()---router里面新增了get/post/head/put/delete方法并赋值匿名函数--5');
     
    for http_method, _ in pairs(supported_http_methods) do 
        self[http_method] = function(s, path, fn)
              --ngx.say('router.lua---Router中的'.. http_method ..'方法被调用-------------------------------'..path..'----14');
             
               local route = s:app_route(path, {is_end = true,is_start = false}, http_method)   
               route[http_method](route, fn)  
               return s
            end
    end
end

--[[
- @desc   新增路由组   
- @param  path            string   路径 
- @param  options         table     {is_end = true, is_start = false}
- @param  http_method     string   post/get/put... 
- return  table
--]]
function Router:app_route(path, options, http_method) 
    --ngx.say('router.lua---用来实例化Route类，并将route.dispatch方法作为Layer:new函数的参数----15');
    
    local route = Route:new(path, http_method)
    local layer = Layer:new(path, options, route, 3) 
          layer.route = route 
    table.insert(self.stack, layer)
    
    --ngx.say('route.lua-->app_route函数 将new layer的结果插入router.stack属性中-----同第15步骤-------18');
    return route
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
         --ngx.say('router.lua-->use(几个参数'.. path ..')--新增路由-10');
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
        
        --ngx.say('router.lua-->use(几个参数)--新增路由"组"------++++++++++++-----10'); 
    end

    table.insert(self.stack, layer);
    --ngx.say('router.lua-->use(...)方法---将new layer的结果插入router.stack属性中----13.1');
    return self
end
 
return Router
local pcall = pcall
local xpcall = xpcall
local traceback = debug.traceback
local pairs = pairs
local ipairs = ipairs
local type = type
local setmetatable = setmetatable
local ostime = os.time
local pathRegexp = require("lor.lib.utils.path_to_regexp")
local utils = require("lor.lib.utils.utils")
local random = utils.random
local debug = require("lor.lib.debug")

math.randomseed(ostime())


local Layer = {}
 
--[[
- @desc   初始化每个中间件将其封装为独立table
- @param  string   path   路径
- @param  table   options 配置   {is_end = false在path尾部加反斜线 true在尾部加$, is_start = true在path开头加^ false不管}
- @param  function  fn    匿名函数 
- @param  int    fn_args_length   匿名函数的参数个数 
- return  table
--]]
function Layer:new(path, options, fn, fn_args_length)

--ngx.say('Layer.lua---调用Layer:new()---Layer被实例化---11'); 

    local opts = options or {}
    local instance = {}
    instance.handle = fn
    instance.name = "layer-" .. random()
    instance.params = {}
    instance.path = path
    instance.keys = {}
    instance.length = fn_args_length -- todo:shoule only be 3 or 4
    instance.is_end = opts.is_end or false 
    instance.is_start = opts.is_start or false  

    local tmp_pattern = pathRegexp.parse_pattern(path, instance.keys, opts)
  
    if tmp_pattern == "" or not tmp_pattern then
        instance.pattern = "/"
    else
        instance.pattern = tmp_pattern
    end
	 
    if instance.is_end then
        instance.pattern = instance.pattern .. "$"
    else
        instance.pattern = pathRegexp.clear_slash(instance.pattern .. "/")
    end

    if instance.is_start then
        instance.pattern = "^" .. pathRegexp.clear_slash("/" .. instance.pattern)
    else
        instance.pattern =  instance.pattern
    end
    
  --ngx.say('-----------------'..instance.pattern .. '----------------13');
  -------注释-------
    if (instance.keys) and #(instance.keys)>0 then 
       -- debug(instance); 
      --   --ngx.say('------'..(instance.keys)[1] .. '----------------13');
     end
   ----------------  
   
    setmetatable(instance, {
        __index = self,
        __tostring = function(s)
            local ok, result = pcall(function()
                local route_name, is_end = "<nil>", ""
                if s.route then
                    route_name = s.route.name
                end

                if s.is_end then
                    is_end = "true"
                else
                    is_end = "false"
                end

                return "(name:" .. s.name .. "\tpath:" .. s.path .. "\tlength:" .. s.length ..
                        "\t layer.route.name:" .. route_name ..
                        "\tpattern:" .. s.pattern .."\tis_end:" .. is_end .. ")"
            end)

            if ok then
                return result
            else
                return "layer.tostring() error"
            end
        end
    }) 
    return instance
end

function Layer:handle_error(err, req, res, next) 
    local fn = self.handle
 
    if self.length ~= 4 then 
        next(err)
        return
    end

    local e
    local ok = xpcall(function() 
        fn(err, req, res, next) 
    end,  function()
        e = (err or "") .. "\n" .. traceback()
    end)
 
    if not ok then
        next(e)
    end
end


--[[  最终执行
- @desc    执行控制中的方法  
- @param  table   req   请求table 
- @param  table   res   响应table
- @param  function   next  函数
- return  返回true or false
--]]
function Layer:handle_request(req, res, next)  
    local fn = self.handle
 --ngx.say('有'.. (self.length) ..'个参数的执行这里,name--->' ..(self.name).."--------最终执行函数被执行");
    if self.length > 3 then  
       return next(); 
    end
  
    local e;
    local ok, ee = xpcall(function()  
			          return fn(req, res, next); 
			       end,
				   function(msg)
					 e = (msg or "") .. "\n" .. traceback()
				   end); 
    if not ok then
        return  next(e or ee)
    end 
end

--[[
- @desc   对一个路由规则 进行匹配
- @param  string   path   路径 
- return  返回true or false
--]]
function Layer:match(path)
    --debug("layer.lua#match before:", "path:", path, "layer:", self)
    if not path then
        self.params = nil 
        return false
    end

    if self.is_end then
        path = pathRegexp.clear_slash(path)
    else
        path = pathRegexp.clear_slash(path .. "/")
    end
    
   
    --req.path 与 所有已经注册的路径((( /([A-Za-z0-9._-]+) )))做对比
    local match_or_not = pathRegexp.is_match(path, self.pattern)
    if not match_or_not then 
        return false
    end

    local m = pathRegexp.parse_path(path, self.pattern, self.keys)
   --ngx.say('--------------------path: '.. path ..'---------pattern:' .. self.pattern..'---------------');
    self.params = m  -- fixbug:参数个数不应转移到下一个请求。
    return true
end


return Layer

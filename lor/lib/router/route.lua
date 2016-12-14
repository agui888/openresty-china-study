local tinsert = table.insert
local utils = require("lor.lib.utils.utils")
local random = utils.random
local slower = string.lower
local pairs = pairs
local ipairs = ipairs
local type = type
local setmetatable = setmetatable

local supported_http_methods = require("lor.lib.methods")
local Layer = require("lor.lib.router.layer")
local debug = require("lor.lib.debug")


local Route = {}

--[[
- @desc   Route类实例  
- @param  table   path 配置    
- return  table   返回一个新table  并将Route类设为新table的元方法  
--]]
function Route:new(path, http_method)

  --ngx.say('route.lua---调用route:new()---route被实例化---16');

    local instance = {}
    instance.path = path
    instance.stack = {}
    instance.methods = {}
    instance.name = "route-" .. random()

    setmetatable(instance, {
        __index = self, 
        __call = self.dispatch, -- important: a magick to supply `route:dispatch`
        __tostring = function(s)
            local ok, result = pcall(function()
                return "(name:" .. s.name .. "\tpath:" .. s.path .. "\tstack_length:" .. #s.stack .. ")"
            end)
            
            if ok then
                return result;
            else
                return "route.tostring() error";
            end
        end
    })
      
    instance:initMethod(http_method);
 
    return instance;
end


function Route:initMethod(http_method)
     --ngx.say('Route.lua-->init()---注意是route里面新增'..http_method .. '方法并赋值匿名函数--17')
     if http_method and http_method ~= "" then
	        self[http_method] = function(self, fn)
	        
	            local layer = Layer:new("/", {is_end = true}, fn, 3);
	                 layer.method = http_method;
	            self.methods[http_method] = true;    --route里的methods属性是一个table 并有对应的get post 等
	            tinsert(self.stack, layer);   ---- route里的stack
	           
	            --ngx.say('route.lua-->'.. http_method ..'函数被调用将实例化layer的结果插入到-route.stack----self是route本身----------19'); 
	        end 
     end 
end

--[[
- @desc   判断这个http请求方式本地是否有注入过
- @param  string   method   http请求方式 
- return  返回true or false
--]]
function Route:_handles_method(method)
     --允许在控制器里 写 _all方法
    if self.methods._all then
        return true        
    end

    local name = slower(method)

    if self.methods[name] then
        return true
    else
        return false
    end
end

function Route:dispatch(req, res, done)
    local idx = 0
    local stack = self.stack
    if #stack == 0 then
      return  done("empty route stack") 
    end

    local method = slower(req.method)
    req.route = self

    local function next(err) 
        if err then
           return done(err) 
        end

        idx = idx + 1
        local layer = stack[idx]
        if not layer then
          return done(err) 
        end

        if layer.method and layer.method ~= method then
           return next(err) 
        end

        if err then
            layer:handle_error(err, req, res, next)
        else
             --ngx.say('+++++++++++++++组的处理--------');
            layer:handle_request(req, res, next)
        end
    end

    next()
end



function Route:all(fn)
    local layer = Layer:new("/", {}, fn, 3)
    layer.method = nil

    self.methods._all = true
    tinsert(self.stack, layer)

    return self
end


return Route
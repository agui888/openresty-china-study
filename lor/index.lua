local type = type

local version = require("lor.version")
local Route = require("lor.lib.router.route")
local Router = require("lor.lib.router.router")
local Request = require("lor.lib.request")
local Response = require("lor.lib.response")
local Application = require("lor.lib.application")
local Wrap = require("lor.lib.wrap")

LOR_FRAMEWORK_DEBUG = false


--[[
- @desc   返回application对象实例
- @param  options   table   {debug = false} 
- return  table
--]]
local createApplication = function(options)
    if options and options.debug and type(options.debug) == 'boolean' then
        LOR_FRAMEWORK_DEBUG = options.debug
    end
    
    --ngx.say('index.lua--把lor当做方法调用执行---createApplication()-2');  
    
    local app = Application:new()
    app:init(options) 
     
    return app
end

local lor = Wrap:new(createApplication, Router, Route, Request, Response)
lor.version = version

return lor

local xpcall = xpcall 
local ngx_time = ngx.time
local Session = require("resty.session")

 
local session_middleware = function(config)
    config = config or {}
    if config.refresh_cookie ~= false then
        config.refresh_cookie = true
    end

    if not config.timeout or type(config.timeout) ~= "number" then
        config.timeout = 3600 -- default session timeout is 3600 seconds
    end

    if not config.secret then
        config.secret = "7su3k78hjqw90fvj480fsdi934j7ery3n59ljf295d"
    end

    return function(req, res, next) 
        req.session = {
            set = function(key, value)
                local s = Session:open({
                    secret = config.secret
                })

                s.data[key] = value

                s.cookie.persistent = true
                s.cookie.lifetime = config.timeout
                s.expires = ngx_time() + config.timeout
                s:save()
            end,
            
            update = function() 
                local s = Session:start({ 
                    secret = config.secret
                })

                s.cookie.persistent = true
                s.expires = ngx_time() + config.timeout
                s.cookie.lifetime = config.timeout
                s:save() 
            end,
            
            get = function(key)
                local s = Session:open({
                    secret = config.secret
                })

                s.cookie.persistent = true
                s.cookie.lifetime = config.timeout
                s.expires = ngx_time() + config.timeout
                return s.data[key]
            end,

            destroy = function()
                local s = Session.start({
                    secret = config.secret
                })
                s:destroy()
            end
        }
 
        local e, ok
        ok = xpcall(function() 
            if config and config.refresh_cookie == true then
                req.session.update()
            end
        end, function()
            --e = debug.traceback()
            error_handler.fatal(err);
        end)

        if not ok then
            ngx.log(ngx.ERR, "[session middleware]refresh cookie error, ", e)
        end

        next()
    end
end

return session_middleware

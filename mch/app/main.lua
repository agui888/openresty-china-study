	local lor = require("lor.index")
	local session_middleware = require("lor.lib.middleware.session")
	local check_login_middleware = require("app.middleware.check_login")
	local whitelist = require("app.config.config").whitelist
	 
	
	local app = lor()
	
	app:conf("view enable", true)
	app:conf("view engine", "tmpl")
	app:conf("view ext", "html")
	app:conf("views", "./app/views")
	
	app:use(session_middleware())
	
	-- filter: add response header
	app:use(function(req, res, next)
	    res:set_header('X-Powered-By', 'Lor Framework')
	    next()
	end)
	
	-- 拦截器:登录
	app:use(check_login_middleware(whitelist))
 
	local authRouter = require("app.routes.auth")
	local todoRouter = require("app.routes.todo")
	local errorRouter = require("app.routes.error")
	 
    app:use("/auth", authRouter())
    app:use("/todo", todoRouter())
    app:use("/error", errorRouter()) 
    app:get("/", function(req, res, next)
        if req.session and req.session.get("username") then
            res:redirect("/todo/index")
        else
            res:redirect("/auth/login")
        end
    end)
 
    app:get("/view", function(req, res, next)
        local data = {
            name =  req.query.name or "lor",
            desc =   req.query.desc or 'a framework of lua based on OpenResty'
        }
        res:render("login", data)
    end)
	  
	-- 404 error
	app:use(function(req, res, next)
	    if req:is_found() ~= true then
	        res:status(404):send("404! sorry, page not found.")
	    end
	end)
	
	-- error handle middleware
	app:erroruse(function(err, req, res, next)
		ngx.log(500, err)
	    res:status(500):send("unknown error")
	end)
	
	app:run()

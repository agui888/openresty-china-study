local pcall = pcall
local type = type
local pairs = pairs


local function dump(...)
    if not LOR_FRAMEWORK_DEBUG then
        return
    end

    local info = { ... }
    if info and type(info[1]) == 'function' then
        pcall(function() info[1]() end)
    elseif info and type(info[1]) == 'table' then
        for i, v in pairs(info[1]) do
            print(i, v)
        end
    elseif ... ~= nil then
        print(...)
    else
        print("debug not works...")
    end
end

--[[
- @desc   lua数据输出
- @param  string   字符串 
- return  string
--]]
function debug(v)
	if not __dump then
		function __dump(v, t, p)    
			local k = p or "";

			if type(v) ~= "table" then
				table.insert(t, k .. " : " .. tostring(v));
			else
				for key, value in pairs(v) do
					__dump(value, t, k .. "[" .. key .. "]");
				end
			end
		end
	end

	local t = {"\r\n" ..'/*************** 调试日志 **************/' };
	__dump(v, t);
	print(table.concat(t, "\r\n"));
end


return debug
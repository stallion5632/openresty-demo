local _M = {
    _VERSION = '0.01'
}


-- local debug = config.debug
-- local base_model = require 'system.model'
local regex = ngx.re
local strlen = string.len
local substr = string.sub

function _M.dump(v)
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
	local t = {'\n'};
	__dump(v, t);
    return table.concat(t, "\n||================== ") .. '\n'
end

function _M.trim(str)
    local m, err = regex.match(str, "[^s]+.+[^s]+", 'ijso')
    if m then
        return m[0]
    else
        return str, err
    end
end

function _M.is_empty_table(tab)
    local num = 0
    for _, _ in pairs(tab) do
        num = num + 1
    end
    if num > 0 then
        return false
    else
        return true
    end
end

function _M.extends(child, parent)
    local mt = {__index = parent}
    return setmetatable(child, mt)
end

function _M.extends_model(model)
    return _M.extends(model, base_model)
end

function _M.merge(tab1, tab2)
    local obj = tab1 or {}
    for k, v in pairs(tab2) do
        if v ~= nil then
            obj[k] = v
        end
    end
    return obj
end

function _M.in_array(ele, tab)
    if ele == nil or type(ele) == 'table' or type(tab) ~= 'table' then
        return nil
    end
    local matched,i,v
    for i, v in pairs(tab) do
        if v == ele then
            matched = i
            break
        end
    end
    return matched
end

function _M.clear_table(tab)
    local obj = {}
    for k, v in pairs(tab) do
        if v then
            obj[k] = v
        end
    end
    return obj
end

function _M.table_length(tab, except)
    local len = 0
    for k, v in pairs(tab) do
        if v and except then
            len = len+1
        else
            len = len+1
        end
    end
    return len
end

function _M.split(str, pattern)
    local tab = {}
    local iterator, err = regex.gmatch(str, pattern, 'ijso')
    if not iterator then
        tab = {str}
        return tab, err
    end
    local m, err = iterator()
    if not m then
        tab = {str}
        return tab, err
    end
    while m do
        tab[#tab+1] = m[1]
        m = iterator()
    end
    return tab
end

function _M.explode(delimiter, str)
    local tab = {}
    if type(str) ~= 'string' or delimiter == nil then
        return tab
    end

    local delen = -strlen(delimiter)
    local subs = substr(str, delen)
    if subs ~= delimiter then
        str = str..delimiter
    end
    local pattern
    if _M.in_array(delimiter, {'|'}) then
        pattern = '([^'..delimiter..']+)\\'..delimiter
    else
        pattern = '([^'..delimiter..']+)'..delimiter
    end
    return _M.split(str, pattern)
end


function _M.url_parse(url)
    local url_tab = {path = nil, params = {} }
    if url == nil then
        return nil, 'the url is nil'
    end
    local m, err = regex.match(url, '([^\\?]+)\\?([^\\?]+)')
    if not m then
        url_tab.path = url
        return url_tab, err
    end
    url_tab.path = m[1]
    local iterator, err = regex.gmatch(m[2], '([a-zA-Z0-9_-]+)=([a-zA-Z0-9_-]+)', 'ijso')
    if not iterator then
        url_tab.params = {}
        return url_tab, err
    end
    local m, err = iterator()
    if not m then
        url_tab.params = {}
        return url_tab, err
    end
    while m do
        url_tab.params[m[1]] = m[2]
        m = iterator()
    end
    return url_tab
end

function _M.implode(delimiter, tab)
    local str = ''
    if type(tab) ~= 'table' or delimiter == nil then
        return str
    end
    local count = #tab
    for i, v in pairs(tab) do
        if type(v) ~= 'table' then
            str = str..v
            if i ~= count then
                str = str..delimiter
            end
        end
    end
    return str
end

return _M
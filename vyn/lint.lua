local vyn_lint = {}


local function table_type(tbl)
    local n_num, n_str = 0, 0
    for i,_ in pairs(tbl) do
        if type(i) == "number" then
            n_num = n_num + 1
        elseif type(i) == "string" then
            n_str = n_str + 1
        end
    end

    return (n_str == 0 and n_num > 0) and "array" or "object"
end

---@param val any
---@param ... string
---@return boolean
function vyn_lint.check_type(val, ...)
    local valid_type = false
    for _,v in pairs{...} do
        if type(val) == "table" and table_type(val) == v then
            valid_type = true; break
        elseif type(val) == v then
            valid_type = true; break
        end
    end
    return valid_type
end

local function split_prop(str)
    local buff = {}
    for s in str:gmatch "([^.]+)" do
        table.insert(buff,
            s:match "^%d+$" and '['..s..']' or
            s:match "[a-zA-Z0-9_]+" and '.'..s or "['"..s.."']")
    end
    return buff
end

---@param tbl table
---@param prop string
---@param ... string
---@return boolean
function vyn_lint.check_prop_type(tbl, prop, ...)
    local t_prop = split_prop(prop)

    ---@diagnostic disable-next-line: deprecated
    local res = (load or loadstring)([=[
        return (_VERSION == 5.1 and arg or {...})[1]]=]
        ..table.concat(t_prop))(tbl)

    return vyn_lint.check_type(res, ...)
end

local function strict_check_prop_type(tbl, prop, ...)
    if not vyn_lint.check_prop_type(tbl, prop, ...) then
        error("property `table"..table.concat(split_prop(prop))..
            "` does not match any types of <"..table.concat({...}, ", ")..">!")
    end
end

function vyn_lint.validate_toml(toml_str)
    local toml = require "toml"

    local ok, tbl = pcall(toml.decode, toml_str)
    if not ok then
        local msg = "from line:"..tbl.begin.line.." column:"..tbl.begin.column.." to line:"..tbl["end"].line.." column:"..tbl["end"].column..", "..tbl.reason
        return ok, msg
    end

    local err
    ok, err = pcall(function()
        strict_check_prop_type(tbl, "syntax", "object")
        strict_check_prop_type(tbl, "syntax.name", "string")
        strict_check_prop_type(tbl, "syntax.filetype", "array")
        strict_check_prop_type(tbl, "syntax.filetype.1", "string")
        strict_check_prop_type(tbl, "syntax.filetype.2", "string")
        strict_check_prop_type(tbl, "rules", "array")
        for i,_ in ipairs(tbl.rules) do
            strict_check_prop_type(tbl, "rules."..i..".keyword", "array", "string")
        end
    end)

    if not ok then
        local curr_source = debug.getinfo(1,'S').source:gsub("^@",""):gsub("%p","%%%1")
        err = err:gsub("^"..curr_source..":%d-:%s*", "") ---@diagnostic disable-line: need-check-nil 
        return false, err
    else return true end
end

return vyn_lint

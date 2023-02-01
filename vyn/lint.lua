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

local function parse_prop(str)
    local buff = {}
    for s in str:gmatch "([^.]+)" do
        table.insert(buff,
            s:match "^%d+$" and '['..s..']' or
            s:match "[a-zA-Z0-9_]+" and '.'..s or "['"..s.."']")
    end
    return table.concat(buff)
end

---@param tbl table
---@param prop string
---@param ... string
---@return boolean
function vyn_lint.check_prop_type(tbl, prop, ...)
    local str_prop = parse_prop(prop)

    ---@diagnostic disable-next-line: deprecated
    local res = (load or loadstring)([=[
        return (_VERSION == 5.1 and arg or {...})[1]]=]
        ..str_prop)(tbl)

    return vyn_lint.check_type(res, ...)
end

local function strict_check_prop_type(tbl, prop, ...)
    if not vyn_lint.check_prop_type(tbl, prop, ...) then
        error("Property `/`toml_src"..parse_prop(prop)..
            "`/ does not match any types of <"..table.concat({...}, ", ")..">!")
    end
end

---@param tbl table
---@param color? boolean
---@return boolean
---@return string?
function vyn_lint.validate_toml(tbl, color)
    local ok, err = pcall(function()
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

    if not ok and err then
        local curr_source = debug.getinfo(1,'S').source:gsub("^@",""):gsub("%p","%%%1")
        err = err:gsub("^"..curr_source..":%d-:%s*", "")

        if not color then
            err = err
                :gsub("(.|(.-)|)","%2")
                :gsub("(./(.-)/)", "%2")
        end
        return false, err
    else return true end
end

return vyn_lint

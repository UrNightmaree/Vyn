local L = require "vyn.Lust"
local toml = require "toml"
local vyn_lint = require "vyn.lint"

local vyn_parse = {}

---@param toml_str string
---@param color? boolean 
---@return string?
---@return string?
function vyn_parse.parse_toml_to_vim(toml_str, color)
    local ok, tbl = pcall(toml.decode, toml_str)

    if not ok and tbl then
        local err = L"From *|line: $<1.line> column: $<1.column> to line: $<2.line> column: $<2.column>|\n @/$<3>/":gen{tbl.begin, tbl["end"], tbl.reason}

        if not color then
            err = err
                :gsub("(.|(.-)|)", "%2")
                :gsub("(./(.-)/)", "%2")
        end

        return nil, err
    end

    local err
    ok, err = vyn_lint.validate_toml(tbl, color)

    if not ok and err then
        return nil, err
    end
end

return vyn_parse

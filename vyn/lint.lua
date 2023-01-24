-- for linting .toml
local vyn_lint = {}

function vyn_lint.check_type(val, ...)
    local valid_type = false
    for _,v in pairs{...} do
        if type(val) == v then
            valid_type = true; break
        end
    end
    return valid_type
end

print(vyn_lint.check_type(_VERSION, "table", "number"))

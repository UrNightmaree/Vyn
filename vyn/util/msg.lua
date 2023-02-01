local C = vyn_ansicolorsx or require "ansicolorsx" ---@diagnostic disable-line:undefined-global

local util_msg = {}

local ind_n = 8

local function ljust(txt)
    return ('%'..ind_n..'s'):format(txt)
end

local function fix_indent(txt)
    local res = ""

    local i = 0
    for s in txt:gmatch "([^\n\r]+)" do
        if i == 0 then
            res = s..'\n'
            i = i + 1
        else
            res = res..(' '):rep(ind_n + 1)..s..'\n'
            i = i + 1
        end
    end
    return res:gsub("\n$","")
end

function util_msg.info(txt)
    print(
        C("%{blue}"..ljust"info")..' '..fix_indent(txt)
    )
end

function util_msg.err(txt)
    print(
        C("%{red}"..ljust"error")..' '..fix_indent(txt)
    )
end

function util_msg.warn(txt)
    print(
        C("%{yellow}"..ljust"warning")..' '..fix_indent(txt)
    )
end

function util_msg.parse(txt)
    local tparse = {
        { "%*", "green" },
        { '@', "red" },
        { '`', "bright" }
    }

    for _, v in ipairs(tparse) do
        txt = txt:gsub("("..v[1].."|(.-)|)", function(_,str)
            return C("%{"..v[2]..'}'..str) end)
        txt = txt:gsub("("..v[1].."/(.-)/)", function(_,str)
            return C("%{bright "..v[2]..'}'..str) end)
    end

    return txt
end

return util_msg

utils = {}


function mprint(str)
    local monitor = peripheral.find("monitor")
    local s, d = monitor.getCursorPos()
    monitor.write(tostring(str))
    monitor.setCursorPos(s,d+1)
end

function nwrite(term, str)
    local x, y = term.getCursorPos()
    local i = 1
    while true do
        local ms = string.find(str, "\n", i, true)
        if ms == nil then break end
        term.write(string.sub(str, i, ms-1))
        y = y+1
        term.setCursorPos(x, y)
        i = ms+1
    end
end


local function newline(indent)
    res = "\n"
    for i=1, indent do
        res = res .. "  "
    end
    return res
end


function ttstring(t, max_depth, indent, already_printed)
    if max_depth == 0 then return tostring(t) end
    already_printed = already_printed or {}
    if already_printed[tostring(t)] then return tostring(t) end
    already_printed[tostring(t)] = true
    max_depth = max_depth or 10
    indent = indent or 1
    res = "{" .. newline(indent)
    for k, v in pairs(t) do
        if type(v)=="table" then
            res = res..k..": "..ttstring(v, max_depth - 1, indent+1, already_printed)..","..newline(indent)
        elseif type(v)=="function" then
        else
            res = res..k..": "..tostring(v)..","..newline(indent)
        end
    end
    return res .. "}"
end

function tableEq(t1, t2)
    if #t1 ~= #t2 then 
        return false end
    for k, v in pairs(t1) do
        if type(t1[k]) ~= type(t2[k]) then return false end
        if type(t1[k]) == "table" then
            if not tableEq(t1[k], t2[k]) then return false end
        else
            if t1[k] ~= t2[k] then return false end
        end
    end
    return true
end

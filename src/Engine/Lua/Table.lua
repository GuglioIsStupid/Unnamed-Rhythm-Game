function table.findID(tbl, val)
    for i, v in pairs(tbl) do
        if v == val then
            return i
        end
    end
end

function table.find(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then
            return v
        end
    end
end

function table.contains(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then
            return true
        end
    end

    return false
end

function table.containsKey(tbl, key)
    for k, _ in pairs(tbl) do
        if k == key then
            return true
        end
    end

    return false
end

function table.random(tbl)
    local rnd = {}
    for _, v in pairs(tbl) do
        table.insert(rnd, v)
    end

    return rnd[love.math.random(1, #rnd)]
end

function table.format(tbl, indent)
    indent = indent or 1

    local str = "{"
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            if tonumber(k) then
                str = str .. "\n" .. string.rep("  ", indent) .. table.format(v, indent + 1)
            else
                str = str .. "\n" .. string.rep("  ", indent) .. tostring(k) .. ": " .. table.format(v, indent + 1)
            end
        else
            if tonumber(k) then
                str = str .. "\n" .. string.rep("  ", indent) .. table.format(v, indent + 1)
            else
                str = str .. "\n" .. string.rep("  ", indent) .. tostring(k) .. ": " .. tostring(v)
            end
        end
    end
    str = str .. "\n" .. string.rep("  ", indent - 1) .. "}"
    
    return str
end
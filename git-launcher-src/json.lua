local select, string_char, string_format, tonumber = select, string.char, string.format, tonumber

--[[
A Hybrid of rxi's JSON decoder and Shunsuke Shimizu's (grafi-tt) JSON encoder.
]]
-------------------------------------------------------------------------------
-- Decode
-- By rxi
-------------------------------------------------------------------------------

local json = {}

local escape_char_map = {
    ["\\"] = "\\",
    ['"'] = '"',
    ["\b"] = "b",
    ["\f"] = "f",
    ["\n"] = "n",
    ["\r"] = "r",
    ["\t"] = "t"
}

local escape_char_map_inv = {["/"] = "/"}
for k, v in pairs(escape_char_map) do
    escape_char_map_inv[v] = k
end

local parse

local function create_set(...)
    local res = {}
    for i = 1, select("#", ...) do
        res[select(i, ...)] = true
    end
    return res
end

local space_chars = create_set(" ", "\t", "\r", "\n")
local delim_chars = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
local literals = create_set("true", "false", "null", "undefined") -- added undefined, but it is not a standard JSON literal... this is only so the game doesn't crash if it is used for some reason

local literal_map = {
    ["true"] = true,
    ["false"] = false,
    ["null"] = nil,
    ["undefined"] = nil
}

local function next_char(str, idx, set, negate)
    for i = idx, #str do
        if set[str:sub(i, i)] ~= negate then
            return i
        end
    end
    return #str + 1
end

local function decode_error(str, idx, msg)
    local line_count = 1
    local col_count = 1
    for i = 1, idx - 1 do
        col_count = col_count + 1
        if str:sub(i, i) == "\n" then
            line_count = line_count + 1
            col_count = 1
        end
    end
    error(string_format("%s at line %d col %d", msg, line_count, col_count))
end

local function codepoint_to_utf8(n)
    -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
    local f = math.floor
    if n <= 0x7f then
        return string_char(n)
    elseif n <= 0x7ff then
        return string_char(f(n / 64) + 192, n % 64 + 128)
    elseif n <= 0xffff then
        return string_char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
    elseif n <= 0x10ffff then
        return string_char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128, f(n % 4096 / 64) + 128, n % 64 + 128)
    end
    error(string_format("invalid unicode codepoint '%x'", n))
end

local function parse_unicode_escape(s)
    local n1 = tonumber(s:sub(1, 4), 16)
    local n2 = tonumber(s:sub(7, 10), 16)
    -- Surrogate pair?
    if n2 then
        return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
    else
        return codepoint_to_utf8(n1)
    end
end

local function parse_string(str, i)
    local res = ""
    local j = i + 1
    local k = j

    while j <= #str do
        local x = str:byte(j)

        if x < 32 then
            decode_error(str, j, "control character in string")
        elseif x == 92 then -- `\`: Escape
            res = res .. str:sub(k, j - 1)
            j = j + 1
            local c = str:sub(j, j)
            if c == "u" then
                local hex =
                    str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1) or str:match("^%x%x%x%x", j + 1) or
                    decode_error(str, j - 1, "invalid unicode escape in string")
                res = res .. parse_unicode_escape(hex)
                j = j + #hex
            else
                if not escape_chars[c] then
                    decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
                end
                res = res .. escape_char_map_inv[c]
            end
            k = j + 1
        elseif x == 34 then -- `"`: End of string
            res = res .. str:sub(k, j - 1)
            return res, j + 1
        end

        j = j + 1
    end

    decode_error(str, i, "expected closing quote for string")
end

local function parse_number(str, i)
    local x = next_char(str, i, delim_chars)
    local s = str:sub(i, x - 1)
    local n = tonumber(s)
    if not n then
        decode_error(str, i, "invalid number '" .. s .. "'")
    end
    return n, x
end

local function parse_literal(str, i)
    local x = next_char(str, i, delim_chars)
    local word = str:sub(i, x - 1)
    if not literals[word] then
        decode_error(str, i, "invalid literal '" .. word .. "'")
    end
    return literal_map[word], x
end

local function parse_array(str, i)
    local res = {}
    local n = 1
    i = i + 1
    while 1 do
        local x
        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        -- Empty / end of array?
        if chr == "]" then
            i = i + 1
            break
        end
        -- Read token
        x, i = parse(str, i)
        res[n] = x
        n = n + 1
        -- Next token
        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        i = i + 1
        if chr == "]" then
            break
        end
        if chr ~= "," then
            decode_error(str, i, "expected ']' or ','")
        end
    end
    return res, i
end

local function parse_object(str, i)
    local res = {}
    i = i + 1
    while 1 do
        local key, val
        i = next_char(str, i, space_chars, true)
        local chr = str:sub(i, i)
        -- Empty / end of object?
        if chr == "}" then
            i = i + 1
            break
        end
        -- Read key
        if chr ~= '"' then
            decode_error(str, i, "expected string for key")
        end
        key, i = parse(str, i)
        -- Read ':' delimiter
        i = next_char(str, i, space_chars, true)
        chr = str:sub(i, i)
        if chr ~= ":" then
            decode_error(str, i, "expected ':' after key")
        end
        i = next_char(str, i + 1, space_chars, true)
        -- Read value
        val, i = parse(str, i)
        -- Set
        res[key] = val
        -- Next token
        i = next_char(str, i, space_chars, true)
        chr = str:sub(i, i)
        i = i + 1
        if chr == "}" then
            break
        end
        if chr ~= "," then
            decode_error(str, i, "expected '}' or ','")
        end
    end
    return res, i
end

local char_func_map = {
    ['"'] = parse_string,
    ["0"] = parse_number,
    ["1"] = parse_number,
    ["2"] = parse_number,
    ["3"] = parse_number,
    ["4"] = parse_number,
    ["5"] = parse_number,
    ["6"] = parse_number,
    ["7"] = parse_number,
    ["8"] = parse_number,
    ["9"] = parse_number,
    ["-"] = parse_number,
    ["t"] = parse_literal,
    ["f"] = parse_literal,
    ["n"] = parse_literal,
    ["["] = parse_array,
    ["{"] = parse_object
}

parse = function(str, idx)
    local chr = str:sub(idx, idx)
    local f = char_func_map[chr]
    if f then
        return f(str, idx)
    end
    decode_error(str, idx, "unexpected character '" .. chr .. "'")
end

function json.decode(str)
    if type(str) ~= "string" then
        error("expected argument of type string, got " .. type(str))
    end
    local res, idx = parse(str, next_char(str, 1, space_chars, true))
    idx = next_char(str, idx, space_chars, true)
    if idx <= #str then
        decode_error(str, idx, "trailing garbage")
    end
    return res
end

-------------------------------------------------------------------------------
-- Encode
-- By Shunsuke Shimizu
-------------------------------------------------------------------------------
local error = error
local byte, find, format, gsub, match = string.byte, string.find, string_format, string.gsub, string.match
local concat = table.concat
local tostring = tostring
local pairs, type = pairs, type
local setmetatable = setmetatable
local huge, tiny = 1 / 0, -1 / 0

local f_string_esc_pat
if _VERSION == "Lua 5.1" then
    -- use the cluttered pattern because lua 5.1 does not handle \0 in a pattern correctly
    f_string_esc_pat = "[^ -!#-[%]^-\255]"
else
    f_string_esc_pat = '[\0-\31"\\]'
end

local _ENV = nil

local function newencoder()
    local v, nullv
    local i, builder, visited

    local function f_tostring(v)
        builder[i] = tostring(v)
        i = i + 1
    end

    local radixmark = match(tostring(0.5), "[^0-9]")
    local delimmark = match(tostring(12345.12345), "[^0-9" .. radixmark .. "]")
    if radixmark == "." then
        radixmark = nil
    end

    local radixordelim
    if radixmark or delimmark then
        radixordelim = true
        if radixmark and find(radixmark, "%W") then
            radixmark = "%" .. radixmark
        end
        if delimmark and find(delimmark, "%W") then
            delimmark = "%" .. delimmark
        end
    end

    local f_number = function(n)
        if tiny < n and n < huge then
            local s = format("%.17g", n)
            if radixordelim then
                if delimmark then
                    s = gsub(s, delimmark, "")
                end
                if radixmark then
                    s = gsub(s, radixmark, ".")
                end
            end
            builder[i] = s
            i = i + 1
            return
        end
        error("invalid number")
    end

    local doencode

    local f_string_subst = {
        ['"'] = '\\"',
        ["\\"] = "\\\\",
        ["\b"] = "\\b",
        ["\f"] = "\\f",
        ["\n"] = "\\n",
        ["\r"] = "\\r",
        ["\t"] = "\\t",
        __index = function(_, c)
            return format("\\u00%02X", byte(c))
        end
    }
    setmetatable(f_string_subst, f_string_subst)

    local function f_string(s)
        builder[i] = '"'
        if find(s, f_string_esc_pat) then
            s = gsub(s, f_string_esc_pat, f_string_subst)
        end
        builder[i + 1] = s
        builder[i + 2] = '"'
        i = i + 3
    end

    local function f_table(o)
        if visited[o] then
            error("loop detected")
        end
        visited[o] = true

        local tmp = o[0]
        if type(tmp) == "number" then -- arraylen available
            builder[i] = "["
            i = i + 1
            for j = 1, tmp do
                doencode(o[j])
                builder[i] = ","
                i = i + 1
            end
            if tmp > 0 then
                i = i - 1
            end
            builder[i] = "]"
        else
            tmp = o[1]
            if tmp ~= nil then -- detected as array
                builder[i] = "["
                i = i + 1
                local j = 2
                repeat
                    doencode(tmp)
                    tmp = o[j]
                    if tmp == nil then
                        break
                    end
                    j = j + 1
                    builder[i] = ","
                    i = i + 1
                until false
                builder[i] = "]"
            else -- detected as object
                builder[i] = "{"
                i = i + 1
                local tmp = i
                for k, v in pairs(o) do
                    if type(k) ~= "string" then
                        error("non-string key")
                    end
                    f_string(k)
                    builder[i] = ":"
                    i = i + 1
                    doencode(v)
                    builder[i] = ","
                    i = i + 1
                end
                if i > tmp then
                    i = i - 1
                end
                builder[i] = "}"
            end
        end

        i = i + 1
        visited[o] = nil
    end

    local dispatcher = {
        boolean = f_tostring,
        number = f_number,
        string = f_string,
        table = f_table,
        __index = function()
            error("invalid type value")
        end
    }
    setmetatable(dispatcher, dispatcher)

    function doencode(v)
        if v == nullv then
            builder[i] = "null"
            i = i + 1
            return
        end
        return dispatcher[type(v)](v)
    end

    local function encode(v_, nullv_)
        v, nullv = v_, nullv_
        i, builder, visited = 1, {}, {}

        doencode(v)
        return concat(builder)
    end

    return encode
end

json.encode = newencoder()

return json

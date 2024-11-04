local httpslib = require("https")
local ltn12 = require("ltn12")

local https = {
    prefix = "thread.https_",
    queries = {}
}

if type(...) == "number" then -- We are in a thread
    require "love.timer"

    local i = ...

    local args = love.thread.getChannel(https.prefix .. i .. "_ARGS"):pop()

    local body = {}
    args.sink = ltn12.sink.table(body)
    if not httpslib then
        print("Cannot create request")
        return false
    end
    local r, c, h = httpslib.request(args.url, args)

    love.thread.getChannel(https.prefix .. i .. "_RES"):push({ table.concat(body), h, c })
else
    local filepath = (...):gsub("%.", "/") .. ".lua"

    function https.request(args, callback)
        local thread = love.thread.newThread(filepath)

        local query = {
            thread = thread,
            callback = callback,
            index = #https.queries + 1,
            active = true
        }

        https.queries[query.index] = query

        love.thread.getChannel(https.prefix .. query.index .. "_ARGS"):push(args)
        thread:start(query.index)

        return query
    end

    function https.update()
        for i, query in pairs(https.queries) do
            if query.thread then
                if not query.thread:isRunning() then
                    query.active = false

                    local err = query.thread:getError()
                    assert(not err, err)

                    local result = love.thread.getChannel(https.prefix .. i .. "_RES"):pop()
                    if result ~= nil then
                        if query.callback then query.callback(unpack(result)) end
                        love.thread.getChannel(https.prefix .. i .. "_RES"):push(nil)
                    end

                    https.queries[query.index] = nil
                end
            end
        end
    end

    function https.cancel(query)
        if query.thread and query.thread:isRunning() then
            query.callback = nil
        end
    end

    return https
end
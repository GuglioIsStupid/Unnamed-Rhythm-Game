local LOG = ""

love.filesystem.createDirectory("Logs")

function debug.error(...)
    local message = {...}
    local errorMessage = ""
    if type(message) == "table" then
        errorMessage = "[ERROR] "
        for key, value in pairs(message) do
            errorMessage = errorMessage .. key .. ": " .. value .. "\n"
        end
    end
    LOG = LOG .. errorMessage
    debug.save()
    error(errorMessage)
end

function debug.warn(...)
    local message = {...}
    local errorMessage = ""
    if type(message) == "table" then
        errorMessage = "[WARN] "
        for key, value in pairs(message) do
            errorMessage = errorMessage .. key .. ": " .. value .. "\n"
        end
    end
    LOG = LOG .. errorMessage
    print(errorMessage)
end

function debug.log(...)
    local message = {...}
    local errorMessage = ""
    if type(message) == "table" then
        errorMessage = "[LOG] "
        for key, value in pairs(message) do
            errorMessage = errorMessage .. key .. ": " .. value .. "\n"
        end
    end
    LOG = LOG .. errorMessage
    print(errorMessage)
end

function debug.info(...)
    local message = {...}
    local errorMessage = ""
    if type(message) == "table" then
        errorMessage = "[INFO] "
        for key, value in pairs(message) do
            errorMessage = errorMessage .. key .. ": " .. value .. "\n"
        end
    end
    LOG = LOG .. errorMessage
    print(errorMessage)
end

function debug.save()
    -- format os.time()
    local time = os.date("*t")
    local formattedTime = time.year .. "-" .. time.month .. "-" .. time.day .. "-" .. time.hour .. "-" .. time.min
    love.filesystem.write("Logs/log-" .. formattedTime .. ".txt", LOG)
    print("Log saved to log-" .. formattedTime .. ".txt")
end

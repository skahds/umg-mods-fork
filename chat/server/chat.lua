



--[[
    serverside chat api
]]
local chat = {}






--[[

TODO: Rate limit the number of messages that can be sent
per user, to prevent spamming.

]]

local constants = require("shared.chat_constants")



-- start of command character in minecraft, like `/` in minecraft.
local commandCharString = "/!;?$"
local commandChars = {}

for i=1, #commandCharString do
    commandChars[commandCharString:sub(i,i)] = true
end

require("shared.chat_packets") -- in case it's not loaded yet

server.on("chat:message", function(sender, message, channel)
    if type(message)~="string"then
        return
    end
    if #message > constants.MAX_MESSAGE_SIZE then
        return
    end
    if commandChars[message:sub(1,1)] then
        return  -- nope!
    end

    -- TODO: Do colored names here
    local msg = "[" .. sender .. "]" .. " " .. message
    server.broadcast("chat:message", msg, channel)
end)










function chat.message(message, channel)
    channel = channel or constants.DEFAULT_CHANNEL
    server.broadcast("chat:message", message, channel)
end


function chat.privateMessage(clientId, message, channel)
    channel = channel or constants.DEFAULT_CHANNEL
    server.unicast( clientId, "chat:message", message, channel)
end


return chat


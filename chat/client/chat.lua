

local chat = {}

local ChatBox = require("client.ChatBox")
local chatControls = require("client.chatControls")

local constants = require("shared.chat_constants")

require("shared.chat_packets") -- in case it's not loaded yet



local chatBox = ChatBox()

---@return chat.ChatBox
function chat.getChatBoxElement()
    return chatBox
end




client.on("chat:message", function(msg)
    -- TODO: Do colors and stuff here.
    chatBox:pushMessage(msg)
end)





-- love.keyboard.setKeyRepeat(true)


local function parseCommandArg(arg)
    if arg:lower() == "true" then
        return true
    elseif arg:lower() == "false" then
        return false
    elseif tonumber(arg) then
        return tonumber(arg)
    end
    return arg
end



local function doCommand(message)
    local buffer = {}
    local _,f = message:find("%S+")
    local command = message:sub(2, f)
    if #message > 0 then
        for arg in message:sub(f+1):gmatch("%S+") do
            table.insert(buffer, parseCommandArg(arg))
        end
        client.send("chat:command", command, unpack(buffer))
    end
end



local listener = input.InputListener()
chat.listener = listener


listener:onTextInput(function(_self, t)
    if chatBox:isChatOpen() then
        chatBox:inputText(t)
    end
end)




--[[
    todo:

    make a proper chat channels API and stuff, and make it consistent
]]
local DEFAULT_CHANNEL = constants.DEFAULT_CHANNEL
local COMMAND_CHAR = constants.COMMAND_CHAR

function chat.message(msg, channel)
    local startChar = msg:sub(1,1)
    if COMMAND_CHAR == startChar then
        doCommand(msg)
    else
        channel = channel or DEFAULT_CHANNEL
        client.send("chat:message", msg, channel)
    end
end



local function inputTyping(controlEnum)
    if controlEnum == chatControls.BACKSPACE then
        chatBox:deleteText(1)
        return true
    elseif controlEnum == chatControls.CHAT then
        chatBox:submitMessage()
        return true
    elseif controlEnum == "ui:EXIT" then
        chatBox:closeChat()
        return true
    end

    return false
end


local function inputNotTyping(cEnum)
    if cEnum == chatControls.CHAT or cEnum == chatControls.COMMAND then
        chatBox:openChat()

        if cEnum == chatControls.COMMAND then
            chatBox:inputText("/")
        end

        return true
    end

    return false
end


listener:onAnyPressed(function(_self, controlEnum)
    --[[
        TODO: Do we need to do blocking here???
    ]]
    local chatOpen = chatBox:isChatOpen()
    if (chatOpen and inputTyping(controlEnum)) or (not chatOpen and inputNotTyping(controlEnum)) then
        _self:claim(controlEnum)
    end
    -- if chatBox:isChatOpen() then
    --     if inputTyping(controlEnum) then
    --         _self:claim(controlEnum)
    --     end
    -- else
    --     if inputNotTyping(controlEnum) then
    --         _self:claim()
    --     end
    -- end
end)



listener:onUpdate(function(self)
    if chatBox and chatBox:isChatOpen() then
        self:lockTextInput()
    end
end)


-- umg.on("rendering:drawUI", function()
--     --[[
--         draw the chat:
--     ]]
--     lg.push("all")
--     chatBox:render(0,0,lg.getDimensions())
--     lg.pop()
-- end)



return chat

local fonts = require("client.fonts")

local EndGameScene = require("client.elements.EndGameScene")
local LevelStatus = require("client.elements.LevelStatus")
local MoneyBox = require("client.elements.MoneyBox")
local SimpleBox = require("client.elements.SimpleBox")
local StretchableButton = require("client.elements.StretchableButton")

local DescriptionBox = require("client.DescriptionBox")

---@class lootplot.main.Scene: Element
local Scene = ui.Element("lootplot.main:Screen")

function Scene:init()
    self:makeRoot()
    self:setPassthrough(true)

    self.levelStatus = LevelStatus()
    self.moneyBox = MoneyBox()
    self.endGameDialog = EndGameScene({
        onDismiss = function()
            self.renderEndGameDialog = false
        end
    })

    self.itemDescriptionSelected = nil
    self.itemDescriptionSelectedTime = 0
    self.cursorDescription = nil
    self.cursorDescriptionTime = 0
    self.renderEndGameDialog = false
    self.slotActionButtons = {}

    self:addChild(self.moneyBox)
    self:addChild(self.levelStatus)
    self:addChild(self.endGameDialog)
end


local function drawBoxTransparent(x, y, w, h)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x, y, w, h, 10, 10)
    love.graphics.setColor(1, 1, 1)
end

local COLOR = {27/255, 27/255, 54/255}
local function drawSideBox(x, y, w, h)
    return SimpleBox.draw(COLOR, x, y, w, h, 10, 4)
end

---@param progress number
---@param dbox lootplot.main.DescriptionBox
---@param color objects.Color
---@param region ui.Region
---@param backgroundDrawer fun(x:number,y:number,w:number,h:number)
local function drawDescription(progress, dbox, color, region, backgroundDrawer)
    local x, y, w, h = region:get()
    local bestHeight = select(2, dbox:getBestFitDimensions(w))
    -- local container = ui.Region(0, 0, w, bestHeight)
    -- local centerContainer = container:center(region)
    local theHeight = math.min(progress, bestHeight)

    backgroundDrawer(x - 5, y - 5, w + 10, theHeight + 10)
    love.graphics.setColor(1, 1, 1)

    if progress >= h then
        love.graphics.setColor(color)
        dbox:draw(x, y, w, h)
        return false
    end

    return true
end

function Scene:onRender(x,y,w,h)
    local r = ui.Region(x,y,w,h)

    local left, middle, right = r:padRatio(0.05):splitHorizontal(2, 5, 2)
    local HEADER_RATIO = 5
    local levelStatusRegion, rest = left:splitVertical(1, HEADER_RATIO)
    local _, rest2 = right:splitVertical(1, HEADER_RATIO)
    local moneyRegion = rest:splitVertical(1, 4)
    local descriptionOpenSpeed = h * 9

    self.levelStatus:render(levelStatusRegion:padRatio(0.1):get())
    self.moneyBox:render(moneyRegion:padRatio(0.1):padRatio(0, 0.4, 0, 0.4):get())

    if self.cursorDescription then
        local mx, my = input.getPointerPosition()
        local descW = w/3
        local descH = select(2, self.cursorDescription:getBestFitDimensions(descW))
        local descRegion = ui.Region(
            math.max(mx - 16 - descW, 16),
            math.min(my + 16, h - descH - 16),
            descW,
            descH
        )
        self.cursorDescriptionTime = self.cursorDescriptionTime + love.timer.getDelta() * descriptionOpenSpeed
        drawDescription(self.cursorDescriptionTime, self.cursorDescription, objects.Color.WHITE, descRegion, drawBoxTransparent)
    end

    if self.itemDescriptionSelected then
        local rightDescRegion = select(2, rest2:splitVertical(1, 5))
        self.itemDescriptionSelectedTime = self.itemDescriptionSelectedTime + love.timer.getDelta() * descriptionOpenSpeed
        drawDescription(self.itemDescriptionSelectedTime, self.itemDescriptionSelected, objects.Color.WHITE, rightDescRegion, drawSideBox)
    end

    if #self.slotActionButtons > 0 then
        local _, bottomArea = r:splitVertical(5, 1)
        _,bottomArea = bottomArea:splitHorizontal(1,3,1)
        local grid = bottomArea:grid(#self.slotActionButtons, 1)

        for i, button in ipairs(self.slotActionButtons) do
            local region = grid[i]:padRatio(0.2)
            button:render(region:get())
        end
    end

    if self.renderEndGameDialog then
        local dialog = r:padRatio(0.3)
        self.endGameDialog:render(dialog:get())
    end
end

local function populateDescriptionBox(entity)
    local description = lp.getLongDescription(entity)
    local dbox = DescriptionBox(fonts.getSmallFont(32))

    dbox:addRichText("{wavy}"..text.escapeRichTextSyntax(lp.getEntityName(entity)).."{/wavy}", fonts.getLargeFont(32))
    dbox:newline()

    for _, descriptionText in ipairs(description) do
        dbox:addRichText(descriptionText, fonts.getSmallFont(32))
    end

    return dbox
end

---@param ent lootplot.LayerEntity?
function Scene:setCursorDescription(ent)
    if ent then
        self.cursorDescription = populateDescriptionBox(ent)
    else
        self.cursorDescription = nil
    end
    self.cursorDescriptionTime = 0
end

---@param itemEnt lootplot.ItemEntity?
function Scene:setSelectedItemDescription(itemEnt)
    if itemEnt then
        self.itemDescriptionSelected = populateDescriptionBox(itemEnt)
    else
        self.itemDescriptionSelected = nil
    end
    self.itemDescriptionSelectedTime = 0
end

---@param action lootplot.SlotAction
local function createActionButton(action)
    return StretchableButton({
        onClick = function()
            if (action.canClick and action.canClick()) or (not action.canClick) then
                audio.play("lootplot.sound:click", {volume = 0.35, pitch = 1.1})
                action.onClick()
            else
                audio.play("lootplot.sound:deny_click", {volume = 0.5})
            end
        end,
        text = action.text,
        color = action.color or "orange",
    })
end

---@param actions lootplot.SlotAction[]?
function Scene:setActionButtons(actions)
    -- Remove existing buttons
    for _, b in ipairs(self.slotActionButtons) do
        self:removeChild(b)
    end

    table.clear(self.slotActionButtons)

    -- Add new buttons
    if actions then
        for _, b in ipairs(actions) do
            local button = createActionButton(b)
            self:addChild(button)
            self.slotActionButtons[#self.slotActionButtons+1] = button
        end
    end
end

---@param win boolean
function Scene:showEndGameDialog(win)
    self.endGameDialog:setWinning(win)
    self.renderEndGameDialog = true
end

return Scene
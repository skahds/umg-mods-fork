
local loc = localization.localize
local interp = localization.newInterpolator


---@type generation.Generator
local itemGen

local function generateItem(ent)
    itemGen = itemGen or lp.newItemGenerator()
    local itemName = itemGen
        :query(function(entityType)
            return lp.getDynamicSpawnChance(entityType, ent)
        end)
    return itemName or lp.FALLBACK_NULL_ITEM
end



---@param ent Entity
---@param bool boolean
local function setItemLock(ent, bool)
    ent.itemLock = bool
    sync.syncComponent(ent, "itemLock")
end

local BUY_TEXT = interp("BUY ($%{price})")

---@param slotEnt Entity
local function buyServer(slotEnt)
    local itemEnt = lp.slotToItem(slotEnt)
    if itemEnt then
        lp.subtractMoney(slotEnt, itemEnt.price)
        setItemLock(slotEnt, false)
    end
end

local function buyClient(slotEnt)
    lp.deselectItem()
    local itemEnt = lp.slotToItem(slotEnt)
    if itemEnt then
        lp.selectItem(itemEnt, true)
    end
end


local shopButton = {
    action = function(ent, clientId)
        if server then
            buyServer(ent)
        elseif client then
            buyClient(ent)
        end
    end,
    canDisplay = function(ent, clientId)
        return ent.itemLock
    end,
    canClick = function(ent, clientId)
        local itemEnt = lp.slotToItem(ent)
        if itemEnt and ent.itemLock then
            return lp.getMoney(itemEnt) >= itemEnt.price
        end
    end,
    text = function(ent)
        local itemEnt = lp.slotToItem(ent)
        if not itemEnt then
            return ""
        end
        return BUY_TEXT(itemEnt)
    end,
    color = objects.Color(0.39,0.66,0.24),
}




---@param ent Entity
---@param bool boolean
local function setRerollLock(ent, bool)
    ent.rerollLock = bool
    sync.syncComponent(ent, "rerollLock")
end

local LOCK_TEXT = loc("Lock reroll")
local UNLOCK_TEXT = loc("Unlock reroll")

local lockRerollButton = {
    action = function(ent, clientId)
        if server then
            setRerollLock(ent, not ent.rerollLock)
        end
    end,
    canDisplay = function(ent, clientId)
        return lp.slotToItem(ent)
    end,
    canClick = function(ent, clientId)
        return lp.slotToItem(ent)
    end,
    text = function(ent)
        if ent.rerollLock then
            return UNLOCK_TEXT
        else
            return LOCK_TEXT
        end
    end,
    color = objects.Color(0.7,0.7,0.7),
}



lp.defineSlot("lootplot.s0.content:shop_slot", {
    itemLock = true,
    image = "shop_slot",
    color = {1, 1, 0.6},
    baseMaxActivations = 100,
    name = loc("Shop slot"),
    triggers = {"REROLL", "PULSE"},
    itemSpawner = generateItem,
    itemReroller = generateItem,
    baseCanSlotPropagate = false,
    canPlayerAccessItemInSlot = function(slotEnt, itemEnt)
        return not slotEnt.itemLock
    end,
    onActivate = function(slotEnt)
        setItemLock(slotEnt, true)
    end,
    actionButtons = {
        shopButton
    }
})




lp.defineSlot("lootplot.s0.content:lockable_shop_slot", {
    itemLock = true,

    image = "shop_slot",
    -- TODO: make a different image for this!

    color = {0.8, 0.8, 0.4},
    baseMaxActivations = 100,
    name = loc("Lockable Shop slot"),
    triggers = {"REROLL", "PULSE"},
    itemSpawner = generateItem,
    itemReroller = generateItem,
    baseCanSlotPropagate = false,
    canActivate = function(ent)
        -- if rerollLock=true, then we dont activate!
        return ent.rerollLock
    end,
    canPlayerAccessItemInSlot = function(slotEnt, itemEnt)
        return not slotEnt.itemLock
    end,
    onActivate = function(slotEnt)
        setItemLock(slotEnt, true)
    end,
    actionButtons = {
        shopButton,
        lockRerollButton
    }
})




lp.defineSlot("lootplot.s0.content:reroll_slot", {
    image = "reroll_slot",
    name = loc("Reroll slot"),
    description = loc("Put an item inside to reroll it!"),
    triggers = {"REROLL", "PULSE"},
    itemReroller = generateItem,
    baseCanSlotPropagate = false,
    baseMaxActivations = 500,
})



lp.defineSlot("lootplot.s0.content:lockable_reroll_slot", {
    image = "reroll_slot",
    -- TODO ^^^ different image pls!

    name = loc("Reroll slot"),
    description = loc("Put an item inside to reroll it!"),
    triggers = {"REROLL", "PULSE"},
    itemReroller = generateItem,
    baseCanSlotPropagate = false,
    baseMaxActivations = 500,
    canActivate = function(ent)
        return ent.rerollLock
    end,
    actionButtons = {
        lockRerollButton
    }
})

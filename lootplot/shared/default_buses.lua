

local calls = {
    COMBO = "lootplot:comboChanged",
    POINTS = "lootplot:pointsChanged",
    POINTS_MULT = "lootplot:multChanged",
    MONEY = "lootplot:moneyChanged",
}

umg.on("lootplot:attributeChanged", function(attr, ent, delta, oldVal, newVal)
    if calls[attr] then
        umg.call(calls[attr], ent, delta, oldVal, newVal)
    end
end)



local function getVal(ent, val)
    if type(val) == "function" then
        return val(ent)
    end
    return val
end

local function getMult(ent, propTabl, prop)
    if propTabl.multipliers then
        local val = propTabl.multipliers[prop]
        if val then
            return getVal(ent, val)
        end
    end
    return 1
end

local function getModifier(ent, propTabl, prop)
    if propTabl.modifiers then
        local val = propTabl.modifiers[prop]
        if val then
            return getVal(ent, val)
        end
    end
    return 0
end


local function getClamp(ent, propTabl, prop)
    local min, max = -math.huge, math.huge

    if propTabl.maximums then
        local val = propTabl.maximums[prop]
        if val then
            max = getVal(ent, val)
        end
    end

    if propTabl.minimums then
        local val = propTabl.minimums[prop]
        if val then
            min = getVal(ent, val)
        end
    end

    return min, max
end


-- LOOTPLOT PROPERTIES:
umg.answer("properties:getPropertyMultiplier", function(ent, prop)
    if ent.lootplotProperties then
        return getMult(ent, ent.lootplotProperties, prop)
    end
end)
umg.answer("properties:getPropertyModifier", function(ent, prop)
    if ent.lootplotProperties then
        return getModifier(ent, ent.lootplotProperties, prop)
    end
    return 0
end)
umg.answer("properties:getPropertyClamp", function(ent, prop)
    local min, max = -math.huge, math.huge
    if ent.lootplotProperties then
        return getClamp(ent, ent.lootplotProperties, prop)
    end
    return min, max
end)



-- BUFFED PROPERTIES:
umg.answer("properties:getPropertyMultiplier", function(ent, prop)
    if ent.buffedProperties then
        return getMult(ent, ent.buffedProperties, prop)
    end
    return 1
end)
umg.answer("properties:getPropertyModifier", function(ent, prop)
    if ent.buffedProperties then
        return getModifier(ent, ent.buffedProperties, prop)
    end
    return 0
end)
umg.answer("properties:getPropertyClamp", function(ent, prop)
    local min, max = -math.huge, math.huge
    if ent.buffedProperties then
        return getClamp(ent, ent.buffedProperties, prop)
    end
    return min, max
end)




umg.answer("lootplot:hasPlayerAccess", function(ent, clientId)
    local ppos = lp.getPos(ent)
    local team = lp.getPlayerTeam(clientId)
    if ppos then
        local plot = ppos:getPlot()
        if plot:isPipelineRunning() then
            return false
        end

        if team then
            return plot:isFogRevealed(ppos, team)
        end
    end
    print("hasPlayerAccess", ent, clientId, ppos, team)
    return true
end)




umg.answer("lootplot:canAddItem", function(itemEnt, ppos)
    local slot = lp.posToSlot(ppos)
    if slot then
        -- button slots cant hold items!
        return not slot:hasComponent("buttonSlot")
    end
    return true -- else, its fine
end)


umg.answer("lootplot:canRemoveItem", function(itemEnt, ppos)
    return not itemEnt.stuck
end)



umg.answer("lootplot:canActivateEntity", function(ent)
    local money = lp.getMoney(ent)
    if money and ent.moneyGenerated and ent.moneyGenerated<0 then
        if ent.moneyGenerated + money < 0 then
            return false
        end
    end
    return true
end)



umg.answer("lootplot:canActivateEntity", function(ent)
    return (ent.activationCount or 0) < (ent.maxActivations or -1)
end)



if server then
    
umg.on("lootplot:entityActivated", function(ent)
    if ent.multGenerated and ent.multGenerated ~= 0 then
        lp.addPointsMult(ent, ent.multGenerated)
    end

    if ent.bonusGenerated and ent.bonusGenerated ~= 0 then
        lp.addPointsBonus(ent, ent.bonusGenerated)
    end

    if ent.pointsGenerated and ent.pointsGenerated ~= 0 then
        lp.addPoints(ent, ent.pointsGenerated)
    end

    if ent.moneyGenerated and ent.moneyGenerated ~= 0 then
        lp.addMoney(ent, ent.moneyGenerated)
    end

    if ent.grubMoneyCap then
        local money = lp.getMoney(ent)
        if money and money >= ent.grubMoneyCap then
            local delta = money - ent.grubMoneyCap
            lp.subtractMoney(ent, delta)
        end
    end
end)



local FIRST_ORDER = -0xffffffffffff
umg.on("lootplot:entityActivated", FIRST_ORDER, function(ent)
    if ent.doomCount then
        ent.doomCount = ent.doomCount - 1
        local ppos = lp.getPos(ent)
        if ppos and ent.doomCount <= 0 then
            lp.queue(ppos, function()
                if umg.exists(ent) then
                    lp.destroy(ent)
                end
            end)
        end
    end
end)



-- sticky/stuck:
umg.on("lootplot:entityActivated", function(ent)
    if ent.sticky and lp.isItemEntity(ent) then
        ent.stuck = true
    end

    if ent.stickySlot and lp.isSlotEntity(ent) then
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            itemEnt.stuck = true
        end
    end
end)



umg.on("lootplot:entityDestroyed", function(ent)
    -- TODO: Maybe we should ask: `lootplot:shouldReviveEntity` here..?
    -- instead of just checking `.lives` directly.
    ----
    -- That would allove for future systems to revive entities, 
    -- in whatever way they want.
    if ent.lives and ent.lives > 0 then
        ent.lives = ent.lives - 1
        local ppos = lp.getPos(ent)
        if not ppos then
            return
        end

        local cloneEnt = ent:clone()

        if cloneEnt.doomCount and cloneEnt.doomCount <= 0 then
            -- HACK: Set doomCount directly here.
            -- For future, we prolly wanna be emitted event-bus, 
            -- like `lootplot:entityRevived` or something.
            cloneEnt.doomCount = 1
        end
        if lp.isSlotEntity(ent) then
            lp.setSlot(ppos, cloneEnt)
        elseif lp.isItemEntity(ent) then
            local ok = lp.forceSetItem(ppos, cloneEnt)
            if not ok then
                cloneEnt:delete()
            end
        else
            umg.log.warn("`.lives` component doesn't work on this ent: ", ent)
        end
    end
end)



end



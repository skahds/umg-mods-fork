

--[[

floating-item system

(handles deletion of items that dont have a slot.)

]]


local TIMEOUT = 1 -- after this amount of time;
-- if an item STILL does not have a slot, then we will delete it.



local timeouts = setmetatable({--[[
    [itemEnt] -> timeWithoutSlot
]]}, {__mode="k"})


local itemGroup = umg.group("item")


local function isInvalid(itemEnt, ppos)
    if not ppos then
        -- the item isn't in a plot... I guess we assume its valid?
        -- maybe modder is storing it somewhere on purpose??

        -- HMMM:  Maybe we should be returning `false` here?
        -- Items are invalid without a ppos...
        return true
    end

    local slotEnt = lp.posToSlot(ppos)
    if slotEnt then
        -- its valid if the slot can hold the item
        return not lp.couldHoldItem(slotEnt, itemEnt)
    else
        -- No slot. Valid if the item can float
        return not lp.canItemFloat(itemEnt)
    end
end


umg.on("@tick", scheduling.skip(3, function()
    local time = umg.getWorldTime()
    for _, itemEnt in ipairs(itemGroup)do
        local ppos = lp.getPos(itemEnt)
        if isInvalid(itemEnt, ppos) then
            -- welp, start timeout!
            timeouts[itemEnt] = timeouts[itemEnt] or time
        else
            -- reset.
            timeouts[itemEnt] = nil
        end
    end

    for itemEnt, t in pairs(timeouts) do
        if t + TIMEOUT > time then
            if umg.exists(itemEnt) then
                lp.destroy(itemEnt)
            end
        end
    end
end))

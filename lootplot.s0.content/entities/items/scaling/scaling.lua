local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")



local function defItem(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end


local function defineHelmet(id, etype)
    etype.rarity = etype.rarity or lp.rarities.RARE
    etype.shape = etype.shape or lp.targets.KingShape(1)

    etype.basePrice = etype.basePrice or 10
    etype.baseMaxActivations = etype.baseMaxActivations or 1

    defItem(id,etype)
end





defineHelmet("iron_helmet", {
    name = loc("Iron Helmet"),

    triggers = {"PULSE"},

    basePrice = 10,
    mineralType = "iron",

    target = {
        type = "ITEM",
        description = interp("Buff all target items: +2 points."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 2, selfEnt)
        end,
    }
})



defItem("moon_knife", {
    name = loc("Moon Knife"),
    activateDescription = loc("Gain 1 point permanently"),

    triggers = {"PULSE"},

    basePointsGenerated = -10,
    rarity = lp.rarities.UNCOMMON,

    basePrice = 9,

    baseMaxActivations = 3,

    onActivate = function(ent)
        lp.modifierBuff(ent, "pointsGenerated", 1)
    end
})



defineHelmet("ruby_helmet", {
    name = loc("Ruby Helmet"),

    triggers = {"PULSE"},

    basePrice = 12,

    mineralType = "ruby",

    target = {
        type = "ITEM",
        description = loc("Buff all target items:\n+1 activations. (Capped at 20)"),
        activate = function(selfEnt, ppos, targetEnt)
            if (targetEnt.maxActivations or 0) < 20 then
                lp.modifierBuff(targetEnt, "maxActivations", 1, selfEnt)
            end
        end,
        filter = function(selfEnt, ppos, targetEnt)
            return (targetEnt.maxActivations or 0) < 20
        end
    },
})



local function hasRerollTrigger(ent)
    if ent.triggers then
        for _,t in ipairs(ent.triggers) do
            if t == "REROLL" then
                return true
            end
        end
    end
    return false
end

defineHelmet("emerald_helmet", {
    name = loc("Emerald Helmet"),

    triggers = {"REROLL"},

    basePrice = 10,
    mineralType = "emerald",

    target = {
        type = "ITEM",
        description = loc("If target has {lootplot:TRIGGER_COLOR}REROLL trigger{/lootplot:TRIGGER_COLOR}, buff target {lootplot:POINTS_MOD_COLOR}+5 points."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 5, selfEnt)
        end,
        filter = function(selfEnt, ppos, targetEnt)
            return hasRerollTrigger(targetEnt)
        end
    }
})


defineHelmet("doom_helmet", {
    name = loc("Doom Helmet"),

    triggers = {"PULSE"},

    activateDescription = loc("Give all targetted items on {lootplot:DOOMED_COLOR}DOOMED{/lootplot:DOOMED_COLOR} slots {lootplot:POINTS_MOD_COLOR}+3 points."),

    basePrice = 14,

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targItem)
            local slotEnt = lp.posToSlot(ppos)
            return slotEnt and slotEnt.doomCount
        end,
        activate = function (selfEnt, ppos, targItem)
            lp.modifierBuff(targItem, "pointsGenerated", 3, selfEnt)
        end
    },

    rarity = lp.rarities.EPIC,
})


defineHelmet("demon_helmet", {
    name = loc("Demon Helmet"),

    activateDescription = loc("Give all targetted {lootplot:REPEATER_COLOR}REPEATER{/lootplot:REPEATER_COLOR} items {lootplot:POINTS_MOD_COLOR}+4 points"),
    triggers = {"PULSE"},

    basePrice = 12,

    repeatActivations = true,
    baseMaxActivations = 1,

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targItem)
            return targItem.repeatActivations
        end,
        activate = function (selfEnt, ppos, targItem)
            lp.modifierBuff(targItem, "pointsGenerated", 10, selfEnt)
        end
    },

    rarity = lp.rarities.EPIC,
})




--[[

TODO:
teal helmet

]]

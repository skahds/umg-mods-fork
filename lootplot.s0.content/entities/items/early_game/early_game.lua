
local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")


local function defItem(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end




--[[
Rock-items give the user good intuition behind how the
destroy-lives systems interact with each other.
]]
defItem("rocks", {
    name = loc("Rocks"),
    basePrice = 3,
    basePointsGenerated = 15,

    lives = 1,
    rarity = lp.rarities.COMMON,
    triggers = {"DESTROY"},
})




local NUM_KEY_ACTS = 10
helper.defineTransformItem("key_bar", "Key Bar", {
    transformId = "key",
    transformName = "Key",
    delayCount = NUM_KEY_ACTS,

    triggers = {"PULSE"},

    basePrice = 4,
    baseMaxActivations = 2,
    basePointsGenerated = 5,

    rarity = lp.rarities.COMMON,
})


--[[
Purpose of STICK is to give intuition
about how multiple triggers work. (REROLL, PULSE trigger)
]]
defItem("stick", {
    image = "stick",
    name = loc("Stick"),

    triggers = {"REROLL", "PULSE"},

    rarity = lp.rarities.COMMON,

    basePointsGenerated = 4,
    basePrice = 2,
})




--[[
Leather's "purpose" is to give intuition about the `mult` system.
]]
defItem("leather", {
    name = loc("Leather"),
    description = loc("Has a 3x points multiplier!"),
    grubMoneyCap = 10,

    rarity = lp.rarities.COMMON,

    lootplotProperties = {
        multipliers = {
            pointsGenerated = 3
        }
    },

    basePrice = 4,

    baseMaxActivations = 15,

    basePointsGenerated = 5,

    triggers = {"PULSE"},
})



--[[
purpose is to give intuition about how target-system works
]]
defItem("net", {
    name = loc("Net"),

    rarity = lp.rarities.COMMON,

    basePrice = 3,

    listen = {
        trigger = "PULSE"
    },
    shape = lp.targets.KING_SHAPE,

    baseMaxActivations = 8,

    basePointsGenerated = 2,
})



local COINS_DESC = interp("20% Chance to earn {lootplot:MONEY_COLOR}$1.\n{wavy}TOTAL EARNED: $%{totalEarned}")
defItem("coins", {
    name = loc("Coins"),
    init = function(ent)
        ent.totalEarned = 0
    end,
    activateDescription = function(ent)
        return COINS_DESC({
            totalEarned = ent.totalEarned
        })
    end,

    rarity = lp.rarities.COMMON,

    basePointsGenerated = 5,
    baseMaxActivations = 2,
    basePrice = 4,

    onActivate = function(ent)
        if lp.SEED:randomMisc()<=0.20 then
            lp.addMoney(ent, 1)
            ent.totalEarned = ent.totalEarned + 1
            sync.syncComponent(ent, "totalEarned")
        end
    end,

    triggers = {"PULSE"},
})






lp.defineItem("lootplot.s0.content:bone", {
    image = "bone",

    description = loc("Has 6 lives."),

    name = loc("Bone"),

    basePrice = 0,

    lives = 6,
    rarity = lp.rarities.UNCOMMON,

    triggers = {"PULSE"},
})





--[[

The purpose of pink-guppy is to make players more aware of
the existance of octopus.

Because in reality, octopus is VERY CENTRAL to the game.

]]
local GUPPY_COUNT = 8

helper.defineTransformItem("pink_guppy", "Pink Guppy", {
    transformId = "pink_octopus",
    transformName = "Pink Octopus",
    delayCount = GUPPY_COUNT,

    basePrice = 4,
    baseMaxActivations = 2,
    basePointsGenerated = 5,

    rarity = lp.rarities.COMMON,

    triggers = {"PULSE"},
})



--[[
Green-guppy = pink-guppy but green-octopus instead.
]]
helper.defineTransformItem("green_guppy", "Green Guppy", {
    transformId = "green_octopus",
    transformName = "Green Octopus",
    delayCount = GUPPY_COUNT,

    triggers = {"REROLL"},

    basePrice = 4,
    baseMaxActivations = 2,
    basePointsGenerated = 5,

    rarity = lp.rarities.COMMON,
})






local activateToot, dedToot
if client then
    local dirObj = umg.getModFilesystem()
    audio.defineAudioInDirectory(
        dirObj:cloneWithSubpath("entities/items/early_game/sounds"), "lootplot.s0.content:", {"audio:sfx"}
    )
    activateToot = sound.Sound("lootplot.s0.content:trumpet_toot")
    dedToot = sound.Sound("lootplot.s0.content:trumpet_destroyed")
end

lp.defineItem("lootplot.s0.content:trumpet", {
    image = "trumpet",
    name = loc("Trumpet"),
    activateDescription = loc("Makes a toot sound"),
    rarity = lp.rarities.COMMON,

    triggers = {"PULSE"},

    baseMaxActivations = 10,
    basePrice = 3,

    basePointsGenerated = 5,

    -- just for the funni
    onActivateClient = function(ent)
        activateToot:play(ent, 0.6, 1 + math.random()/2)
    end,
    onDestroyClient = function(ent)
        dedToot:play(ent, 1, 1 + math.random()/2)
    end,
})



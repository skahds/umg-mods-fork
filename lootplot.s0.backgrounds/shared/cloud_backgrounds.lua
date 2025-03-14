
local sunsetCtor = nil
local cherryCtor = nil
local skyCtor = nil
local popcornCtor = nil
local tealCtor = nil
local abstractCtor = nil
local voidCtor = nil


if client then

local CloudBackground = require("client.CloudBackground")

local W,H = 3000,1500
-- HACK: kinda hacky, hardcode plot offset
local minsize = 40
local DELTA = (minsize * lp.constants.WORLD_SLOT_DISTANCE) / 2

function skyCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100,

        backgroundColor = objects.Color("#FF8FA1FF"),
        cloudColor = objects.Color("#FF8FA1FF"),
    })
end

function cherryCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100,

        backgroundColor = objects.Color("#FFFFC2EE"),
        cloudColor = objects.Color("#FFFFC2EE"),
    })
end

function sunsetCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100,

        backgroundColor = objects.Color("#FFFFCA91"),
        cloudColor = objects.Color("#FFFFCA91"),
        -- backgroundColor = objects.Color("#FFFFE8C8"),
        -- cloudColor = objects.Color("#FFFFE8C8"),
    })
end


function popcornCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100,

        backgroundColor = objects.Color("#" .. "FFFDFAA3"),
        cloudColor = objects.Color("#" .. "FFFDFAA3"),
    })
end


function voidCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 0,

        backgroundColor = objects.Color("#FF370354"),
        cloudColor = objects.Color("#FF370354"),
    })
end


function tealCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100,

        backgroundColor = objects.Color("#FF53E2AF"),
        cloudColor = objects.Color("#FF53E2AF"),
    })
end

end

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:sky_cloud_background", {
    name = localization.localize("Default"),
    constructor = skyCtor,
    icon = "sky_cloud_background"
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:cherry_background", {
    name = localization.localize("Cherry"),
    constructor = cherryCtor,
    icon = "cherry_cloud_background"
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:sunset_background", {
    name = localization.localize("Sunset"),
    constructor = sunsetCtor,
    icon = "sunset_cloud_background"
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:teal_background", {
    name = localization.localize("Teal"),
    constructor = tealCtor,
    icon = "teal_cloud_background"
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:popcorn_background", {
    name = localization.localize("Popcorn"),
    constructor = popcornCtor,
    icon = "popcorn_background",
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:void_background", {
    name = localization.localize("Void"),
    constructor = voidCtor,
    icon = "void_background",
    fogColor = objects.Color("#" .. "FF250732")
})



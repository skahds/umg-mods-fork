


local options = require("shared.options")


properties.defineProperty("speed", {
    base = "baseSpeed",
    default = options.DEFAULT_SPEED,
    shouldComputeClientside = true,

    getModifier = function(ent)
        return umg.ask("spatial:getSpeedModifier", ent) or 0
    end,
    getMultiplier = function(ent)
        return umg.ask("spatial:getSpeedMultiplier", ent) or 1
    end
})

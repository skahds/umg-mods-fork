
lp.defineItem("pomegranate", {
    image = "pomegranate",

    name = "pomegranate",
    description = "Generate slots",
    baseBuyPrice = 5,

    targetShape = lp.targets.KING_SHAPE,

    targetType = "NO_SLOT",
    activateTargets = function(ent, ppos, targetEnt)
        local e = lp.trySpawnSlot(ppos, server.entities.slot)
        if e then

            --[[
                TODO: THIS IS ABSOLUTE DOG WATER!
                We shouldn't be setting .ownerPlayer component in here.
                There should be an easier api to automatically inherit, or something.

                We should make it as easy as possible to spawn items and slots.
            ]]
            e.ownerPlayer = ent.ownerPlayer
        end
    end,
})


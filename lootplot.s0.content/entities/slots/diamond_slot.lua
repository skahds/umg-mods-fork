local loc = localization.localize

return lp.defineSlot("lootplot.s0.content:diamond_slot", {
    image = "diamond_slot",
    name = loc("Diamond slot"),
    description = loc("Item gets a {lootplot:POINTS_MULT_COLOR}5 x POINTS-MULTIPLIER{/lootplot:POINTS_MULT_COLOR}."),
    baseMaxActivations = 100,
    triggers = {"PULSE"},
    slotItemProperties = {
        multipliers = {
            pointsGenerated = 5
        }
    },
})


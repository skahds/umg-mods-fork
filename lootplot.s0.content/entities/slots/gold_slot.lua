local loc = localization.localize


return lp.defineSlot("lootplot.s0.content:golden_slot", {
    image = "golden_slot",
    name = loc("Golden slot"),
    baseMoneyGenerated = 1,
    triggers = {"PULSE"},
})


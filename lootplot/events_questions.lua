

umg.defineEvent("lootplot:itemAddedToSlot")
umg.defineEvent("lootplot:itemRemovedFromSlot")



umg.defineEvent("lootplot:plotActivated")


umg.defineEvent("lootplot:entityActivated")

umg.defineEvent("lootplot:entityRerolled")


umg.defineEvent("lootplot:moneyAdded")
umg.defineEvent("lootplot:moneySubtracted")
umg.defineEvent("lootplot:moneyChanged")

umg.defineEvent("lootplot:pointsAdded")
umg.defineEvent("lootplot:pointsSubtracted")
umg.defineEvent("lootplot:pointsChanged")



umg.defineQuestion("lootplot:isActivationBlocked", reducers.OR)


umg.defineQuestion("lootplot:getMoneyMultiplier", reducers.MULTIPLY)
umg.defineQuestion("lootplot:getPointMultiplier", reducers.MULTIPLY)


umg.defineQuestion("lootplot:getPipelineDelayMultiplier", reducers.MULTIPLY)
umg.defineQuestion("lootplot:getPipelineDelay", reducers.ADD)


umg.defineQuestion("lootplot:isItemRemovalBlocked", reducers.OR)
umg.defineQuestion("lootplot:isItemAdditionBlocked", reducers.OR)

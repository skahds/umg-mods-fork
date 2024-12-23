local loc = localization.localize



local function defineCard(name, cardEType)
    cardEType.image = cardEType.image or name
    cardEType.rarity = cardEType.rarity or lp.rarities.RARE
    if not cardEType.listen then
        cardEType.triggers = cardEType.triggers or {"PULSE"}
    end

    cardEType.baseMaxActivations = 1
    cardEType.basePrice = cardEType.basePrice or 10

    lp.defineItem("lootplot.s0.content:" .. name, cardEType)
end


local function shuffled(tabl)
    local shufTabl = {}
    local len = #tabl
    for i=1,#tabl do
        local newIndex = (i % len) + 1
        shufTabl[newIndex] = tabl[i]
    end
    return shufTabl
end


---@param tabl Entity[]
---@param shufFunc fun(e:Entity, e2:Entity)
local function apply(tabl, shufFunc)
    for i=1, #tabl-1, 2 do
        local e1, e2 = tabl[i], tabl[i+1]
        shufFunc(e1, e2)
    end
end




defineCard("star_card", {
    name = loc("Star Card"),

    rarity = lp.rarities.LEGENDARY,

    shape = lp.targets.VerticalShape(1),

    target = {
        type = "ITEM",
        description = loc("Shuffle shapes between target items"),
    },

    onActivate = function(selfEnt)
        local targets = lp.targets.getShapePositions(selfEnt)
        if not targets then
            return
        end

        local itemEntities = {}
        local itemEntShapes = {}

        for _, ppos in ipairs(targets) do
            local itemEnt = lp.posToItem(ppos)
            if itemEnt then
                itemEntities[#itemEntities+1] = itemEnt
                itemEntShapes[#itemEntities] = itemEnt.shape
            end
        end

        -- Shuffle shapes
        itemEntShapes = shuffled(itemEntShapes)

        -- Assign shapes
        for i, itemEnt in ipairs(itemEntities) do
            if itemEnt.shape ~= itemEntShapes[i] then
                lp.targets.setShape(itemEnt, itemEntShapes[i])
            end
        end
    end
})


defineCard("hearts_card", {
    name = loc("Hearts Card"),
    shape = lp.targets.VerticalShape(1),
    target = {
        type = "ITEM",
        description = loc("Shuffle lives between target items"),
    },

    onActivate = function(selfEnt)
        local targets = shuffled(
            lp.targets.getShapePositions(selfEnt):map(lp.posToItem)
        )
        apply(targets, function(e1,e2)
            local l1 = e1.lives or 0
            local l2 = e2.lives or 0
            e1.lives = l2
            e2.lives = l1
        end)
    end,

    rarity = lp.rarities.EPIC
})


defineCard("mana_card", {
    name = loc("Mana Card"),
    shape = lp.targets.VerticalShape(1),

    target = {
        type = "SLOT",
        description = loc("Shuffle {lootplot.mana:LIGHT_MANA_COLOR}mana{/lootplot.mana:LIGHT_MANA_COLOR} between target slots"),
    },

    onActivate = function(selfEnt)
        local targets = shuffled(
            lp.targets.getShapePositions(selfEnt):map(lp.posToSlot)
        )
        apply(targets, function(e1,e2)
            local m1 = e1.manaCount or 0
            local m2 = e2.manaCount or 0
            e1.manaCount = m2
            e2.manaCount = m1
        end)
    end,

    rarity = lp.rarities.RARE
})




defineCard("price_card", {
    name = loc("Price Card"),

    shape = lp.targets.UP_SHAPE,

    doomCount = 10,

    target = {
        type = "ITEM",
        description = loc("Increase item price by 20%"),
        filter = function(targetEnt)
            return targetEnt.price
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local mod = targetEnt.price * 0.2
            lp.modifierBuff(targetEnt, "price", mod, selfEnt)
        end
    },

    rarity = lp.rarities.EPIC,
})


defineCard("spades_card", {
    name = loc("Spades Card"),

    shape = lp.targets.UpShape(2),

    target = {
        type = "ITEM",
        description = loc("Shuffle positions of target items"),
    },

    onActivate = function(selfEnt)
        local targets = lp.targets.getShapePositions(selfEnt)
        if not targets then
            return
        end

        local slots = targets:map(lp.posToSlot)
        slots = shuffled(slots)

        -- Swap item positions
        for i = 1, #slots - 1 do
            local s1 = slots[i]
            local s2 = slots[i + 1]
            local s1p = lp.getPos(s1)
            local s2p = lp.getPos(s2)
            if s1p and s2p and lp.canSwapItems(s1p, s2p) then
                lp.swapItems(s1p, s2p)
            end
        end
    end
})

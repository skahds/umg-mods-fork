
---@alias lootplot.rarities.Rarity {id:string, color:objects.Color, index:number, name:string, rarityWeight:number, displayString:string}
---@return lootplot.rarities.Rarity
local function newRarity(id, name, rarity_weight, color)
    local cStr = localization.localize("{wavy}{c r=%f g=%f b=%f}%{name}{/c}{/wavy}", {
        name = name
    }):format(color.r, color.g, color.b)

    local rarity = {
        id = id,
        color = color,
        index = 1,
        name = name,
        rarityWeight = rarity_weight,
        displayString = cStr
    }

    umg.register(rarity, "lootplot.rarities:" .. name)
    return rarity
end



local function hsl(h,s,l)
    return objects.Color(0,0,0)
        :setHSL(h,s/100,l/100)
end


umg.answer("lootplot:getConstantSpawnWeightMultiplier", function(etype)
    local rarity = etype.rarity
    ---@cast rarity lootplot.rarities.Rarity
    if rarity then
        return rarity.rarityWeight
    end
    return 1
end)




if client then
    local ORDER = 50
    umg.on("lootplot:populateDescription", ORDER, function(ent, arr)
        local rarity = ent.rarity
        if rarity then
            local descString = localization.localize("Rarity") .. ": " .. rarity.displayString
            ---@cast rarity lootplot.rarities.Rarity
            if rarity then
                arr:add(descString)
            end
        end
    end)
end



---Can override rarities in this table:
---
---Availability: Client and Server
lp.rarities = {
    COMMON = newRarity("COMMON", "COMMON (I)", 2, hsl(110, 35, 55)),
    UNCOMMON = newRarity("UNCOMMON", "UNCOMMON (II)", 1.5, hsl(150, 66, 55)),
    RARE = newRarity("RARE", "RARE (III)", 1, hsl(220, 90, 55)),
    EPIC = newRarity("EPIC", "EPIC (IV)", 0.6, hsl(275, 100,45)),
    LEGENDARY = newRarity("LEGENDARY", "LEGENDARY (V)",0.1, hsl(330, 100, 35)),
    MYTHIC = newRarity("MYTHIC", "MYTHIC (VI)", 0.02, hsl(50, 90, 40)),

    -- Use this rarity when you dont want an item to spawn naturally.
    -- (Useful for easter-egg items, or items that can only be spawned by other items)
    UNIQUE = newRarity("UNIQUE", "UNIQUE", 0.00, objects.Color.WHITE),
}

local RARITY_LIST = objects.Array()

for _,r in pairs(lp.rarities) do
    RARITY_LIST:add(r)
end
RARITY_LIST:sortInPlace(function(a, b)
    return a.rarityWeight > b.rarityWeight
end)

---@type lootplot.rarities.Rarity[] | objects.Array
lp.rarities.RARITY_LIST = RARITY_LIST


---Availability: Client and Server
---@param r1 lootplot.rarities.Rarity
---@return number rarity weight of the rarity object. Lower means more rare.
function lp.rarities.getWeight(r1)
    return r1.rarityWeight
end


local function assertServer()
    if not server then
        umg.melt("This can only be called on client-side!", 3)
    end
end

--- Availability: Server
---@param ent Entity
---@param rarity lootplot.rarities.Rarity
function lp.rarities.setEntityRarity(ent, rarity)
    assertServer()
    ent.rarity = rarity
    sync.syncComponent(ent, "rarity")
end



local shiftTc = typecheck.assert("table", "number")


--- Availability: Client and Server
---@param rarity lootplot.rarities.Rarity
---@param delta number
---@return lootplot.rarities.Rarity
function lp.rarities.shiftRarity(rarity, delta)
    shiftTc(rarity, delta)
    if rarity.rarityWeight == 0 or rarity == lp.rarities.UNIQUE then
        -- cannot shift UNIQUE rarity. (That would be weird)
        return rarity
    end
    for i,r in ipairs(RARITY_LIST) do
        if r.rarityWeight == rarity.rarityWeight then
            local choice = math.clamp(i + delta, 1, #RARITY_LIST)
            return RARITY_LIST[choice]
        end
    end
    -- FAILED!
    return rarity
end



local configured = false
---@param levelRarities table<lootplot.rarities.Rarity, integer>
function lp.rarities.configureLevelSpawningLimits(levelRarities)
    if configured then
        return
    end

    configured = true
    umg.answer("lootplot:getDynamicSpawnChance", function(etype, generationEnt)
        local level = lp.getLevel(generationEnt) or 0
        ---@cast etype +table<string, any>

        local minLevel = levelRarities[etype.rarity] or 0
        if level and (level < minLevel) then
            return 0
        end
        return 1
    end)
end



---@type {[string]: generation.Generator}
local genCache = {}

local function createGenerator(rarity)
    lp.newItemGenerator({
        filter = function(etypeName, _)
            local etype = server.entities[etypeName]
            if etype and etype.rarity and etype.rarity.id == rarity.id then
                return true
            end
            return false
        end
    })
end

local function dummy()
    return 1
end

---@param rarity lootplot.rarities.Rarity
---@param generationEnt Entity
---@param extraPickChance? generation.PickChanceFunction Function that returns the chance of an item being picked. 1 means pick always, 0 means fully skip this item (filtered out), anything inbetween is the chance of said entry be accepted or be rerolled.
---@return (fun(...): Entity)?
function lp.rarities.randomItemOfRarity(rarity, generationEnt, extraPickChance)
    local gen = genCache[rarity] or createGenerator(rarity)
    extraPickChance = extraPickChance or dummy
    assert(extraPickChance ~= lp.getDynamicSpawnChance, "Shouldnt pass this in! Its already called!!")
    ---@cast gen generation.Generator
    local etypeName = gen:query(function(entry, weight)
        return (extraPickChance(entry, weight) or 1) * lp.getDynamicSpawnChance(entry, generationEnt)
    end)
    return server.entities[etypeName]
end

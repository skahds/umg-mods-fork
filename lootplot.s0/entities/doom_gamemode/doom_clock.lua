
--[[


- Doom-clock (item)
Provides win/lose conditions

]]

local loc = localization.localize




local K = 1000 -- 1k
local M = 1000000 -- 1m

local POINT_REQUIREMENTS = {
    [0] = {
        -- EASY: level 6
        60, 400, 1500,  4*K,  15*K, 40*K,              200*K, 600*K, 1000000, 2000000
    },

    [1] = {
        -- NORMAL: level 7 
        80, 600, 3*K,  6*K,  25*K, 160*K, 1*M,                  2*M, 4*M, 6*M
    },

    [2] = {
        -- HARD: level 8
        100, 900, 5*K, 10*K, 50*K, 0.4*M, 2*M, 5*M,                   8*M, 20*M
    }
}




local function makePretty(num)
    --[[
    132 --> 130
    67043 --> 67000
    12 --> 12
    1349545442335 --> 13000000000
    etc
    ]]
    local numZeros = math.floor(math.log(num, 10))
    local floorVal = 10 ^ (numZeros)
    return math.floor(num / floorVal) * floorVal
end


---@param ent Entity
local function getRequiredPoints(ent)
    local level = lp.getLevel(ent)
    local difficulty, dInfo = lp.getDifficulty()
    local tabl
    if POINT_REQUIREMENTS[dInfo.difficulty] then
        tabl = POINT_REQUIREMENTS[dInfo.difficulty]
    else
        tabl = POINT_REQUIREMENTS[2]
    end

    if tabl and tabl[level] then
        return tabl[level]
    end

    local GROWTH_PER_LEVEL = 3
    local number = (GROWTH_PER_LEVEL^(level)) * 100
    return makePretty(number)
end






--[[
for lv=1, 10 do
    print("LEVEL POINTS:",lv,getRequiredPoints(lv))
end
]]


--[[
    This code tries to relocate the doom clock if ther are slot or item below it.
]]
-- Plots to be tested for heurestic search
local SEARCH_SIZE = 2 -- 1 = 3x3, 2 = 5x5, 3 = 7x7, and so on.
local ORDER_SEARCH = lp.targets.KingShape(SEARCH_SIZE)
table.insert(ORDER_SEARCH.relativeCoords, {0, 0}) -- Include center

table.sort(ORDER_SEARCH.relativeCoords, function (a, b)
    local d1 = math.sqrt(a[1] * a[1] + a[2] * a[2])
    local d2 = math.sqrt(b[1] * b[1] + b[2] * b[2])
    return d1 < d2
end)

local function moveClockToClearPosition(ent)
    local ppos = lp.getPos(ent)
    if not ppos then return end
    local plot = ppos:getPlot()

    for _, relpos in ipairs(ORDER_SEARCH.relativeCoords) do
        local px = ent._plotX + relpos[1]
        local py = ent._plotY + relpos[2]

        if px >= 0 and py >= 0 then
            local ppos = plot:getPPos(px, py)

            if not (lp.posToItem(ppos) or lp.posToSlot(ppos)) then
                -- Move it here
                ent.x, ent.y, ent.dimension = ppos:getWorldPos()
                return
            end
        end
    end
end



umg.defineEntityType("lootplot.s0:doom_clock", {
    image = "doom_clock",
    layer = "world",

    onUpdateServer = function(ent)
        local currentRequiredPoints = lp.getRequiredPoints(ent)
        local neededRequiredPoints = getRequiredPoints(ent)

        if currentRequiredPoints ~= neededRequiredPoints then
            lp.setAttribute("REQUIRED_POINTS", ent, neededRequiredPoints)
        end
    end,

    onUpdateClient = moveClockToClearPosition,
})



local function makeSparkPS(count)
    local spark = love.graphics.newParticleSystem(client.atlas:getTexture(), count)
    spark:setQuads(
        assert(client.assets.images.spark_1),
        assert(client.assets.images.spark_2),
        assert(client.assets.images.spark_3)
    )
    spark:setParticleLifetime(0.1, 0.5)
    spark:setEmissionArea("ellipse", 10, 10, 0, true)
    spark:setRotation(0, math.pi * 2)
    spark:setLinearDamping(5, 10)
    spark:setSpeed(-55, 55)
    spark:setColors(objects.Color.YELLOW)
    return spark
end

local function makeSpark(ent, count)
    local newEnt = client.entities.empty()
    newEnt.x, newEnt.y = ent.x, ent.y
    newEnt.dimension = ent.dimension
    newEnt.lifetime = 0.5
    -- ^^^ delete self after X seconds
    local ps = makeSparkPS(count)
    ps:setPosition(ent.x, ent.y)
    ps:emit(count)
    newEnt.particles = ps
    newEnt.drawDepth = 100
end

local function makeBallPS(count)
    local ball = love.graphics.newParticleSystem(client.atlas:getTexture(), count)
    ball:setQuads(
        assert(client.assets.images.ball_1),
        assert(client.assets.images.ball_2),
        assert(client.assets.images.ball_3),
        assert(client.assets.images.ball_4)
    )
    ball:setParticleLifetime(0.2, 0.5)
    ball:setLinearAcceleration(0, -10, 0, -30)
    ball:setEmissionArea("ellipse", 10, 10, 0, true)
    ball:setColors(0.46, 0, 0.6, 1)
    return ball
end

local function makeBall(ent)
    local COUNT = 20
    local newEnt = client.entities.empty()
    newEnt.x, newEnt.y = ent.x, ent.y
    newEnt.dimension = ent.dimension
    newEnt.lifetime = 0.5
    -- ^^^ delete self after X seconds
    local ps = makeBallPS(COUNT)
    ps:setPosition(ent.x, ent.y)
    ps:emit(COUNT)
    newEnt.particles = ps
    newEnt.drawDepth = 100
end

umg.on("lootplot:comboChanged", function(ent, delta, oldVal, newVal)
    if newVal > 2 then
        local particleCount = math.floor(math.sqrt(newVal) * 1)
        makeSpark(ent, particleCount)
    end
end)

umg.on("lootplot:entityDestroyed", function(ent)
    if lp.isSlotEntity(ent) or lp.isItemEntity(ent) then
        return makeBall(ent)
    end
end)
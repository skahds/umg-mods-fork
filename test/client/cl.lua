

umg.on("@load", function()
    vignette.setStrength(0.65)
end)






love.graphics.clear()




local function getPlayerWithXY()
    --[[
        this sucks!
        PLS dont use this code in real world.
        It doesn't work for multiplayer.
        entities will only chase the host.
    ]]
    local clientId = client.getClient()
    local ents = control.getControlledEntities(clientId)
    for _, e in ipairs(ents) do
        if e.x and e.y then
            return e
        end
    end
end




local function makeClientBlock(dvec)
    local pine = client.entities.block(dvec.x, dvec.y)
    return pine
end



umg.on("@keypressed", function(k,scancode)
    if scancode == "q" then
        umg.melt("stop")
    end
    if scancode == "e" then
        local e = getPlayerWithXY()
        makeClientBlock(e)
    end
end)


umg.on("@draw", function()
    local p = getPlayerWithXY()
    if p then
        love.graphics.setColor(0,0,0)
        love.graphics.print(spatial.getDimension(p))
    end
end)




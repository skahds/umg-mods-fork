
--[[

Handles ents that are being controlled by the player.

Currently there are no restrictions for moving your own entity;
this means that modified clients can teleport anywhere on the screen

]]


local constants = require("shared.constants")


local controlAdmin = {}

function controlAdmin.forceSetPlayerPosition(ent, x, y, z)
    ent.x = x
    ent.y = y
    ent.z = z or ent.z
    -- we gotta force a sync here, since clients ignore position syncs from
    -- the server.
    local sender = ent.controller
    server.unicast(sender, "forceSetPlayerPosition", ent, x, y, z)
end



local function filterPlayerPosition(sender, ent, x,y,z)
    z = z or 0
    if state.getCurrentState() ~= "game" then
        return false -- game is probably paused
        -- TODO: This is kinda hacky and shitty
    end

    local basics = ent.controllable and sender == ent.controller and ent.x and ent.y
    if not basics then
        return false
    end

    local dist = math.distance(ent.x-x, ent.y-y, (ent.z or 0)-z)
    local sync_threshold = ent.speed * (1 + constants.PLAYER_MOVE_LEIGHWAY)
    if dist > sync_threshold then
        -- TODO: This forceSync call is bad, hacked client crash opportunity here.
        -- Perhaps we should instead mark this entity as "should force sync"
        -- and then sync once on the next tick?
        -- with this setup, hacked clients could send multiple position packets per frame and ddos the server
        return false -- ent moving too fast!
    end

    return true
end



local function filterPlayerVelocity(sender, ent, vx,vy,vz)
    if state.getCurrentState() ~= "game" then
        return false -- game is probably paused
        -- TODO: This is kinda hacky and shitty
    end

    return ent.controllable and sender == ent.controller
        and ent.vx and ent.vy
end


local sf = sync.filters

server.on("setPlayerPosition", {
    arguments = {sf.controlEntity, sf.number, sf.number, sf.Optional(sf.number)},
    handler = function(sender, ent, x,y,z)
        if not filterPlayerPosition(sender, ent, x,y,z)then
            return
        end

        ent.x = x
        ent.y = y
        ent.z = z or ent.z
    end
})




local DEFAULT_SPEED = 100

server.on("setPlayerVelocity", {
    arguments = {sf.controlEntity, sf.number, sf.number, sf.Optional(sf.number)},
    handler = function(sender, ent, vx, vy, vz)
        if not filterPlayerVelocity(sender, ent, vx, vy, vz) then
            return
        end
        local max_spd = (ent.speed or DEFAULT_SPEED) 
        if max_spd >= vx and max_spd >= vy then
            -- check that the player aint cheating.
            -- Note that the player can cheat by "flying" though, haha.
            -- (Because vz isn't checked)
            ent.vx = vx
            ent.vy = vy
            if ent.vz then
                ent.vz = vz
            end
        end
    end
})


return controlAdmin
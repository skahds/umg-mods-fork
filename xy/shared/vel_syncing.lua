
local constants = require("shared.constants")
local getSpeed = require("shared.get_speed")


local NUMBER_SYNC_THRESHOLD = constants.NUMBER_SYNC_THRESHOLD

local abs = math.abs




sync.autoSyncComponent("vy", {
    lerp = true,
    numberSyncThreshold = NUMBER_SYNC_THRESHOLD,
    
    controllable = {
        shouldAcceptServerside = function(ent, vy)
            -- we should accept the velocity, iff the velocity is lower
            -- than the maximum.
            -- TODO: This technically means that script kiddies can move
            -- faster than the max velocity, up to sqrt(2) times faster,
            -- since this check only accounts for one dimension.

            -- But... speed hax was already possible with SYNC_LEIGHWAY. 
            -- Oh well! There are bigger fish to fry
            return abs(vy) <= getSpeed(ent)
        end,

        shouldForceSyncClientside = function()
            -- TODO: What do we do here?
            -- I guess we just deny the packet?
            -- There's no possibility for "jumps" for velocities...
            return false
            -- I guess just deny..?
        end
    }
})


sync.autoSyncComponent("vx", {
    --[[
        same logic as above ^^^^^
    ]]
    lerp = true,
    numberSyncThreshold = NUMBER_SYNC_THRESHOLD,
    
    controllable = {
        shouldAcceptServerside = function(ent, vx)
            return abs(vx) <= getSpeed(ent)
        end,
        shouldForceSyncClientside = function()
            return false
        end
    }
})

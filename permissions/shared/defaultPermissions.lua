

components.project("permissions", "authorizable")



umg.answer("permissions:entityHasPermission", function(actorEnt, authEnt)
    -- permissions.public implies that the entity is publically accessible
    local perms = authEnt.permissions
    if perms then
        if perms.public then
            return true
        end

        if perms.playerOnly then
            local isPlayer = (actorEnt.controller and actorEnt.controllable)
            if isPlayer then
                return true
            end
        end
    end
end)


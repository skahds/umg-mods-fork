

local shouldApplyEffect = require("shared.should_apply")



local EventEffects = objects.Class("effects:EventEffects")



function EventEffects:init(ownerEnt)
    self.ownerEnt = ownerEnt
    self.eventEffects = objects.Set()

    self.eventToEffectSet = {--[[
        Keeps track of what effectEntities are used for each effect.

        [eventName] -> List<effectEnt>
    ]]}
end


local function canTrigger(ownerEnt, effectEnt, ...)
    if not shouldApplyEffect(effectEnt, ownerEnt) then
        return false
    end

    local evEffect = effectEnt.eventEffect
    if evEffect.shouldTrigger then
        return evEffect.shouldTrigger(effectEnt, ownerEnt, ...)
    end
    return true -- all ok!
end


local function activateEffect(ownerEnt, effectEnt, ...)
    local evEffect = effectEnt.eventEffect
    if evEffect.usable and effectEnt.usable then
        error("todo")
    end

    if evEffect.trigger then
        evEffect.trigger(effectEnt, ownerEnt, ...)
    end

    umg.call("effects:eventEffectTriggered", effectEnt, ownerEnt)
end


function EventEffects:call(eventName, ...)
    local set = self.eventToEffectSet[eventName]
    if not set then
        return -- no events listening. RIP
    end

    local ownerEnt = self.ownerEnt
    for _, effectEnt in ipairs(set) do
        if canTrigger(ownerEnt, effectEnt, ...) then
            activateEffect(ownerEnt, effectEnt, ...)
        end
    end
end



function EventEffects:shouldTakeEffect(effectEnt)
    return effectEnt.eventEffect
end




local listenedEvents = {--[[
    Checks whether we already have a listener setup for this event

    [eventName] -> true
]]}



local function ensureEventListener(eventName)
    --[[
        creates an event-listener for `eventName` at runtime,
        (if one doesn't already exist.)

        This function only works when the effect entity is
            the first argument passed into the event.
    ]]
    if listenedEvents[eventName] then
        return -- we already have a listener here
    end

    umg.on(eventName, function(ent, ...)
        if ent.eventEffects then
            ent.eventEffects:call(eventName, ...)
        end
    end)

    listenedEvents[eventName] = true
end



function EventEffects:addEffect(effectEnt)
    local event = effectEnt.eventEffect.event
    local set = self.eventToEffectSet[event]
    if not set then
        set = objects.Set()
        self.eventToEffectSet[event] = set
    end

    ensureEventListener(event)
    set:add(effectEnt)
end


function EventEffects:removeEffect(effectEnt)
    local event = effectEnt.eventEffect.event
    local set = self.eventToEffectSet[event]
    set:remove(effectEnt)
    if set:size() <= 0 then
        self.eventToEffectSet[event] = nil
    end
end



umg.on("effects:effectAdded", function(effectEnt, ent)
    if effectEnt.eventEffect then
        ent.eventEffects = ent.eventEffects or EventEffects(ent)
        ent.eventEffects:addEffect(effectEnt)
    end
end)


umg.on("effects:effectRemoved", function(effectEnt, ent)
    if ent.eventEffects then
        ent.eventEffects:removeEffect(effectEnt)
    end
end)


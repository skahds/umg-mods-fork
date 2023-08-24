
--[[
    
An "ItemHandle" is an object representing an item in an inventory slot.

It's useful when we want items to have more complex behaviour.

If an item is moved out of an inventory, or if an item moves slots,
any ItemHandle for that item becomes invalid,
and other systems that have a reference to that ItemHandle will know.

This allows systems to use items in more complex ways, for example:
- item holding
- armour (ie. chestplate slot)
- passive item buffs (ie. terraria passive item slots)


Each inventory may have ItemHandles.
ItemHandles are managed by the inventory internally.
Nothing needs to be done to manage them externally; they are fully
handled by the inventory itself.

-----------------------
Systems may also respond to ItemHandles becoming invalid through callbacks

For example, an ItemHandle with the `removePosition` flag would
cause position components to be removed from the item.

This frees the burden of state from the systems who own the itemHandles.
They can just add the `removePosition` flag, and be confident that
everything will be cleaned up.

]]


local ItemHandle = objects.Class("items:ItemHandle")


local initTc = typecheck.assert("number", "number", "entity")

function ItemHandle:init(slotX, slotY, itemEnt)
    --[[
        `itemEnt` is the item at (slotX, slotY) in the inventory.

        We don't have a reference to the inventory; rather,
        the inventory has a reference to us.
    ]]
    initTc(slotX, slotY, itemEnt)
    self.slotX = slotX
    self.slotY = slotY
    self._item = itemEnt -- TODO: We NEED ephemeral components for this!
    self.valid = true
end


--[[

TODO: In the future, we may want to check for 2 types of validity:

- whether the item has moved slots
- whether the item has moved INVENTORIES.


Currently, :isValid() is just for slots.
for future, we may want to do inventory-wide checks

]]
function ItemHandle:isValid()
    if not self.valid then
        return false
    end

    if not umg.exists(self._item) then
        -- if the item ent no longer exists, invalidate self
        self:invalidate()
        return false
    end

    return true
end


function ItemHandle:get()
    if self:isValid() then
        return self._item
    end
    error("ItemHandle was not valid! check using :isValid() before calling :get()")
end


local strTc = typecheck.assert("string")

function ItemHandle:setFlag(key, val)
    strTc(key)
    if ItemHandle[key] then
        error("Invalid flag: " .. key)
    end
    self[key] = val
end


function ItemHandle:getFlag(key)
    strTc(key)
    return self[key]
end


function ItemHandle:getSlot()
    return self.slotX, self.slotY
end


function ItemHandle:onInvalidate(invEnt, itemEnt)
    --[[ to be overridden! ]]
end


function ItemHandle:invalidate(invEnt)
    if self:isValid() then
        self:onInvalidate(invEnt, self._item)
    end
    self.valid = false
    self._item = nil
end
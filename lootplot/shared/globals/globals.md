

# Global functions

These are global functions used internally within lootplot.

These are NOT exported.


```lua

-- typechecks:
posTc(ppos)
slotTc(slotEnt)
itemTc(itemEnt)


RPC("mystring", {"entity", "number"}, 
function(ent, slot)
    ...
end)

```

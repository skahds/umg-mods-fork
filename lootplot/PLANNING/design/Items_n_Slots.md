

# Slot
Slots live in `Plot`s.

A Slot is like a container for an item to exist in.
Can be placed in the world; but also exist within inventories.

Important things to note:
- `Slot`s CANNOT be moved out of a `Plot`.
    - They can only be deleted/augmented.







# Items 
Items are the CORE of lootplot.

Items live in `Slot`s.
An item CANNOT exist outside of `Slot`.

- How are items moved between Plots?
    - They aren't. Items are moved between `Slot`s.



# Generic augments:
"Generic augments" are augments that are applied to BOTH items, AND slots.
(See `LOOTPLOT.md` for more info)


## Slot augments:
Slots can have one or more "augments".
These augments should be characterized by an overlay upon the slot.
(For example, a lil corner flap-sprite at the bottom-left or something)

## Example Slot-Augments:
Reroll slots:
    Reroll the item when reroll activated
Shop slots:
    Items in these slots can be purchased
Dead slots:
    Items in these slots do not activate.
    By default; shops/inventories have "Dead" slots.




## SUPER-WEAPON: Generic Augments/Modifiers!!!
REMEMBER TO ABUSE THE ECS-NATURE OF LOOTPLOT!!
We can add flags to `Item`s OR `Slot`s; and they will work exactly the same.

EXAMPLE:
- On activation:  Give $1.   
^^^ This "augment/modifier" would work *perfectly* on an Item, OR a Slot.
Make sure to write behaviour generically;
if we don't compose behaviour like this, we are wasting time.



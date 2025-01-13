--- STEAMODDED HEADER
--- MOD_NAME: Fatemaker
--- MOD_ID: FATEMAKER
--- MOD_AUTHOR: [jitJet]
--- MOD_DESCRIPTION: A Destiny 2 inspired mod with subclass synergies and elements!
--- PREFIX: fm
----------------------------------------------
------------MOD CODE -------------------------

SMODS.load_file("data/overrides.lua")()
SMODS.load_file("data/atlases.lua")()
SMODS.load_file("data/sounds.lua")()
assert(SMODS.load_file("data/enhancements/void.lua"))()
assert(SMODS.load_file("data/enhancements/solar.lua"))()
assert(SMODS.load_file('data/enhancements/arc.lua'))()
assert(SMODS.load_file("data/enhancements/stasis.lua"))()
assert(SMODS.load_file("data/enhancements/strand.lua"))()
assert(SMODS.load_file("data/enhancements/resonance.lua"))()
assert(SMODS.load_file("data/enhancements/prismatic.lua"))()
assert(SMODS.load_file("data/jokers.lua"))()
assert(SMODS.load_file("data/blinds/corrupted_wish.lua"))()
assert(SMODS.load_file("data/blinds/machine_garden.lua"))()
assert(SMODS.load_file("data/ui/loadout.lua"))()

----------------------------------------------
------------MOD CODE END----------------------
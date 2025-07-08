--- STEAMODDED HEADER
--- MOD_NAME: Fatemaker
--- MOD_ID: FATEMAKER
--- MOD_AUTHOR: [jitJet]
--- MOD_DESCRIPTION: A Destiny 2 inspired mod with subclass synergies and elements!
--- PREFIX: fm
----------------------------------------------
------------MOD CODE -------------------------

Fatemaker = {}

Fatemaker.config = SMODS.current_mod.config

assert(SMODS.load_file("data/overrides.lua"))()
assert(SMODS.load_file("data/atlases.lua"))()
assert(SMODS.load_file("data/sounds.lua"))()
assert(SMODS.load_file("data/editions/voidwalker.lua"))()
assert(SMODS.load_file("data/editions/sunbreaker.lua"))()
-- assert(SMODS.load_file("data/editions/arcstrider.lua"))()
assert(SMODS.load_file("data/enhancements/void.lua"))()
assert(SMODS.load_file("data/enhancements/solar.lua"))()
assert(SMODS.load_file('data/enhancements/arc.lua'))()
assert(SMODS.load_file("data/enhancements/stasis.lua"))()
assert(SMODS.load_file("data/enhancements/strand.lua"))()
assert(SMODS.load_file("data/enhancements/resonance.lua"))()
assert(SMODS.load_file("data/enhancements/prismatic.lua"))()
assert(SMODS.load_file("data/jokers.lua"))()
assert(SMODS.load_file("data/consumables.lua"))()
assert(SMODS.load_file("data/backs.lua"))()
assert(SMODS.load_file("data/boosters/void.lua"))()
assert(SMODS.load_file("data/boosters/solar.lua"))()
assert(SMODS.load_file("data/boosters/arc.lua"))()
assert(SMODS.load_file("data/blinds/corrupted_wish.lua"))()
assert(SMODS.load_file("data/blinds/machine_garden.lua"))()
assert(SMODS.load_file("data/blinds/fallen_crypt.lua"))()
assert(SMODS.load_file("data/blinds/reshaped_edge.lua"))()
assert(SMODS.load_file("data/ui.lua"))()
assert(SMODS.load_file("data/mechanics.lua"))()
----------------------------------------------
------------MOD CODE END----------------------
-- Enhancements
SMODS.Sound({ vol = 0.6, key = "amplified", path = "amplified.ogg" })
SMODS.Sound({ vol = 0.6, key = "blind", path = "blind.ogg" })
SMODS.Sound({ vol = 0.6, key = "cracked", path = "cracked.ogg" })
SMODS.Sound({ vol = 0.6, key = "devour", path = "devour.ogg" })
SMODS.Sound({ vol = 0.4, key = "dissected", path = "dissected.ogg" })
SMODS.Sound({ vol = 0.6, key = "finalized", path = "finalized.ogg" })
SMODS.Sound({ vol = 0.6, key = "freeze", path = "freeze.ogg" })
SMODS.Sound({ vol = 0.6, key = "ignition", path = "ignition.ogg" })
SMODS.Sound({ vol = 0.6, key = "jolt", path = "jolt.ogg" })
SMODS.Sound({ vol = 0.6, key = "overshield", path = "overshield.ogg" })
SMODS.Sound({ vol = 0.6, key = "primed", path = "primed.ogg" })
SMODS.Sound({ vol = 0.6, key = "radiant", path = "radiant.ogg" })
SMODS.Sound({ vol = 0.6, key = "resonant", path = "resonant.ogg" })
SMODS.Sound({ vol = 0.6, key = "restoration", path = "restoration.ogg" })
SMODS.Sound({ vol = 0.6, key = "scorch", path = "scorch.ogg" })
SMODS.Sound({ vol = 0.6, key = "shatter", path = "shatter.ogg" })
SMODS.Sound({ vol = 0.6, key = "slow", path = "slow.ogg" })
SMODS.Sound({ vol = 0.6, key = "tangle", path = "tangle.ogg" })
SMODS.Sound({ vol = 0.6, key = "threaded", path = "threaded.ogg" })
SMODS.Sound({ vol = 0.6, key = "transcendent", path = "transcendent.ogg" })
SMODS.Sound({ vol = 0.6, key = "unravel", path = "unravel.ogg" })
SMODS.Sound({ vol = 0.6, key = "volatile", path = "volatile.ogg" })
SMODS.Sound({ vol = 0.6, key = "wovenmail", path = "wovenmail.ogg" })

-- Corrupted Wish
SMODS.Sound({ vol = 0.6, key = "corrupted_wish_wish_granted", path = "corrupted_wish_wish_granted.ogg" })
SMODS.Sound({ vol = 0.6, key = "corrupted_wish_taken", path = "corrupted_wish_taken.ogg" })

SMODS.Sound({
    vol = 0.8,
    pitch = 1,
    key = "music_corrupted_wish",
    path = "corrupted_wish.ogg",
    select_music_track = function()
        return (G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_fm_corrupted_wish")
    end,
})

-- Machine Garden
SMODS.Sound({ vol = 0.6, key = "machine_garden_explosion", path = "machine_garden_explosion.ogg" })
SMODS.Sound({ vol = 0.6, key = "machine_garden_gauge_fill", path = "machine_garden_gauge_fill.ogg" })
SMODS.Sound({ vol = 0.6, key = "machine_garden_mote_spawn", path = "machine_garden_mote_spawn.ogg" })
SMODS.Sound({ vol = 0.6, key = "machine_garden_tether_linked", path = "machine_garden_tether_linked.ogg" })
SMODS.Sound({ vol = 0.6, key = "machine_garden_tether_powered", path = "machine_garden_tether_powered.ogg" })
SMODS.Sound({ vol = 0.6, key = "machine_garden_tether_unpowering", path = "machine_garden_tether_unpowering.ogg" })
SMODS.Sound({ vol = 0.6, key = "machine_garden_voltaic_overflow_spawn", path = "machine_garden_voltaic_overflow_spawn.ogg" })

SMODS.Sound({
    vol = 0.8,
    pitch = 1,
    key = "music_machine_garden",
    path = "machine_garden.ogg",
    select_music_track = function()
        return (G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_fm_machine_garden")
    end,
})
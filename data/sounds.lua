SMODS.Sound({ vol = 0.6, key = "amplified", path = "amplified.wav" })
SMODS.Sound({ vol = 0.6, key = "blind", path = "blind.wav" })
SMODS.Sound({ vol = 0.6, key = "cracked", path = "cracked.wav" })
SMODS.Sound({ vol = 0.6, key = "devour", path = "devour.wav" })
SMODS.Sound({ vol = 0.4, key = "dissected", path = "dissected.wav" })
SMODS.Sound({ vol = 0.6, key = "finalized", path = "finalized.wav" })
SMODS.Sound({ vol = 0.6, key = "freeze", path = "freeze.wav" })
SMODS.Sound({ vol = 0.6, key = "ignition", path = "ignition.wav" })
SMODS.Sound({ vol = 0.6, key = "jolt", path = "jolt.wav" })
SMODS.Sound({ vol = 0.6, key = "overshield", path = "overshield.wav" })
SMODS.Sound({ vol = 0.6, key = "primed", path = "primed.wav" })
SMODS.Sound({ vol = 0.6, key = "radiant", path = "radiant.wav" })
SMODS.Sound({ vol = 0.6, key = "resonant", path = "resonant.wav" })
SMODS.Sound({ vol = 0.6, key = "restoration", path = "restoration.wav" })
SMODS.Sound({ vol = 0.6, key = "scorch", path = "scorch.wav" })
SMODS.Sound({ vol = 0.6, key = "shatter", path = "shatter.wav" })
SMODS.Sound({ vol = 0.6, key = "slow", path = "slow.wav" })
SMODS.Sound({ vol = 0.6, key = "tangle", path = "tangle.wav" })
SMODS.Sound({ vol = 0.6, key = "threaded", path = "threaded.wav" })
SMODS.Sound({ vol = 0.6, key = "transcendent", path = "transcendent.wav" })
SMODS.Sound({ vol = 0.6, key = "unravel", path = "unravel.wav" })
SMODS.Sound({ vol = 0.6, key = "volatile", path = "volatile.wav" })
SMODS.Sound({ vol = 0.6, key = "wovenmail", path = "wovenmail.wav" })

SMODS.Sound({ vol = 0.6, key = "corrupted_wish_wish_granted", path = "corrupted_wish_wish_granted.wav" })
SMODS.Sound({ vol = 0.6, key = "corrupted_wish_taken", path = "corrupted_wish_taken.wav" })

SMODS.Sound({
    vol = 0.8,
    pitch = 1,
    key = "music_corrupted_wish",
    path = "corrupted_wish.ogg",
    select_music_track = function()
        return (G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_fm_corrupted_wish")
    end,
})

SMODS.Sound({
    vol = 0.8,
    pitch = 1,
    key = "music_machine_garden",
    path = "machine_garden.ogg",
    select_music_track = function()
        return (G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_fm_machine_garden")
    end,
})
SMODS.Shader({ key = 'sunbreaker', path = 'sunbreaker.fs' })

SMODS.Edition({
    key = "sunbreaker",
    shader = "sunbreaker",
    loc_txt = {
        name = "Sunbreaker",
        label = "Sunbreaker",
        text = {
            "Nothing yet!"
        }
    },
    sound = { sound = "fm_sunbreaker" },
    disable_shadow = false,
    disable_base_shader = false,
    discovered = true,
    unlocked = true,
    config = {},
    in_shop = false,
    apply_to_float = true,
    loc_vars = function(self)
        return { vars = {} }
    end
})
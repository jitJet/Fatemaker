SMODS.Shader({ key = 'veiled', path = 'veiled.fs' })

SMODS.Edition({
    key = "veiled",
    shader = "veiled",
    loc_txt = {
        name = "Veiled",
        label = "Veiled",
        text = {
            "Nothing yet!"
        }
    },
    disable_shadow = true,
    disable_base_shader = true,
    discovered = true,
    unlocked = true,
    config = {},
    in_shop = false,
    apply_to_float = true,
    loc_vars = function(self)
        return { vars = {} }
    end
})
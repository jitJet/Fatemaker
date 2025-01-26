SMODS.Shader({ key = 'voidwalker', path = 'voidwalker.fs' })

SMODS.Edition({
    key = "voidwalker",
    shader = "voidwalker",
    loc_txt = {
        name = "Voidwalker",
        label = "Voidwalker",
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
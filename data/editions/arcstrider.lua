SMODS.Shader({ key = 'arcstrider', path = 'arcstrider.fs' })

SMODS.Edition({
    key = "arcstrider",
    shader = "arcstrider",
    loc_txt = {
        name = "Arcstrider",
        label = "Arcstrider",
        text = {
            "Nothing yet!"
        }
    },
    sound = { sound = "fm_arcstrider" },
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
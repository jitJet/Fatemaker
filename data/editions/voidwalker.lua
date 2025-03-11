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
    sound = { sound = "fm_voidwalker" },
    disable_shadow = false,
    disable_base_shader = false,
    on_apply = function(card)
        card.children.particles = Particles(1, 1, 0, 0, {
            timer = 0.03,
            scale = 0.3,
            speed = 1.2,
            behind = true,
            lifespan = 2,
            attach = card,
            colours = {G.C.PURPLE, lighten(G.C.PURPLE, 0.15), darken(G.C.PURPLE, 0.2)},
            fill = true
        })
    end,
    on_load = function(card)
        card.children.particles = Particles(1, 1, 0, 0, {
            timer = 0.03,
            scale = 0.3,
            speed = 1.2,
            behind = true,
            lifespan = 2,
            attach = card,
            colours = {G.C.PURPLE, lighten(G.C.PURPLE, 0.15), darken(G.C.PURPLE, 0.2)},
            fill = true
        })
    end,
    on_remove = function(card)
        card.children.particles:remove()
    end,
    discovered = true,
    unlocked = true,
    config = {},
    in_shop = true,
    weight = 3,
    apply_to_float = true,
    loc_vars = function(self)
        return { vars = {} }
    end
})
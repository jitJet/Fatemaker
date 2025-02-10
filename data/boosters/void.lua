SMODS.Booster({
    key = "void",
    loc_txt = {
        name = "Void Pack",
        text = {
            "Choose 1 of up to",
            "3 {C:purple}Void{} cards to add",
            "to your deck",
            "Small chance for",
            "{C:dark_edition}Transcendent{} cards to spawn"
        },
        group_name = "Void Pack"
    },
    atlas = "Boosters",
    pos = { x = 0, y = 0 },
    cost = 6,
    weight = 1,
    config = { extra = 3, choose = 1 },
    ease_background_colour = function(self)
        ease_background_colour({ new_colour = G.C.PURPLE, special_colour = G.C.BLACK, contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.015,
            scale = 0.2,
            initialize = true,
            lifespan = 1,
            speed = 1.1,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.BLACK, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.BLACK, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function(self, card, i)
        local rng = pseudorandom('void_pack')
        if rng > 0.9 then
            return {
                set = "Enhanced", 
                area = G.pack_cards, 
                skip_materialize = true,
                no_edition = false,
                enhancement = "m_fm_transcendent"
            }
        else
            local void_enhancements = {
                "m_fm_overshield",
                "m_fm_volatile",
                "m_fm_devour"
            }
            local selected_enhancement = void_enhancements[math.random(#void_enhancements)]
            
            return {
                set = "Enhanced", 
                area = G.pack_cards, 
                skip_materialize = true,
                no_edition = false,
                enhancement = selected_enhancement
            }
        end
    end
})
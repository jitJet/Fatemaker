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
    create_card = function(self, card, i)
        local rng = pseudorandom('void_pack')
        local card_config
        if rng > 0.9 then
            card_config = {
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
                "m_fm_devour",
                "m_fm_suppress"
            }
            local selected_enhancement = pseudorandom_element(void_enhancements, pseudoseed('void_enhancement'))
            
            card_config = {
                set = "Enhanced", 
                area = G.pack_cards, 
                skip_materialize = true,
                no_edition = false,
                enhancement = selected_enhancement
            }
        end
    
        local edition = poll_edition('edi'..(key_append or '')..G.GAME.round_resets.ante, 2, true)
        if edition then
            card_config.edition = edition
        end
    
        local seal = SMODS.poll_seal({mod = 10})
        if seal then
            card_config.seal = seal
        end
    
        return card_config
    end
})

SMODS.Booster({
    key = "jumbo_void",
    loc_txt = {
        name = "Jumbo Void Pack",
        text = {
            "Choose 1 of up to",
            "5 {C:purple}Void{} cards to add",
            "to your deck",
            "Small chance for",
            "{C:dark_edition}Transcendent{} cards to spawn"
        },
        group_name = "Void Pack"
    },
    atlas = "Boosters",
    pos = { x = 1, y = 0 },
    cost = 8,
    weight = 1,
    config = { extra = 5, choose = 1 },
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
        local rng = pseudorandom('jumbo_void_pack')
        local card_config
        if rng > 0.9 then
            card_config = {
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
                "m_fm_devour",
                "m_fm_suppress",
            }
            local selected_enhancement = pseudorandom_element(void_enhancements, pseudoseed('void_enhancement'))
            
            card_config = {
                set = "Enhanced", 
                area = G.pack_cards, 
                skip_materialize = true,
                no_edition = false,
                enhancement = selected_enhancement
            }
        end
    
        local edition = poll_edition('edi'..(key_append or '')..G.GAME.round_resets.ante, 2, true)
        if edition then
            card_config.edition = edition
        end
    
        local seal = SMODS.poll_seal({mod = 10})
        if seal then
            card_config.seal = seal
        end
    
        return card_config
    end
})

SMODS.Booster({
    key = "mega_void",
    loc_txt = {
        name = "Mega Void Pack",
        text = {
            "Choose 2 of up to",
            "5 {C:purple}Void{} cards to add",
            "to your deck",
            "Small chance for",
            "{C:dark_edition}Transcendent{} cards to spawn"
        },
        group_name = "Void Pack"
    },
    atlas = "Boosters",
    pos = { x = 2, y = 0 },
    cost = 10,
    weight = 1,
    config = { extra = 5, choose = 2 },
    ease_background_colour = function(self)
        ease_background_colour({ new_colour = G.C.PURPLE, special_colour = G.C.BLACK, contrast = 2 })
    end,
    particles = function(self)
        G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
            timer = 0.1,
            scale = 0.5,
            initialize = true,
            lifespan = 2,
            speed = 1.5,
            padding = -1,
            attach = G.ROOM_ATTACH,
            colours = { G.C.BLACK, lighten(G.C.PURPLE, 0.4), lighten(G.C.PURPLE, 0.2), lighten(G.C.BLACK, 0.2) },
            fill = true
        })
        G.booster_pack_sparkles.fade_alpha = 1
        G.booster_pack_sparkles:fade(1, 0)
    end,
    create_card = function(self, card, i)
        local rng = pseudorandom('mega_void_pack')
        local card_config
        if rng > 0.9 then
            card_config = {
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
                "m_fm_devour",
                "m_fm_suppress"
            }
            local selected_enhancement = pseudorandom_element(void_enhancements, pseudoseed('void_enhancement'))
            
            card_config = {
                set = "Enhanced",
                area = G.pack_cards,
                skip_materialize = true,
                no_edition = false,
                enhancement = selected_enhancement
            }
        end
    
        local edition = poll_edition('edi'..(key_append or '')..G.GAME.round_resets.ante, 2, true)
        if edition then
            card_config.edition = edition
        end
    
        local seal = SMODS.poll_seal({mod = 10})
        if seal then
            card_config.seal = seal
        end
    
        return card_config
    end
})
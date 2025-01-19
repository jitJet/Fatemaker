SMODS.Joker{
    key = "balance",
    loc_txt = {
        name = "Facet of Balance",
        text = {
            "If the total Chip or Mult amount",
            "is lower than the other, {C:attention}sacrifice",
            "half of the higher amount{} to be added",
            "to the lower amount"
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=0, y=0},
    calculate = function(self, card, context)
        if context.joker_main then
            if hand_chips > mult then
                local halved_chips = hand_chips / 2
                hand_chips = hand_chips - halved_chips
                mult = mult + halved_chips
                update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
                return {
                    message = "+" .. halved_chips .. " Mult",
                    colour = G.C.MULT,
                    card = card
                }
            elseif hand_chips < mult then
                local halved_mult = mult / 2
                mult = mult - halved_mult
                hand_chips = hand_chips + halved_mult
                update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
                return {
                    message = "+" .. halved_mult,
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker{
    key = "well_of_radiance",
    loc_txt = {
        name = "Well of Radiance",
        text = {
            "Charge with 5 {C:attention}Solar{} cards.",
            "Once charged and once per ante,",
            "win a Blind to turn your",
            "hand into half {C:attention}Radiant{} and {C:attention}Restoration{} cards",
            "{C:inactive}(Currently: {C:attention}#1#{C:inactive})"
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=0, y=1},
    config = {
        extra = {
            charge = 0,
            state = "charging", -- states: "charging", "ready", "primed"
            current_ante = 0
        }
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { card.ability.extra.charge .. "/5 Charging" } }
        elseif card.ability.extra.state == "ready" then
            return { vars = { "Ready!" } }
        elseif card.ability.extra.state == "primed" then
            return { vars = { "Primed!" } }
        else
            return { vars = { "0/5 Charging" } }
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if card.ability.extra.state == "charging" then
                local solar_count = 0
                for _, scoringCard in ipairs(context.scoring_hand) do
                    if scoringCard.config.center == G.P_CENTERS.m_fm_radiant or
                       scoringCard.config.center == G.P_CENTERS.m_fm_restoration or
                       scoringCard.config.center == G.P_CENTERS.m_fm_scorch then
                        solar_count = solar_count + 1
                    end
                end
                
                card.ability.extra.charge = math.min(5, card.ability.extra.charge + solar_count)
                
                if card.ability.extra.charge >= 5 then
                    card.ability.extra.state = "ready"
                    local eval = function() return card.ability.extra.state == "ready" end
                    juice_card_until(card, eval, true)
                    return {
                        message = "Ready!",
                        sound = "fm_super_ready",
                        colour = G.C.ORANGE,
                        card = card
                    }
                else
                    return {
                        message = "Charging...",
                        colour = G.C.ORANGE,
                        card = card
                    }
                end
            end
        end
 
        if context.end_of_round and card.ability.extra.state == "ready" and
            card.ability.extra.current_ante ~= G.GAME.round_resets.blind_ante then
            card.ability.extra.state = "primed"
            card.ability.extra.current_ante = G.GAME.round_resets.blind_ante
            return {
                message = "Primed!",
                colour = G.C.ORANGE,
                card = card
            }
        end
        
        if not context.before and card.ability.extra.state == "primed" and #G.hand.cards > 0 then
            local normal_cards = {}
            for _, handCard in ipairs(G.hand.cards) do
                if handCard.ability.set ~= "Enhanced" then
                    table.insert(normal_cards, handCard)
                end
            end
         
            if #normal_cards >= 2 then
                local half = math.floor(#normal_cards / 2)
                for i = 1, half do
                    normal_cards[i]:flip()
                    SMODS.calculate_effect({
                        message = "Radiant!",
                        sound = "fm_well_of_radiance",
                        colour = G.C.ORANGE
                    }, normal_cards[i])
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        func = function()
                            normal_cards[i]:set_ability(G.P_CENTERS.m_fm_radiant)
                            normal_cards[i]:flip()
                            return true
                        end
                    }))
                end
                for i = half + 1, #normal_cards do
                    normal_cards[i]:flip()
                    SMODS.calculate_effect({
                        message = "Restored!",
                        sound = "fm_well_of_radiance",
                        colour = G.C.ORANGE
                    }, normal_cards[i])
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        func = function()
                            normal_cards[i]:set_ability(G.P_CENTERS.m_fm_restoration)
                            normal_cards[i]:flip()
                            return true
                        end
                    }))
                end
            end
            
            card.ability.extra.state = "charging"
            card.ability.extra.charge = 0
        end
    end
}

SMODS.Joker{
    key = "golden_gun",
    loc_txt = {
        name = "Golden Gun",
        text = {
            "Charge with 5 {C:attention}Solar{} cards.",
            "Once charged, next hand played sets",
            "number of retriggers. Then, next hand",
            "with {C:attention}Solar{} cards will retrigger those",
            "cards that many times.",
            "{C:inactive}(Currently: {C:attention}#1#{C:inactive})"
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=1, y=1},
    config = {
        extra = {
            charge = 0,
            loaded_retriggers = 0,
            state = "charging"  -- states: "charging", "ready", "loaded", "firing"
        }
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { card.ability.extra.charge .. "/5 Charging" } }
        elseif card.ability.extra.state == "ready" then
            return { vars = { "Ready!" } }
        elseif card.ability.extra.state == "loaded" then
            return { vars = { card.ability.extra.loaded_retriggers .. "x Loaded!" } }
        else
            return { vars = { "0/5 Charging" } }
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            -- Skip Blueprint copies if in loaded state
            if card.ability.extra.state == "loaded" then
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i].ability.name == "Blueprint" and
                       G.jokers.cards[i+1] == card then
                        return nil
                    end
                end
            end
     
            local solar_count = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_radiant or
                   scoringCard.config.center == G.P_CENTERS.m_fm_restoration or
                   scoringCard.config.center == G.P_CENTERS.m_fm_scorch then
                    solar_count = solar_count + 1
                end
            end
     
            if card.ability.extra.state == "charging" then
                card.ability.extra.charge = math.min(5, card.ability.extra.charge + solar_count)
                
                if card.ability.extra.charge >= 5 then
                    card.ability.extra.state = "ready"
                    local eval = function() return card.ability.extra.state == "ready" end
                    juice_card_until(card, eval, true)
                    return {
                        message = "Ready!",
                        sound = "fm_super_ready",
                        colour = G.C.ORANGE,
                        card = card
                    }
                else
                    return {
                        message = "Charging...",
                        colour = G.C.ORANGE,
                        card = card
                    }
                end
            elseif card.ability.extra.state == "ready" and solar_count > 0 then
                card.ability.extra.loaded_retriggers = solar_count
                card.ability.extra.state = "loaded"
                return {
                    message = solar_count .. "x Loaded!",
                    colour = G.C.ORANGE,
                    sound = "fm_golden_gun_loaded",
                    card = card
                }
            elseif card.ability.extra.state == "loaded" then
                local has_solar = false
                for _, scoringCard in ipairs(context.scoring_hand) do
                    if scoringCard.config.center == G.P_CENTERS.m_fm_radiant or
                       scoringCard.config.center == G.P_CENTERS.m_fm_restoration or
                       scoringCard.config.center == G.P_CENTERS.m_fm_scorch then
                        has_solar = true
                        break
                    end
                end
                
                if has_solar then
                    card.ability.extra.state = "firing"
                end
            end
        end
     
        if context.cardarea == G.play and context.repetition and not context.repetition_only then
            if card.ability.extra.state == "loaded" and
               (context.other_card.config.center == G.P_CENTERS.m_fm_radiant or
                context.other_card.config.center == G.P_CENTERS.m_fm_restoration or
                context.other_card.config.center == G.P_CENTERS.m_fm_scorch) then
                
                local retriggers = card.ability.extra.loaded_retriggers
                
                if context.other_card == context.scoring_hand[#context.scoring_hand] then
                    card.ability.extra.state = "charging"
                    card.ability.extra.charge = 0
                    card.ability.extra.loaded_retriggers = 0
                end
                
                return {
                    message = retriggers .. "x Shot!",
                    sound = "fm_golden_gun",
                    repetitions = retriggers,
                    card = context.other_card
                }
            end
        end
    end
}

SMODS.Joker{
    key = "thundercrash",
    loc_txt = {
        name = "Thundercrash",
        text = {
            "Charge with 5 {C:blue}Arc{} cards.",
            "When charged and {C:attention}#1#{} is played,",
            "highest card gains {C:blue}50 times{} the chips and",
            "{C:blue}jolts{} unenhanced cards",
            "{C:inactive}(Currently: {C:attention}#2#{C:inactive})"
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=2, y=1},
    config = {
        extra = {
            charge = 0,
            state = "charging",
            target_suit = "Hearts"
        }
    },
    init = function(self)
        local suits = {"Hearts", "Diamonds", "Spades", "Clubs"}
        self.ability.extra.target_suit = suits[math.random(#suits)]
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.target_suit,
            card.ability.extra.state == "charging" and 
                card.ability.extra.charge .. "/5 Charging" or "Ready!"
        }}
    end,
    calculate = function(self, card, context)
        if context.end_of_round then
            local suits = {"Hearts", "Diamonds", "Spades", "Clubs"}
            card.ability.extra.target_suit = suits[math.random(#suits)]
        end
 
        if context.joker_main then
            if card.ability.extra.state == "charging" then
                local arc_count = 0
                for _, scoringCard in ipairs(context.scoring_hand) do
                    if scoringCard.config.center == G.P_CENTERS.m_fm_jolt or
                       scoringCard.config.center == G.P_CENTERS.m_fm_amplified or
                       scoringCard.config.center == G.P_CENTERS.m_fm_blinded then
                        arc_count = arc_count + 1
                    end
                end
                
                card.ability.extra.charge = math.min(5, card.ability.extra.charge + arc_count)
                
                if card.ability.extra.charge >= 5 then
                    card.ability.extra.state = "ready"
                    return {
                        message = "Ready!",
                        sound = "fm_super_ready",
                        colour = G.C.BLUE
                    }
                else
                    return {
                        message = "Charging...",
                        colour = G.C.BLUE
                    }
                end
            end
            
            if card.ability.extra.state == "ready" then
                local highest_card = nil
                local has_target_suit = false
                
                for _, scoringCard in ipairs(context.scoring_hand) do
                    if scoringCard.base.suit == card.ability.extra.target_suit then
                        has_target_suit = true
                        if not highest_card or scoringCard:get_id() > highest_card:get_id() then
                            highest_card = scoringCard
                        end
                    end
                end
                
                if has_target_suit then
                    for _, scoringCard in ipairs(context.scoring_hand) do
                        SMODS.calculate_effect({
                            message = "Jolted!",
                            sound = "fm_jolt",
                            colour = G.C.BLUE
                        }, scoringCard)
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            func = function()
                                scoringCard:flip()
                                scoringCard:set_ability(G.P_CENTERS.m_fm_jolt)
                                scoringCard:flip()
                                return true
                            end
                        }))
                    end                    
                
                    -- Reset charge first
                    card.ability.extra.state = "charging"
                    card.ability.extra.charge = 0
                
                    -- Then apply bonus chips to highest card
                    if highest_card then
                        card_eval_status_text(highest_card, 'extra', nil, nil, nil, {
                            message = "Crashed!",
                            sound = "fm_thundercrash",
                            colour = G.C.BLUE
                        })
                        return {
                            card = highest_card,
                            chips = highest_card:get_id() * 50
                        }
                    end
                end
            end
        end
    end
}

SMODS.Joker{
    key = "gathering_storm",
    loc_txt = {
        name = "Gathering Storm",
        text = {
            "First hand played per round {C:blue}amplifies{} 3 unenhanced cards",
            "Playing {C:blue}amplified{} cards will retrigger them",
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=3, y=1},
    calculate = function(self, card, context)
        if context.joker_main then
            
        end
    end
}

SMODS.Joker{
    key = "ward_of_dawn",
    loc_txt = {
        name = "Ward of Dawn",
        text = {
            "While at least one Overshield card is in hand,",
            "gain {C:mult}+10{} Mult for each Void card scored"
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=4, y=1},
    calculate = function(self, card, context)
        if context.joker_main then
            
        end
    end
}

SMODS.Joker{
    key = "shadowshot",
    loc_txt = {
        name = "Shadowshot",
        text = {
            "Discarding a Void card per round will",
            "transform 3 random unenhanced cards to",
            "its effect"
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=5, y=1},
    calculate = function(self, card, context)
        if context.joker_main then
            
        end
    end
}

SMODS.Joker{
    key = "winters_wrath",
    loc_txt = {
        name = "Winter's Wrath",
        text = {
            "",
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=6, y=1},
    calculate = function(self, card, context)
        if context.joker_main then
            
        end
    end
}

SMODS.Joker{
    key = "glacial_quake",
    loc_txt = {
        name = "Glacial Quake",
        text = {
            "",
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=7, y=1},
    calculate = function(self, card, context)
        if context.joker_main then
            
        end
    end
}

SMODS.Joker{
    key = "needlestorm",
    loc_txt = {
        name = "Needlestorm",
        text = {
            "",
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=8, y=1},
    calculate = function(self, card, context)
        if context.joker_main then
            
        end
    end
}

SMODS.Joker{
    key = "bladefury",
    loc_txt = {
        name = "Bladefury",
        text = {
            "",
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=9, y=1},
    calculate = function(self, card, context)
        if context.joker_main then
            
        end
    end
}

SMODS.Joker{
    key = "witnesss_shatter",
    loc_txt = {
        name = "Witness's Shatter",
        text = {
            "",
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=10, y=1},
    calculate = function(self, card, context)
        if context.joker_main then
            
        end
    end
}

SMODS.Joker{
    key = "resonate_whirlwind",
    loc_txt = {
        name = "Resonate Whirlwind",
        text = {
            "",
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=0, y=2},
    calculate = function(self, card, context)
        if context.joker_main then
            
        end
    end
}
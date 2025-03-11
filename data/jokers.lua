SMODS.Joker{
    key = "balance",
    loc_txt = {
        name = "Facet of Balance",
        text = {
            "If the total Chip or Mult amount",
            "is lower than the other, {C:attention}sacrifice a",
            "quarter of the higher amount{} to be added",
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
                local quartered_chips = hand_chips / 4
                hand_chips = hand_chips - quartered_chips
                mult = mult + quartered_chips
                update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
                return {
                    message = "+" .. quartered_chips .. " Mult",
                    colour = G.C.MULT,
                    card = card
                }
            elseif hand_chips < mult then
                local quartered_mult = mult / 4
                mult = mult - quartered_mult
                hand_chips = hand_chips + quartered_mult
                update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
                return {
                    message = "+" .. quartered_mult,
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
            state = "charging",
            current_ante = 0
        }
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { card.ability.extra.charge .. "/5 Charging" } }
        else
            return { vars = { "Ready!" } }
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
                
                if solar_count > 0 then
                    card.ability.extra.charge = math.min(5, card.ability.extra.charge + solar_count)
                    if card.ability.extra.charge >= 5 then
                        card.ability.extra.state = "ready"
                        local eval = function() return card.ability.extra.state == "ready" end
                        juice_card_until(card, eval, true)
                        return {
                            message = "Ready!",
                            sound = "fm_super_ready",
                            colour = G.C.ORANGE
                        }
                    else
                        return {
                            message = "Charging...",
                            colour = G.C.ORANGE
                        }
                    end
                end
            end
        end
        
        if not context.before and context.end_of_round and card.ability.extra.state == "ready" and #G.hand.cards > 0 then
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
            "number of retriggers depending on number of",
            "{C:attention}Solar{} cards played.",
            "Then, next hand with {C:attention}Solar{} cards",
            "will retrigger them that many times",
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
            local solar_count = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_radiant or
                   scoringCard.config.center == G.P_CENTERS.m_fm_restoration or
                   scoringCard.config.center == G.P_CENTERS.m_fm_scorch then
                    solar_count = solar_count + 1
                end
            end
        
            if card.ability.extra.state == "charging" then
                if solar_count > 0 then
                    card.ability.extra.charge = math.min(5, card.ability.extra.charge + solar_count)
                    if card.ability.extra.charge >= 5 then
                        card.ability.extra.state = "ready"
                        local eval = function() return card.ability.extra.state == "ready" end
                        juice_card_until(card, eval, true)
                        return {
                            message = "Ready!",
                            sound = "fm_super_ready",
                            colour = G.C.ORANGE
                        }
                    else
                        return {
                            message = "Charging...",
                            colour = G.C.ORANGE
                        }
                    end
                end
            elseif card.ability.extra.state == "ready" and solar_count > 0 then
                card.ability.extra.loaded_retriggers = solar_count
                card.ability.extra.state = "loaded"
                local eval = function() return card.ability.extra.state == "loaded" end
                juice_card_until(card, eval, true)
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
            "When charged and a {C:attention}#1#{} is played,",
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
                
                if arc_count > 0 then
                    card.ability.extra.charge = math.min(5, card.ability.extra.charge + arc_count)
                    
                    if card.ability.extra.charge >= 5 then
                        card.ability.extra.state = "ready"
                        local eval = function() return card.ability.extra.state == "ready" end
                        juice_card_until(card, eval, true)
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
                        if scoringCard.ability.set ~= "Enhanced" then
                            SMODS.calculate_effect({
                                message = "Jolted!",
                                sound = "fm_jolt",
                                colour = G.C.BLUE
                            }, scoringCard)
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    scoringCard:flip()
                                    scoringCard:set_ability(G.P_CENTERS.m_fm_jolt)
                                    scoringCard:flip()
                                    return true
                                end
                            }))
                        end
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
            "Charge with 5 {C:blue}Arc{} cards.",
            "When charged, 3 cards become {C:blue}Amplified{}.",
            "Playing {C:blue}Amplified{} cards grants {C:red}+5{} Mult",
            "per card. Continues until a hand without",
            "{C:blue}Amplified{} cards is played",
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
    pos = {x=3, y=1},
    config = {
        extra = {
            charge = 0,
            state = "charging",
            streak_mult = 0
        }
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { card.ability.extra.charge .. "/5 Charging" } }
        else
            return { vars = { card.ability.extra.streak_mult > 0 and
                "+" .. card.ability.extra.streak_mult .. " Mult" or "Ready!" } }
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local arc_count = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_jolt or
                   scoringCard.config.center == G.P_CENTERS.m_fm_amplified or
                   scoringCard.config.center == G.P_CENTERS.m_fm_blinded then
                    arc_count = arc_count + 1
                end
            end
    
            if arc_count > 0 and card.ability.extra.state == "charging" then
                card.ability.extra.charge = math.min(5, card.ability.extra.charge + arc_count)
                if card.ability.extra.charge >= 5 then
                    card.ability.extra.state = "ready"
                    local eval = function() return card.ability.extra.state == "ready" end
                    juice_card_until(card, eval, true)
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
            elseif card.ability.extra.state == "active" then
                local amplified_count = 0
                for _, scoringCard in ipairs(context.scoring_hand) do
                    if scoringCard.config.center == G.P_CENTERS.m_fm_amplified then
                        amplified_count = amplified_count + 1
                    end
                end
    
                if amplified_count > 0 then
                    card.ability.extra.streak_mult = card.ability.extra.streak_mult + (5 * amplified_count)
                    return {
                        mult = card.ability.extra.streak_mult,
                        message = "Stormed!",
                        sound = "fm_gathering_storm",
                        colour = G.C.BLUE
                    }
                else
                    card.ability.extra.state = "charging"
                    card.ability.extra.charge = 0
                    card.ability.extra.streak_mult = 0
                    return {
                        message = "Reset!",
                        colour = G.C.BLUE
                    }
                end
            end
        end
    
        if context.after and card.ability.extra.state == "ready" then
            local normal_cards = {}
            for _, handCard in ipairs(G.hand.cards) do
                if handCard.ability.set ~= "Enhanced" then
                    table.insert(normal_cards, handCard)
                end
            end
    
            for i = 1, math.min(3, #normal_cards) do
                local card_index = math.random(#normal_cards)
                local target_card = normal_cards[card_index]
                SMODS.calculate_effect({
                    message = "Amplified!",
                    sound = "fm_amplified",
                    colour = G.C.BLUE
                }, target_card)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        target_card:flip()
                        target_card:set_ability(G.P_CENTERS.m_fm_amplified)
                        target_card:flip()
                        return true
                    end
                }))
                table.remove(normal_cards, card_index)
            end
            card.ability.extra.state = "active"
        end
    end
}

SMODS.Joker{
    key = "ward_of_dawn",
    loc_txt = {
        name = "Ward of Dawn",
        text = {
            "Charge with 5 {C:purple}Void{} cards.",
            "When charged, grants {C:mult}+5{} Mult per",
            "{C:purple}Void{} card scored while an",
            "{C:purple}Overshield{} card is in hand.",
            "If your hand has 3 or more {C:purple}Overshield{} cards,",
            "{C:attention}double{} this bonus.",
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
    config = {
        extra = {
            charge = 0,
            state = "charging"
        }
     },
     loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { card.ability.extra.charge .. "/5 Charging" } }
        else
            return { vars = { "Ready!" } }
        end
    end,
    pos = {x=4, y=1},
    calculate = function(self, card, context)
        if context.joker_main then
            -- Charge with Void cards
            if card.ability.extra.state == "charging" then
                local void_count = 0
                for _, scoringCard in ipairs(context.scoring_hand) do
                    if scoringCard.config.center == G.P_CENTERS.m_fm_overshield or
                       scoringCard.config.center == G.P_CENTERS.m_fm_devour or
                       scoringCard.config.center == G.P_CENTERS.m_fm_volatile then
                        void_count = void_count + 1
                    end
                end
     
                if void_count > 0 then
                    card.ability.extra.charge = math.min(5, card.ability.extra.charge + void_count)
                    if card.ability.extra.charge >= 5 then
                        card.ability.extra.state = "ready"
                        local eval = function() return card.ability.extra.state == "ready" end
                        juice_card_until(card, eval, true)
                        return {
                            message = "Ready!",
                            sound = "fm_super_ready",
                            colour = G.C.PURPLE
                        }
                    else
                        return {
                            message = "Charging...",
                            colour = G.C.PURPLE
                        }
                    end
                end
            end
     
            -- Active effect
            if card.ability.extra.state == "ready" then
                local overshield_count = 0
                for _, handCard in ipairs(G.hand.cards) do
                    if handCard.config.center == G.P_CENTERS.m_fm_overshield then
                        overshield_count = overshield_count + 1
                    end
                end
            
                local void_count = 0
                for _, scoringCard in ipairs(context.scoring_hand) do
                    if scoringCard.config.center == G.P_CENTERS.m_fm_overshield or
                       scoringCard.config.center == G.P_CENTERS.m_fm_devour or
                       scoringCard.config.center == G.P_CENTERS.m_fm_volatile then
                        void_count = void_count + 1
                    end
                end
            
                if void_count > 0 and overshield_count > 0 then
                    local bonus = void_count * 5
                    if overshield_count >= 3 then
                        bonus = bonus * 2
                        card.ability.extra.state = "charging"
                        card.ability.extra.charge = 0
                        return {
                            message = "Empowered!",
                            sound = "fm_ward_of_dawn",
                            colour = G.C.PURPLE,
                            mult = bonus,
                        }
                    end
                    card.ability.extra.state = "charging"
                    card.ability.extra.charge = 0
                    return {
                        message = "Shielded!",
                        sound = "fm_ward_of_dawn",
                        colour = G.C.PURPLE,
                        mult = bonus,
                    }
                end
            end
        end
    end
}

SMODS.Sticker {
    key = "void_anchor",
    loc_txt = {
        name = "Void Anchor",
        text = { 
            "Adjacent cards to this card",
            "become {C:purple}Volatile{}.",
            "After 3 hands, this card will",
            "be {C:mult}destroyed{}.",
            "{C:inactive}({C:mult}#1#{C:inactive} uses left)"
        }
    },
    atlas = "Stickers",
    pos = {x = 1, y = 0},
    config = {
        extra = {
            hands_remaining = 3,
            uses_remaining = 3
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { self.config.extra.uses_remaining } }
    end,
    default_compat = true,
    calculate = function(self, card, context)
        if context.after then
            for i, handCard in ipairs(G.hand.cards) do
                if handCard == card then
                    if self.config.extra.uses_remaining > 0 then
                        if i > 1 then
                            G.hand.cards[i-1]:flip()
                            play_sound("fm_void_anchor")
                            G.hand.cards[i-1]:set_ability(G.P_CENTERS.m_fm_volatile)
                            G.hand.cards[i-1]:flip()
                        end
                        if i < #G.hand.cards then
                            G.hand.cards[i+1]:flip()
                            play_sound("fm_void_anchor")
                            G.hand.cards[i+1]:set_ability(G.P_CENTERS.m_fm_volatile)
                            G.hand.cards[i+1]:flip() 
                        end
                        self.config.extra.uses_remaining = self.config.extra.uses_remaining - 1
                    end

                    -- Handle countdown and destruction of the card
                    self.config.extra.hands_remaining = self.config.extra.hands_remaining - 1
                    if self.config.extra.hands_remaining <= 0 then
                        card:start_dissolve({G.C.PURPLE})
                    end
                    break
                end
            end
        end
    end,
    draw = function(self, card, layer)
        local t = G.TIMERS.REAL
        G.shared_stickers[self.key].role.draw_major = card
        
        G.shared_stickers[self.key]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, 
            card.children.center, 0.3, t * 0.2)
        G.shared_stickers[self.key]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, 
            card.children.center, 0.3, -t * 0.4)
        G.shared_stickers[self.key]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, 
            card.children.center, 0.3, t * 0.6)
    end
}

SMODS.Joker{
    key = "shadowshot",
    loc_txt = {
        name = "Shadowshot",
        text = {
            "Charge with 5 {C:purple}Void{} cards.",
            "When charged, a random card gains a",
            "{C:purple}Void Anchor{}. Adjacent cards to it become",
            "{C:purple}Volatile{}. After 3 hands,",
            "the anchored card will be destroyed.",
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
    pos = {x=5, y=1},
    config = {
        extra = {
            charge = 0,
            state = "charging",
            hands_remaining = 3
        }
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { card.ability.extra.charge .. "/5 Charging" } }
        else
            return { vars = { "Ready!" } }
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local void_count = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_overshield or
                   scoringCard.config.center == G.P_CENTERS.m_fm_devour or
                   scoringCard.config.center == G.P_CENTERS.m_fm_volatile then
                    void_count = void_count + 1
                end
            end
     
            if void_count > 0 and card.ability.extra.state == "charging" then
                card.ability.extra.charge = math.min(5, card.ability.extra.charge + void_count)
                if card.ability.extra.charge >= 5 then
                    card.ability.extra.state = "ready"
                    return {
                        message = "Ready!",
                        sound = "fm_super_ready",
                        colour = G.C.PURPLE
                    }
                else
                    return {
                        message = "Charging...",
                        colour = G.C.PURPLE
                    }
                end
            end
        end
        if context.after and card.ability.extra.state == "ready" then
            local available_cards = {}
            for _, handCard in ipairs(G.hand.cards) do
                table.insert(available_cards, handCard)
            end
        
            if #available_cards > 0 then
                local target_card = pseudorandom_element(available_cards, pseudoseed('shadowshot'))

                SMODS.calculate_effect({
                    message = "Tethered!",
                    sound = "fm_shadowshot",
                    colour = G.C.PURPLE
                }, target_card)

                target_card.void_anchored = true
                G.E_MANAGER:add_event(Event({
                    func = function()
                        target_card:juice_up()
                        SMODS.Stickers.fm_void_anchor:apply(target_card, true)
                        SMODS.Stickers.fm_void_anchor.config.extra.uses_remaining = 3
                        target_card.void_anchored = nil
                        card.ability.extra.state = "charging"
                        card.ability.extra.charge = 0
                        return true
                    end
                }))
            end
        end
    end
}

SMODS.Joker{
    key = "winters_wrath",
    loc_txt = {
        name = "Winter's Wrath",
        text = {
            "Charge with 5 {C:spades}Stasis{} cards.",
            "When charged, {C:attention}#1#{} will {C:spades}Slow{}",
            "all played cards and {C:spades}Freeze{} all played {C:spades}Slow{} cards.",
            "{C:attention}#2#{} will {C:spades}Shatter{} all played {C:spades}Freeze{} cards.",
            "{C:inactive}(Currently: {C:attention}#3#{C:inactive})"
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
    pos = {x=6, y=1},
    config = {
        extra = {
            charge = 0,
            state = "charging",
            freeze_hand = "Pair",
            shatter_hand = "Two Pair"
        }
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { 
                card.ability.extra.freeze_hand,
                card.ability.extra.shatter_hand,
                card.ability.extra.charge .. "/5 Charging" 
            }}
        else
            return { vars = { 
                card.ability.extra.freeze_hand,
                card.ability.extra.shatter_hand,
                "Ready!" 
            }}
        end
    end,
    calculate = function(self, card, context)
        -- Set new random hands at round end
        if context.end_of_round then
            local hand_pool = {
                "Pair", "Two Pair", "Three of a Kind",
                "Flush",
                "Full House"
            }
            
            local freeze_idx = math.random(#hand_pool)
            local freeze_hand = hand_pool[freeze_idx]
            table.remove(hand_pool, freeze_idx)
            
            local shatter_idx = math.random(#hand_pool)
            local shatter_hand = hand_pool[shatter_idx]
            
            card.ability.extra.freeze_hand = freeze_hand
            card.ability.extra.shatter_hand = shatter_hand
        end
    
        if context.joker_main then
            if card.ability.extra.state == "charging" then
                local stasis_count = 0
                for _, scoringCard in ipairs(context.scoring_hand) do
                    if scoringCard.config.center == G.P_CENTERS.m_fm_slow or
                       scoringCard.config.center == G.P_CENTERS.m_fm_freeze or
                       scoringCard.config.center == G.P_CENTERS.m_fm_stasis_crystal or
                       scoringCard.config.center == G.P_CENTERS.m_fm_shatter then
                        stasis_count = stasis_count + 1
                    end
                end
    
                if stasis_count > 0 then
                    card.ability.extra.charge = math.min(5, card.ability.extra.charge + stasis_count)
                    if card.ability.extra.charge >= 5 then
                        card.ability.extra.state = "ready"
                        local eval = function() return card.ability.extra.state == "ready" end
                        juice_card_until(card, eval, true)
                        return {
                            message = "Ready!",
                            sound = "fm_super_ready",
                            colour = G.C.SPADES
                        }
                    else
                        return {
                            message = "Charging...",
                            colour = G.C.SPADES
                        }
                    end
                end
            elseif card.ability.extra.state == "ready" then
                if context.poker_hands then
                    -- Check freeze hand
                    if (card.ability.extra.freeze_hand == "Flush" and 
                        (next(context.poker_hands["Flush"]) or next(context.poker_hands["Flush Five"]))) or
                       (card.ability.extra.freeze_hand == "Full House" and 
                        (next(context.poker_hands["Full House"]) or next(context.poker_hands["Flush House"]))) or
                       next(context.poker_hands[card.ability.extra.freeze_hand]) then
                        
                        -- Process existing Slow cards to Frozen first
                        for _, playCard in ipairs(G.play.cards) do
                            if playCard.config.center == G.P_CENTERS.m_fm_slow then
                                playCard:juice_up()
                                playCard:set_ability(G.P_CENTERS.m_fm_freeze)
                            end
                        end
                        -- Then convert unenhanced to Slow
                        for _, playCard in ipairs(G.play.cards) do
                            if playCard.ability.set ~= "Enhanced" and 
                               playCard.config.center ~= G.P_CENTERS.m_fm_freeze then
                                playCard:juice_up()
                                playCard:set_ability(G.P_CENTERS.m_fm_slow)
                            end
                        end
                        
                        card.ability.extra.state = "charging"
                        card.ability.extra.charge = 0

                        return {
                            message = "Cast!",
                            sound = "fm_winters_wrath",
                            colour = G.C.SUITS.Spades
                        }
                    
                    -- Check shatter hand
                    elseif (card.ability.extra.shatter_hand == "Flush" and 
                        (next(context.poker_hands["Flush"]) or next(context.poker_hands["Flush Five"]))) or
                       (card.ability.extra.shatter_hand == "Full House" and 
                        (next(context.poker_hands["Full House"]) or next(context.poker_hands["Flush House"]))) or
                       next(context.poker_hands[card.ability.extra.shatter_hand]) then
                        
                        for _, playCard in ipairs(G.play.cards) do
                            if playCard.config.center == G.P_CENTERS.m_fm_freeze then
                                playCard:juice_up()
                                playCard:set_ability(G.P_CENTERS.m_fm_shatter)
                            end
                        end

                        card.ability.extra.state = "charging"
                        card.ability.extra.charge = 0
            
                        return {
                            message = "Cast!",
                            sound = "fm_winters_wrath",
                            colour = G.C.SUITS.Spades
                        }
                    end
                end
            end
        end
    end
}

SMODS.Joker{
    key = "glacial_quake",
    loc_txt = {
        name = "Glacial Quake",
        text = {
            "Charge with 5 {C:spades}Stasis{} cards.",
            "Places 3 {C:spades}Stasis Crystals{}",
            "in your hand. They gain {C:mult}+5{} Mult",
            "per {C:spades}Freeze{} card played before",
            "destroying themselves in 3 hands.",
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
    pos = {x=7, y=1},
    config = {
        extra = {
            charge = 0,
            state = "charging"
        }
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { card.ability.extra.charge .. "/5 Charging" } }
        else
            return { vars = { "Ready!" } }
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local stasis_count = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_slow or
                   scoringCard.config.center == G.P_CENTERS.m_fm_freeze or
                   scoringCard.config.center == G.P_CENTERS.m_fm_stasis_crystal or
                   scoringCard.config.center == G.P_CENTERS.m_fm_shatter then
                    stasis_count = stasis_count + 1
                end
            end
     
            if stasis_count > 0 and card.ability.extra.state == "charging" then
                card.ability.extra.charge = math.min(5, card.ability.extra.charge + stasis_count)
                if card.ability.extra.charge >= 5 then
                    card.ability.extra.state = "ready"
                    return {
                        message = "Ready!",
                        sound = "fm_super_ready",
                        colour = G.C.SUITS.Spades
                    }
                else
                    return {
                        message = "Charging...",
                        colour = G.C.SUITS.Spades
                    }
                end
            end
        end
     
        if card.ability.extra.state == "ready" and context.after then
            for i = 1, 3 do
                local crystal = Card(G.hand.T.x + (i-2)*G.CARD_W, G.hand.T.y, 
                                  G.CARD_W, G.CARD_H, G.P_CARDS.empty, 
                                  G.P_CENTERS.m_fm_stasis_crystal)
                crystal:start_materialize({G.C.SECONDARY_SET.Enhanced})
                draw_card(G.play, G.hand, 90, 'up', false, crystal)
            end
            
            card.ability.extra.state = "charging"
            card.ability.extra.charge = 0
            
            G.E_MANAGER:add_event(Event({
                func = function()
                    return {
                        message = "Quaked!",
                        sound = "fm_glacial_quake",
                        colour = G.C.SUITS.Spades
                    }
                end
            }))
        end
    end
}

SMODS.Joker{
    key = "needlestorm",
    loc_txt = {
        name = "Needlestorm",
        text = {
            "Charge with 5 {C:green}Strand{} cards.",
            "When charged, grants {C:green}Unravel{}",
            "to 5 random cards in hand.",
            "Each card starts with Threads",
            "equal to its rank.",
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
    pos = {x=8, y=1},
    config = {
        extra = {
            charge = 0,
            state = "charging"
        }
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { card.ability.extra.charge .. "/5 Charging" } }
        else
            return { vars = { "Ready!" } }
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local strand_count = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_tangle or
                   scoringCard.config.center == G.P_CENTERS.m_fm_wovenmail or
                   scoringCard.config.center == G.P_CENTERS.m_fm_unravel then
                    strand_count = strand_count + 1
                end
            end
    
            if strand_count > 0 and card.ability.extra.state == "charging" then
                card.ability.extra.charge = math.min(5, card.ability.extra.charge + strand_count)
                if card.ability.extra.charge >= 5 then
                    card.ability.extra.state = "ready"
                    local eval = function() return card.ability.extra.state == "ready" end
                    juice_card_until(card, eval, true)
                    return {
                        message = "Ready!",
                        sound = "fm_super_ready",
                        colour = G.C.GREEN
                    }
                else
                    return {
                        message = "Charging...",
                        colour = G.C.GREEN
                    }
                end
            end
        end
    
        if context.after and card.ability.extra.state == "ready" then
            local normal_cards = {}
            for _, handCard in ipairs(G.hand.cards) do
                if handCard.ability.set ~= "Enhanced" then
                    table.insert(normal_cards, handCard)
                end
            end
    
            for i = 1, math.min(5, #normal_cards) do
                local card_idx = math.random(#normal_cards)
                local target_card = normal_cards[card_idx]
                local thread_count = target_card:get_id()
    
                SMODS.calculate_effect({
                    message = thread_count .. " Threads!",
                    sound = "fm_needlestorm",
                    colour = G.C.GREEN
                }, target_card)
    
                G.E_MANAGER:add_event(Event({
                    func = function()
                        target_card:flip()
                        target_card:set_ability(G.P_CENTERS.m_fm_unravel)
                        target_card.ability.extra.threads = thread_count
                        target_card:flip()
                        return true
                    end
                }))
                
                table.remove(normal_cards, card_idx)
            end
    
            card.ability.extra.state = "charging"
            card.ability.extra.charge = 0
        end
    end
}

SMODS.Joker{
    key = "bladefury",
    loc_txt = {
        name = "Bladefury",
        text = {
            "Charge with 5 {C:green}Strand{} cards.",
            "When charged, playing a {C:attention}Pair{}",
            "or a {C:attention}High Card{} will",
            "slice them into equivalent pairs,",
            "cloning them but with halved ranks.",
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
    pos = {x=9, y=1},
    config = {
        extra = {
            charge = 0,
            state = "charging"
        }
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { card.ability.extra.charge .. "/5 Charging" } }
        else
            return { vars = { "Ready!" } }
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if card.ability.extra.state == "charging" then
                local strand_count = 0
                for _, scoringCard in ipairs(context.scoring_hand) do
                    if scoringCard.config.center == G.P_CENTERS.m_fm_tangle or
                       scoringCard.config.center == G.P_CENTERS.m_fm_unravel or
                       scoringCard.config.center == G.P_CENTERS.m_fm_wovenmail then
                        strand_count = strand_count + 1
                    end
                end
     
                if strand_count > 0 then
                    card.ability.extra.charge = math.min(5, card.ability.extra.charge + strand_count)
                    if card.ability.extra.charge >= 5 then
                        card.ability.extra.state = "ready"
                        local eval = function() return card.ability.extra.state == "ready" end
                        juice_card_until(card, eval, true)
                        return {
                            message = "Ready!",
                            sound = "fm_super_ready",
                            colour = G.C.GREEN
                        }
                    else
                        return {
                            message = "Charging...",
                            colour = G.C.GREEN
                        }
                    end
                end
            end

            if card.ability.extra.state == "ready" and (next(context.poker_hands["Pair"]) or next(context.poker_hands["High Card"])) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for _, playCard in ipairs(context.scoring_hand) do
                            if playCard.base.id > 2 and not SMODS.always_scores(playCard) then
                                local new_rank
                                for _, k in ipairs(SMODS.Rank.obj_buffer) do
                                    if SMODS.Ranks[k].nominal >= playCard.base.nominal/2 then
                                        new_rank = k
                                        break
                                    end
                                end
                                
                                playCard:juice_up()
                                SMODS.change_base(playCard, playCard.base.suit, new_rank)
                                
                                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                                local new_card = copy_card(playCard, nil, nil, G.playing_card)
                                new_card.T.y = playCard.T.y - G.CARD_H
                                table.insert(G.playing_cards, new_card)
                                G.deck.config.card_limit = G.deck.config.card_limit + 1
                                draw_card(G.play, G.deck, 90, 'up', nil, new_card)
                                new_card:start_materialize()
                            end
                        end
                        return true
                    end
                }))
             
                card.ability.extra.state = "charging"
                card.ability.extra.charge = 0
                return {
                    message = "Sliced!",
                    sound = "fm_bladefury",
                    colour = G.C.GREEN
                }
            end
        end
    end
}

SMODS.Sticker {
    key = "catatonic",
    loc_txt = {
        name = "Catatonic",
        text = {
            "Cannot be played or discarded",
            "For each hand played, this card",
            "gains {C:mult}+10{} Mult",
            "Disappears after the round ends",
            "{C:inactive}(Currently: {C:mult}+#1#{C:inactive} Mult)"
        }
    },
    default_compat = true,
    sets = {
        Joker = false
    },
    atlas = "Stickers",
    pos = {x = 2, y = 0},
    config = {
        extra = {
            accumulated_mult = 10
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.catatonic_mult or self.config.extra.accumulated_mult } }
    end,
    calculate = function(self, card, context)
        if not card.catatonic_mult then
            card.catatonic_mult = self.config.extra.accumulated_mult
        end
        
        if card.area == G.hand and context.after then
            card.catatonic_mult = card.catatonic_mult + 10
            return {
                message = "Mult Up!",
                colour = G.C.MULT
            }
        end
        
        if card.area == G.hand and context.main_scoring then
            return {
                mult = card.catatonic_mult
            }
        end
        
        if context.end_of_round then
            card:flip()
            SMODS.Stickers.fm_catatonic:apply(card, false)
            card:flip()
            card.catatonic_mult = nil
        end
    end
}

SMODS.Joker{
    key = "witnesss_shatter",
    loc_txt = {
        name = "Witness's Shatter",
        text = {
            "Charge with 5 {C:black}Resonance{} cards.",
            "When charged, {C:attention}#1#{} random cards",
            "become {C:black}Catatonic{}, making them {C:mult}unplayable{}",
            "and {C:mult}undiscardable{}, but gaining",
            "{C:mult}+10{} Mult per hand played",
            "until the round ends.",
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
    pos = {x=10, y=1},
    config = {
        extra = {
            charge = 0,
            state = "charging",
            catatonic_count = 3
        }
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { 
                card.ability.extra.catatonic_count, 
                card.ability.extra.charge .. "/5 Charging" 
            }}
        else
            return { vars = { 
                card.ability.extra.catatonic_count, 
                "Ready!" 
            }}
        end
    end,
    calculate = function(self, card, context)
        if context.end_of_round then
            card.ability.extra.catatonic_count = math.random(1, 3)
        end
        
        if context.joker_main then
            local resonance_count = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_resonant or
                   scoringCard.config.center == G.P_CENTERS.m_fm_dissected or
                   scoringCard.config.center == G.P_CENTERS.m_fm_finalized then
                    resonance_count = resonance_count + 1
                end
            end

            if resonance_count > 0 and card.ability.extra.state == "charging" then
                card.ability.extra.charge = math.min(5, card.ability.extra.charge + resonance_count)
                if card.ability.extra.charge >= 5 then
                    card.ability.extra.state = "ready"
                    local eval = function() return card.ability.extra.state == "ready" end
                    juice_card_until(card, eval, true)
                    return {
                        message = "Ready!",
                        sound = "fm_super_ready",
                        colour = G.C.BLACK
                    }
                else
                    return {
                        message = "Charging...",
                        colour = G.C.BLACK
                    }
                end
            end
        end
        
        if context.after and card.ability.extra.state == "ready" then
            local available_cards = {}
            for _, handCard in ipairs(G.hand.cards) do

                if handCard.ability.set ~= "Enhanced" then
                    table.insert(available_cards, handCard)
                end
            end
            
            -- Calculate how many cards to become catatonic (min of available cards or config value)
            local cards_to_catatonic = math.min(#available_cards, card.ability.extra.catatonic_count)
            
            for i = 1, cards_to_catatonic do
                if #available_cards > 0 then
                    -- Select random card
                    local card_idx = math.random(#available_cards)
                    local target_card = available_cards[card_idx]
                    
                    -- Apply catatonic effect with visual feedback
                    SMODS.calculate_effect({
                        message = "Decimated!",
                        sound = "fm_witnesss_shatter",
                        colour = G.C.BLACK
                    }, target_card)
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target_card:juice_up()
                            SMODS.Stickers.fm_catatonic:apply(target_card, true)
                            return true
                        end
                    }))
                    
                    -- Remove from available cards
                    table.remove(available_cards, card_idx)
                end
            end
            
            -- Reset charge state
            card.ability.extra.state = "charging"
            card.ability.extra.charge = 0
        end
    end
}

SMODS.Joker{
    key = "resonate_whirlwind",
    loc_txt = {
        name = "Resonate Whirlwind",
        text = {
            "Charge with 5 Resonance cards.",
            "When charged, all cards except those of",
            "suit {C:attention}#1#{} are subjected to random",
            "rank changes. Surviving cards gain",
            "{C:black}Resonance{} enhancements.",
            "{C:inactive}(Currently: {C:attention}#2#{C:inactive})"
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
    config = {
        extra = {
            charge = 0,
            state = "charging",
            protected_suit = "Hearts"
        }
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { 
                card.ability.extra.protected_suit or "None",
                card.ability.extra.charge .. "/5 Charging" 
            }}
        else
            return { vars = { 
                card.ability.extra.protected_suit or "None",
                "Ready!" 
            }}
        end
    end,
    calculate = function(self, card, context)
        if context.end_of_round then
            local suit_key = pseudorandom_element(SMODS.Suit.obj_buffer, pseudoseed('whirlwind_suit'))
            card.ability.extra.protected_suit = suit_key
        end
        
        if context.joker_main then
            local resonance_count = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_resonant or
                   scoringCard.config.center == G.P_CENTERS.m_fm_dissected or
                   scoringCard.config.center == G.P_CENTERS.m_fm_finalized then
                    resonance_count = resonance_count + 1
                end
            end

            if resonance_count > 0 and card.ability.extra.state == "charging" then
                card.ability.extra.charge = math.min(5, card.ability.extra.charge + resonance_count)
                if card.ability.extra.charge >= 5 then
                    card.ability.extra.state = "ready"
                    local eval = function() return card.ability.extra.state == "ready" end
                    juice_card_until(card, eval, true)
                    return {
                        message = "Ready!",
                        sound = "fm_super_ready",
                        colour = G.C.BLACK
                    }
                else
                    return {
                        message = "Charging...",
                        colour = G.C.BLACK
                    }
                end
            end
        end

        if context.after and card.ability.extra.state == "ready" then
            local protected_cards = {}
            local unprotected_cards = {}

            for _, handCard in ipairs(G.hand.cards) do
                if handCard.base.suit == card.ability.extra.protected_suit then
                    table.insert(protected_cards, handCard)
                else
                    table.insert(unprotected_cards, handCard)
                end
            end

            for _, protectedCard in ipairs(protected_cards) do
                local enhancements = {
                    G.P_CENTERS.m_fm_resonant,
                    G.P_CENTERS.m_fm_dissected,
                    G.P_CENTERS.m_fm_finalized
                }
                
                local enhancement = enhancements[math.random(#enhancements)]
                
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    func = function()
                        protectedCard:flip()
                        protectedCard:juice_up()
                        protectedCard:set_ability(enhancement)
                        G.hand:add_to_highlighted(protectedCard)
                        G.E_MANAGER:add_event(Event({
                            trigger = "before",
                            func = function()
                                protectedCard:flip()
                                G.hand:remove_from_highlighted(protectedCard)
                                return true
                            end
                        }))
                        return true
                    end
                }))
            end
            
            for _, unprotectedCard in ipairs(unprotected_cards) do
                local rank_change = math.random(-3, 3)
                if rank_change == 0 then rank_change = 1 end
                
                G.E_MANAGER:add_event(Event({
                    trigger = "before",
                    func = function()
                        local current_rank = unprotectedCard.base.value
                        local current_idx = nil
                        
                        for idx, rank_key in ipairs(SMODS.Rank.obj_buffer) do
                            if rank_key == current_rank then
                                current_idx = idx
                                break
                            end
                        end
                        
                        if current_idx then
                            -- Calculate new rank index (bounded by buffer size)
                            local new_idx = math.max(1, math.min(#SMODS.Rank.obj_buffer, current_idx + rank_change))
                            local new_rank = SMODS.Rank.obj_buffer[new_idx]
                            
                            -- Apply rank change
                            unprotectedCard:flip()
                            unprotectedCard:juice_up()
                            SMODS.change_base(unprotectedCard, unprotectedCard.base.suit, new_rank)
                            G.hand:add_to_highlighted(unprotectedCard)
                            
                            -- Show message indicating rank change
                            local message = rank_change > 0 and "+" .. rank_change .. " Rank!" or rank_change .. " Rank!"
                            local color = rank_change > 0 and G.C.BLACK or G.C.RED
                            
                            SMODS.calculate_effect({
                                message = message,
                                colour = color
                            }, unprotectedCard)

                            G.E_MANAGER:add_event(Event({
                                trigger = "before",
                                func = function()
                                    unprotectedCard:flip()
                                    G.hand:remove_from_highlighted(unprotectedCard)
                                    return true
                                end
                            }))
                        end
                        return true
                    end
                }))
            end
            
            -- Reset after use
            card.ability.extra.state = "charging"
            card.ability.extra.charge = 0
            
            return {
                message = "Whirlwind!",
                sound = "fm_resonate_whirlwind",
                colour = G.C.BLACK
            }
        end
    end
}

SMODS.Joker{
    key = "transcendence",
    loc_txt = {
        name = "Transcendence",
        text = {
            "Charge with 5 {X:dark_edition,C:white}Prismatic{} cards.",
            "When charged, the next scoring hand will",
            "convert all {C:attention}Light{} cards to {C:darkgray}Dark{} cards and",
            "all {C:darkgray}Dark{} cards to {C:attention}Light{} cards,",
            "then score again with the converted cards.",
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
    pos = {x=1, y=2},
    config = {
        extra = {
            charge = 0,
            state = "charging"
        }
    },
    loc_vars = function(self, info_queue, card)
        if card.ability.extra.state == "charging" then
            return { vars = { card.ability.extra.charge .. "/5 Charging" } }
        else
            return { vars = { "Ready!" } }
        end
    end,
    calculate = function(self, card, context)
        -- Charge with Prismatic cards
        if context.joker_main then
            -- Count Prismatic cards
            local prismatic_count = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_transcendent then
                    prismatic_count = prismatic_count + 1
                end
            end
     
            if prismatic_count > 0 and card.ability.extra.state == "charging" then
                card.ability.extra.charge = math.min(5, card.ability.extra.charge + prismatic_count)
                if card.ability.extra.charge >= 5 then
                    card.ability.extra.state = "ready"
                    local eval = function() return card.ability.extra.state == "ready" end
                    juice_card_until(card, eval, true)
                    return {
                        message = "Ready!",
                        sound = "fm_super_ready",
                        colour = G.C.WHITE
                    }
                else
                    return {
                        message = "Charging...",
                        colour = G.C.WHITE
                    }
                end
            end

            -- Main effect when charged
            if card.ability.extra.state == "ready" then
                -- Define Light and Dark enhancement centers
                local light_centers = {
                    G.P_CENTERS.m_fm_scorch,
                    G.P_CENTERS.m_fm_radiant,
                    G.P_CENTERS.m_fm_restoration,
                    G.P_CENTERS.m_fm_amplified,
                    G.P_CENTERS.m_fm_jolt,
                    G.P_CENTERS.m_fm_blinded,
                    G.P_CENTERS.m_fm_devour,
                    G.P_CENTERS.m_fm_volatile,
                    G.P_CENTERS.m_fm_overshield
                }
                
                local dark_centers = {
                    G.P_CENTERS.m_fm_stasis_crystal,
                    G.P_CENTERS.m_fm_slow,
                    G.P_CENTERS.m_fm_freeze,
                    G.P_CENTERS.m_fm_shatter,
                    G.P_CENTERS.m_fm_tangle,
                    G.P_CENTERS.m_fm_wovenmail,
                    G.P_CENTERS.m_fm_unravel,
                    G.P_CENTERS.m_fm_resonant,
                    G.P_CENTERS.m_fm_dissected,
                    G.P_CENTERS.m_fm_finalized
                }
                
                -- Helper function to check if a center is in a list
                local function center_in_list(center, list)
                    for _, c in ipairs(list) do
                        if center == c then
                            return true
                        end
                    end
                    return false
                end
                
                -- Convert cards in the scoring hand
                for _, scoringCard in ipairs(context.scoring_hand) do
                    -- Skip prismatic cards
                    if scoringCard.config.center ~= G.P_CENTERS.m_fm_transcendent then
                        local new_center
                        
                        -- Convert Light to Dark
                        if center_in_list(scoringCard.config.center, light_centers) then
                            new_center = dark_centers[math.random(#dark_centers)]
                            
                            G.E_MANAGER:add_event(Event({
                                trigger = "immediate",
                                func = function()
                                    scoringCard:flip()
                                    scoringCard:juice_up()
                                    scoringCard:set_ability(new_center)
                                    SMODS.calculate_effect({
                                        message = "Darkened!",
                                        sound = "fm_transcendence",
                                        colour = G.C.BLACK
                                    }, scoringCard)
                                    scoringCard:flip()
                                    return true
                                end
                            }))
                            
                        -- Convert Dark to Light
                        elseif center_in_list(scoringCard.config.center, dark_centers) then
                            new_center = light_centers[math.random(#light_centers)]
                            
                            G.E_MANAGER:add_event(Event({
                                trigger = "immediate",
                                func = function()
                                    scoringCard:flip()
                                    scoringCard:juice_up()
                                    scoringCard:set_ability(new_center)
                                    SMODS.calculate_effect({
                                        message = "Illuminated!",
                                        sound = "fm_transcendence",
                                        colour = G.C.WHITE
                                    }, scoringCard)
                                    scoringCard:flip()
                                    return true
                                end
                            }))
                        end
                    end
                end
                
                -- Reset the joker state
                card.ability.extra.state = "charging"
                card.ability.extra.charge = 0
            end
        end
    end
}

SMODS.Joker{
    key = "meditation",
    loc_txt = {
        name = "Meditation",
        text = {
            "Score {C:attention}7{} elemental cards of the same subclass",
            "{C:attention}in a row{} to grant a Subclass Edition to a",
            "random card in hand",
            "{C:inactive}({C:attention}#1#{C:inactive}, {C:attention}#2#{C:inactive}/7 cards)",
            "{C:mult}Self-destructs{} after granting a Subclass Edition"
        }
    },
    atlas = 'Jokers',
    rarity = 4,
    cost = 10,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=2, y=2},
    soul_pos = {x=10, y=2},
    config = {
        extra = {
            current_subclass = "None",
            count = 0,
            last_played_card_id = nil
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.current_subclass == "None" and "None" or card.ability.extra.current_subclass,
            card.ability.extra.count
        }}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local subclass_centers = {
                ["Void"] = {
                    G.P_CENTERS.m_fm_overshield,
                    G.P_CENTERS.m_fm_devour,
                    G.P_CENTERS.m_fm_volatile
                },
                ["Solar"] = {
                    G.P_CENTERS.m_fm_radiant,
                    G.P_CENTERS.m_fm_restoration,
                    G.P_CENTERS.m_fm_scorch
                },
                ["Arc"] = {
                    G.P_CENTERS.m_fm_jolt,
                    G.P_CENTERS.m_fm_amplified,
                    G.P_CENTERS.m_fm_blinded
                },
                ["Stasis"] = {
                    G.P_CENTERS.m_fm_slow,
                    G.P_CENTERS.m_fm_freeze,
                    G.P_CENTERS.m_fm_stasis_crystal,
                    G.P_CENTERS.m_fm_shatter
                },
                ["Strand"] = {
                    G.P_CENTERS.m_fm_tangle,
                    G.P_CENTERS.m_fm_wovenmail,
                    G.P_CENTERS.m_fm_unravel
                },
                ["Resonance"] = {
                    G.P_CENTERS.m_fm_resonant,
                    G.P_CENTERS.m_fm_dissected,
                    G.P_CENTERS.m_fm_finalized
                },
                ["Prismatic"] = {
                    G.P_CENTERS.m_fm_transcendent
                }
            }
            
            -- Define subclass to soul_pos mapping
            local subclass_to_soul_pos = {
                ["Void"] = {x = 3, y = 2},
                ["Solar"] = {x = 4, y = 2},
                ["Arc"] = {x = 5, y = 2},
                ["Stasis"] = {x = 6, y = 2},
                ["Strand"] = {x = 7, y = 2},
                ["Resonance"] = {x = 8, y = 2},
                ["Prismatic"] = {x = 9, y = 2},
                ["None"] = {x = 10, y = 2}
            }
            
            -- Define subclass to Edition center mapping
            local subclass_to_edition = {
                ["Void"] = 'e_fm_voidwalker',
                ["Solar"] = 'e_fm_sunbreaker',
                ["Arc"] = 'e_fm_arcstrider',
                ["Stasis"] = 'e_fm_behemoth',
                ["Strand"] = 'e_fm_threadrunner',
                ["Resonance"] = 'e_fm_architect',
                ["Prismatic"] = 'e_fm_legend'
            }
            
            -- Detect played subclass in this hand
            local detected_subclass = "None"
            local scored_cards = context.scoring_hand or {}
            
            for _, scoringCard in ipairs(scored_cards) do
                for subclass, centers in pairs(subclass_centers) do
                    for _, center in ipairs(centers) do
                        if scoringCard.config.center == center then
                            detected_subclass = subclass
                            break
                        end
                    end
                    if detected_subclass ~= "None" then break end
                end
                if detected_subclass ~= "None" then break end
            end
            
            -- If no subclass detected in this hand, skip processing
            if detected_subclass == "None" then 
                return 
            end
            
            -- Check if we're continuing a streak or starting a new one
            if card.ability.extra.current_subclass == detected_subclass then
                -- Continue the streak
                card.ability.extra.count = card.ability.extra.count + 1
            else
                -- Start a new streak
                card.ability.extra.current_subclass = detected_subclass
                card.ability.extra.count = 1
                
                -- Update soul_pos to match the new subclass
                card:flip()
                card:juice_up()
                card.children.floating_sprite:set_sprite_pos(subclass_to_soul_pos[detected_subclass])
                card:flip()
            end
            
            -- If reached 7 cards, grant edition
            if card.ability.extra.count >= 7 then
                -- Find eligible cards in hand
                local eligible_cards = {}
                for _, handCard in ipairs(G.hand.cards) do
                    if handCard.ability.set ~= "Enhanced" and handCard.ability.set ~= "Edition" then
                        table.insert(eligible_cards, handCard)
                    end
                end
                
                -- Apply edition if we have eligible cards
                if #eligible_cards > 0 then
                    local target_card = eligible_cards[math.random(#eligible_cards)]
                    local edition_center = subclass_to_edition[card.ability.extra.current_subclass]
                    
                    -- Play effects
                    local subclass_colors = {
                        ["Void"] = G.C.PURPLE,
                        ["Solar"] = G.C.ORANGE,
                        ["Arc"] = G.C.BLUE,
                        ["Stasis"] = G.C.SUITS.Spades,
                        ["Strand"] = G.C.GREEN,
                        ["Resonance"] = G.C.BLACK,
                        ["Prismatic"] = G.C.DARK_EDITION
                    }
                    
                    local color = subclass_colors[card.ability.extra.current_subclass] or G.C.WHITE
                    local message = card.ability.extra.current_subclass .. " Enlightenment!"
                    
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound("fm_meditation_sweep")
                            local count = 0
                            local shake_event
                            shake_event = Event({
                                func = function()
                                    if count <= 30 then
                                        card:juice_up(1, 1)
                                        count = count + 1
                                        G.E_MANAGER:add_event(shake_event)
                                    else

                                        play_sound("fm_meditation_explosion")
                                        card:start_dissolve({G.C.DARK_EDITION})
                                        
                                        G.E_MANAGER:add_event(Event({
                                            trigger = "after",
                                            delay = 3.0,
                                            func = function()
                                                local target_count = 0
                                                local target_shake_event
                                                target_shake_event = Event({
                                                    trigger = "after",
                                                    delay = 0.05,
                                                    func = function()
                                                        if target_count <= 15 then
                                                            target_card:juice_up(1, 1)
                                                            target_count = target_count + 1
                                                            G.E_MANAGER:add_event(target_shake_event)
                                                        else
                                                            target_card:juice_up(8, 8)
                                                            G.hand:add_to_highlighted(card)
                                                            target_card:set_edition(edition_center, true)
                                                            G.hand:remove_from_highlighted(card)
                                                            return true
                                                        end
                                                        return true
                                                    end
                                                })
                                                G.E_MANAGER:add_event(target_shake_event)
                                                return true
                                            end
                                        }))
                                        return true
                                    end
                                    return true
                                end
                            })
                            G.E_MANAGER:add_event(shake_event)
                            return true
                        end
                    }))
                end
            else
                -- Update progress message
                return {
                    message = card.ability.extra.count .. "/7 " .. card.ability.extra.current_subclass,
                    colour = G.C.WHITE
                }
            end
        end
    end
}
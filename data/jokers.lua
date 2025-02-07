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
                    trigger = 'after',
                    delay = 0.3,
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
                    trigger = 'after',
                    delay = 0.15,
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
                trigger = 'after',
                delay = 0.3,
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
            "Charge with 5 {C:green}Strand{} cards.",
            "When charged, playing two cards only in {C:attention}Pair{}",
            "or one card only in {C:attention}High Card{} will",
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

            if card.ability.extra.state == "ready" and ((next(context.poker_hands["Pair"]) and #context.scoring_hand == 2) or (next(context.poker_hands["High Card"]) and #context.scoring_hand == 1)) then
                for _, playCard in ipairs(context.scoring_hand) do  -- Use scoring_hand instead of play.cards
                    -- Only slice cards that can be halved
                    if playCard.base.id > 2 then
                        playCard.to_slice = true
                    end
                end

                -- Only proceed if valid cards to slice
                local valid_slice = false
                for _, playCard in ipairs(context.scoring_hand) do
                    if playCard.to_slice then
                        valid_slice = true
                        break
                    end
                end

                if valid_slice then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.5,
                        func = function()
                            for _, playCard in ipairs(context.scoring_hand) do
                                if playCard.to_slice then
                                    local new_rank = math.ceil(playCard.base.id / 2)
                                    
                                    -- Create new cards first, then remove original
                                    for j = 1, 2 do
                                        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                                        local new_card = copy_card(playCard, nil, nil, G.playing_card)
                                        new_card:set_base(G.P_CARDS[string.sub(playCard.base.suit, 1, 1)..'_' .. 
                                            (new_rank < 10 and tostring(new_rank) or
                                                new_rank == 10 and 'T' or
                                                new_rank == 11 and 'J' or
                                                new_rank == 12 and 'Q' or
                                                new_rank == 13 and 'K' or 'A')])
                                        new_card.T.x = playCard.T.x + (j*2-3)*G.CARD_W
                                        table.insert(G.playing_cards, new_card)
                                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                                        draw_card(G.play, G.deck, 90, 'up', nil, new_card)
                                        new_card:start_materialize()
                                    end
                                    draw_card(G.play, G.discard, 90, 'down', false, playCard)
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

SMODS.Joker{
    key = "transcendence",
    loc_txt = {
        name = "Transcendence",
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
    pos = {x=1, y=2},
    calculate = function(self, card, context)
        if context.joker_main then
            
        end
    end
}

SMODS.Joker{
    key = "meditation",
    loc_txt = {
        name = "Meditation",
        text = {
            "Play 7 cards of the same subclass",
            "in a row to grant a Subclass Edition to a",
            "card in hand"
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=2, y=2},
    soul_pos = {x=3, y=2},
    calculate = function(self, card, context)
        if context.joker_main then
            
        end
    end
}
-- SMODS.Joker{
--     key = "balance",
--     loc_txt = {
--         name = "Facet of Balance",
--         text = {
--             "If the total Chip or Mult amount",
--             "is lower than the other, {C:attention}sacrifice a",
--             "quarter of the higher amount{} to be added",
--             "to the lower amount"
--         }
--     },
--     atlas = 'Jokers',
--     rarity = 2,
--     cost = 4,
--     blueprint_compat = true,
--     eternal_compat = true,
--     perishable_compat = true,
--     unlocked = true,
--     discovered = true,
--     pos = {x=0, y=0},
--     calculate = function(self, card, context)
--         if context.joker_main then
--             if hand_chips > mult then
--                 local quartered_chips = hand_chips / 4
--                 hand_chips = hand_chips - quartered_chips
--                 mult = mult + quartered_chips
--                 update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
--                 return {
--                     message = "+" .. quartered_chips .. " Mult",
--                     colour = G.C.MULT,
--                     card = card
--                 }
--             elseif hand_chips < mult then
--                 local quartered_mult = mult / 4
--                 mult = mult - quartered_mult
--                 hand_chips = hand_chips + quartered_mult
--                 update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
--                 return {
--                     message = "+" .. quartered_mult,
--                     colour = G.C.CHIPS,
--                     card = card
--                 }
--             end
--         end
--     end
-- }

SMODS.Joker{
    key = "well_of_radiance",
    loc_txt = {
        name = "Well of Radiance",
        text = {
            "Charge with 5 {C:attention}Solar{} cards",
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
                       scoringCard.config.center == G.P_CENTERS.m_fm_scorch or
                       scoringCard.config.center == G.P_CENTERS.m_fm_cure then
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
            "Charge with 5 {C:attention}Solar{} cards",
            "Once charged, next hand played sets",
            "number of retriggers depending on number of",
            "{C:attention}Solar{} cards played",
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
                    scoringCard.config.center == G.P_CENTERS.m_fm_scorch or
                    scoringCard.config.center == G.P_CENTERS.m_fm_cure then
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
                       scoringCard.config.center == G.P_CENTERS.m_fm_scorch or
                       scoringCard.config.center == G.P_CENTERS.m_fm_cure then
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
                context.other_card.config.center == G.P_CENTERS.m_fm_scorch or
                context.other_card.config.center == G.P_CENTERS.m_fm_cure) then
                
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
            "Charge with 5 {C:blue}Arc{} cards",
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
            target_suit = nil
        }
    },
    init = function(self)
        local suits = SMODS.Suit.obj_buffer
        self.ability.extra.target_suit = pseudorandom_element(suits, pseudoseed("CHARGE!"))
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { 
            card.ability.extra.target_suit or "None",
            card.ability.extra.state == "charging" and 
                card.ability.extra.charge .. "/5 Charging" or "Ready!"
        }}
    end,
    calculate = function(self, card, context)
        if context.end_of_round then
            local suits = SMODS.Suit.obj_buffer
            card.ability.extra.target_suit = pseudorandom_element(suits, pseudoseed("CHARGE!"))
        end

        if context.joker_main then
            if card.ability.extra.state == "charging" then
                local arc_count = 0
                for _, scoringCard in ipairs(context.scoring_hand) do
                    if scoringCard.config.center == G.P_CENTERS.m_fm_jolt or
                       scoringCard.config.center == G.P_CENTERS.m_fm_amplified or
                       scoringCard.config.center == G.P_CENTERS.m_fm_blinded or
                       scoringCard.config.center == G.P_CENTERS.m_fm_bolt_charge then
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
            "Charge with 5 {C:blue}Arc{} cards",
            "When charged, 3 cards become {C:blue}Amplified{}",
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
                   scoringCard.config.center == G.P_CENTERS.m_fm_blinded or
                   scoringCard.config.center == G.P_CENTERS.m_fm_bolt_charge then
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
                local card_index = pseudorandom("test", 1, #normal_cards)
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
            "Charge with 5 {C:purple}Void{} cards",
            "When charged, grants {C:mult}+5{} Mult per",
            "{C:purple}Void{} card scored while an",
            "{C:purple}Overshield{} card is in hand",
            "If your hand has 3 or more {C:purple}Overshield{} cards,",
            "{C:attention}double{} this bonus",
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
            state = "charging",
            starvation_applied = false
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
                       scoringCard.config.center == G.P_CENTERS.m_fm_volatile or
                       scoringCard.config.center == G.P_CENTERS.m_fm_suppress then
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
                       scoringCard.config.center == G.P_CENTERS.m_fm_volatile or
                       scoringCard.config.center == G.P_CENTERS.m_fm_suppress then
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
            "become {C:purple}Volatile{}",
            "After 3 hands, this card will",
            "be {C:mult}destroyed{}",
            "{C:inactive}({C:mult}#1#{C:inactive} uses left)"
        }
    },
    atlas = "Stickers",
    pos = {x = 1, y = 0},
    config = {}, -- No need for extra here
    loc_vars = function(self, info_queue, card)
        return { vars = { card.void_anchor_uses or 3 } }
    end,
    default_compat = true,
    calculate = function(self, card, context)
        -- Initialize counters if not present
        if card.void_anchor_uses == nil then card.void_anchor_uses = 3 end
        if card.void_anchor_hands == nil then card.void_anchor_hands = 3 end

        if context.after then
            for i, handCard in ipairs(G.hand.cards) do
                if handCard == card then
                    if card.void_anchor_uses > 0 then
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
                        card.void_anchor_uses = card.void_anchor_uses - 1
                    end

                    -- Handle countdown and destruction of the card
                    card.void_anchor_hands = card.void_anchor_hands - 1
                    if card.void_anchor_hands <= 0 then
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
            "Charge with 5 {C:purple}Void{} cards",
            "When charged, a random card gains a",
            "{C:purple}Void Anchor{}. Adjacent cards to it become",
            "{C:purple}Volatile{}. After 3 hands,",
            "the anchored card will be destroyed",
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
            hands_remaining = 3,
            starvation_applied = false
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
                   scoringCard.config.center == G.P_CENTERS.m_fm_volatile or
                   scoringCard.config.center == G.P_CENTERS.m_fm_suppress then
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
                        target_card.void_anchor_uses = 3
                        target_card.void_anchor_hands = 3
                        -- target_card.void_anchored = nil
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
            "Charge with 5 {C:spades}Stasis{} cards",
            "When charged, {C:attention}#1#{} will {C:spades}Slow{}",
            "all played cards and {C:spades}Freeze{} all played {C:spades}Slow{} cards",
            "{C:attention}#2#{} will {C:spades}Shatter{} all played {C:spades}Freeze{} cards",
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
            
            local freeze_idx = pseudorandom("test", 1, #hand_pool)
            local freeze_hand = hand_pool[freeze_idx]
            table.remove(hand_pool, freeze_idx)
            
            local shatter_idx = pseudorandom("test", 1, #hand_pool)
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
                        
                        -- Process existing Slow cards to Freeze first
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
            "Charge with 5 {C:spades}Stasis{} cards",
            "Places 3 {C:spades}Stasis Crystals{}",
            "in your hand. They gain {C:mult}+5{} Mult",
            "per {C:spades}Freeze{} card played before",
            "destroying themselves in 3 hands",
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
            "Charge with 5 {C:green}Strand{} cards",
            "When charged, grants {C:green}Unravel{}",
            "to 5 random cards in hand",
            "Each card starts with Threads",
            "equal to its rank",
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
                   scoringCard.config.center == G.P_CENTERS.m_fm_unravel or
                   scoringCard.config.center == G.P_CENTERS.m_fm_suspend then
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
                local card_idx = pseudorandom("test", 1, #normal_cards)
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
                        target_card.ability.extra.threads_per_hand = 1
                        for _, joker in ipairs(G.jokers.cards) do
                            if joker.config.center_key == "j_fm_thread_of_evolution" then
                                target_card.ability.extra.threads_per_hand = 2
                                for i = #G.deck.cards, 1, -1 do
                                    if G.deck.cards[i].config.center == G.P_CENTERS.m_fm_unravel then
                                        G.deck.cards[i].ability.extra.threads_per_hand = 2
                                    end
                                end
                                break
                            end
                        end
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
            "Charge with 5 {C:green}Strand{} cards",
            "When charged, playing a {C:attention}Pair{}",
            "or a {C:attention}High Card{} will",
            "slice them into equivalent pairs,",
            "cloning them but with halved ranks",
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
                       scoringCard.config.center == G.P_CENTERS.m_fm_wovenmail or
                       scoringCard.config.center == G.P_CENTERS.m_fm_suspend then
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

            if card.ability.extra.state == "ready" and (context.scoring_name == "Pair" or context.scoring_name == "High Card") then
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
            "gains {C:mult}+#2#{} Mult",
            "Disappears after the round ends",
            "{C:inactive}(Currently: {C:mult}+#1#{C:inactive} Mult)"
        }
    },
    default_compat = true,
    sets = { Joker = false },
    atlas = "Stickers",
    pos = {x = 2, y = 0},
    config = {}, -- No shared state!
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.catatonic_accumulated_mult or 10,
                card.catatonic_mult_increment or 10
            }
        }
    end,
    calculate = function(self, card, context)
        -- Initialize per-card values if not present
        if card.catatonic_accumulated_mult == nil then card.catatonic_accumulated_mult = 10 end
        if card.catatonic_mult_increment == nil then card.catatonic_mult_increment = 10 end

        -- Check for Splinter of Corruption Joker
        local increment = 10
        for _, joker in ipairs(G.jokers.cards) do
            if joker.config.center_key == "j_fm_splinter_of_corruption" then
                increment = 20
                break
            end
        end
        card.catatonic_mult_increment = increment

        if card.area == G.hand and context.after then
            card.catatonic_accumulated_mult = card.catatonic_accumulated_mult + card.catatonic_mult_increment
            return {
                message = "Mult Up!",
                colour = G.C.MULT
            }
        end
        if card.area == G.hand and context.main_scoring then
            return {
                mult = card.catatonic_accumulated_mult
            }
        end
        if context.end_of_round then
            card:flip()
            SMODS.Stickers.fm_catatonic:apply(card, false)
            card:flip()
            card.catatonic_accumulated_mult = nil
            card.catatonic_mult_increment = nil
        end
    end
}

SMODS.Joker{
    key = "witnesss_shatter",
    loc_txt = {
        name = "Witness's Shatter",
        text = {
            "Charge with 5 {C:black}Resonance{} cards",
            "When charged, {C:attention}#1#{} random cards",
            "become {C:black}Catatonic{}, making them {C:mult}unplayable{}",
            "and {C:mult}undiscardable{}, but grants incremental {C:red}Mult{}",
            "per hand played",
            "until the round ends",
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
            card.ability.extra.catatonic_count = pseudorandom("catatonic", 1, 3)
        end
        
        if context.joker_main then
            local resonance_count = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_resonant or
                   scoringCard.config.center == G.P_CENTERS.m_fm_dissected or
                   scoringCard.config.center == G.P_CENTERS.m_fm_finalized or
                   scoringCard.config.center == G.P_CENTERS.m_fm_rooted then
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
                    local card_idx = pseudorandom("test", 1, #available_cards)
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
            "Charge with 5 Resonance cards",
            "When charged, all cards except those of",
            "suit {C:attention}#1#{} are subjected to random",
            "rank changes. Surviving cards gain",
            "{C:black}Resonance{} enhancements",
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
                   scoringCard.config.center == G.P_CENTERS.m_fm_finalized or
                   scoringCard.config.center == G.P_CENTERS.m_fm_rooted then
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
                    G.P_CENTERS.m_fm_finalized,
                    G.P_CENTERS.m_fm_rooted
                }
                
                local enhancement = pseudorandom_element(enhancements, pseudoseed('enhancements'))
                
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
                local rank_change = pseudorandom("test", -3, 3)
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
            "Charge with 5 {X:dark_edition,C:white}Prismatic{} cards",
            "When charged, the next scoring hand will",
            "convert all {C:attention}Light{} cards to {C:darkgray}Dark{} cards and",
            "all {C:darkgray}Dark{} cards to {C:attention}Light{} cards,",
            "then score again with the converted cards",
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
                    G.P_CENTERS.m_fm_cure,
                    G.P_CENTERS.m_fm_amplified,
                    G.P_CENTERS.m_fm_bolt_charge,
                    G.P_CENTERS.m_fm_jolt,
                    G.P_CENTERS.m_fm_blinded,
                    G.P_CENTERS.m_fm_devour,
                    G.P_CENTERS.m_fm_volatile,
                    G.P_CENTERS.m_fm_overshield,
                    G.P_CENTERS.m_fm_suppress
                }
                
                local dark_centers = {
                    G.P_CENTERS.m_fm_stasis_crystal,
                    G.P_CENTERS.m_fm_slow,
                    G.P_CENTERS.m_fm_freeze,
                    G.P_CENTERS.m_fm_shatter,
                    G.P_CENTERS.m_fm_tangle,
                    G.P_CENTERS.m_fm_suspend,
                    G.P_CENTERS.m_fm_wovenmail,
                    G.P_CENTERS.m_fm_unravel,
                    G.P_CENTERS.m_fm_resonant,
                    G.P_CENTERS.m_fm_dissected,
                    G.P_CENTERS.m_fm_finalized,
                    G.P_CENTERS.m_fm_rooted
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
                            new_center = pseudorandom_element(dark_centers, pseudoseed('enhancements'))
                            
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
                            new_center = pseudorandom_element(light_centers, pseudoseed('enhancements'))
                            
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
                    G.P_CENTERS.m_fm_volatile,
                    G.P_CENTERS.m_fm_suppress
                },
                ["Solar"] = {
                    G.P_CENTERS.m_fm_radiant,
                    G.P_CENTERS.m_fm_cure,
                    G.P_CENTERS.m_fm_restoration,
                    G.P_CENTERS.m_fm_scorch
                },
                ["Arc"] = {
                    G.P_CENTERS.m_fm_jolt,
                    G.P_CENTERS.m_fm_amplified,
                    G.P_CENTERS.m_fm_blinded,
                    G.P_CENTERS.m_fm_bolt_charge
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
                    G.P_CENTERS.m_fm_unravel,
                    G.P_CENTERS.m_fm_suspend
                },
                ["Resonance"] = {
                    G.P_CENTERS.m_fm_resonant,
                    G.P_CENTERS.m_fm_dissected,
                    G.P_CENTERS.m_fm_finalized,
                    G.P_CENTERS.m_fm_rooted
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
                    local target_card = pseudorandom_element(eligible_cards, pseudoseed('enhancements'))
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

-- FRAGMENT JOKERS

SMODS.Joker{
    key = "echo_of_expulsion",
    loc_txt = {
        name = "Echo of Expulsion",
        text = {
            "If the played hand contains the same {C:purple}Void{} enhancements,",
            " grant {X:mult,C:white}X1.5{} Mult and {X:blue,C:white}X1.5{} Chips but discard a random card"
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
    pos = {x=0, y=3},
    config = { 
        extra = { 
            des = false,
            over = 0,
            devo = 0,
            vola = 0,
            supp = 0
        } 
    },
    calculate = function(self, card, context)
        if context.joker_main then
            for _, scored_card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scored_card, "m_fm_overshield") then
                    card.ability.extra.over = card.ability.extra.over + 1
                elseif SMODS.has_enhancement(scored_card, "m_fm_devour") then
                    card.ability.extra.devo = card.ability.extra.devo + 1
                elseif SMODS.has_enhancement(scored_card, "m_fm_volatile") then
                    card.ability.extra.vola = card.ability.extra.vola + 1
                elseif SMODS.has_enhancement(scored_card, "m_fm_suppress") then
                    card.ability.extra.supp = card.ability.extra.supp + 1
                end
            end
            if card.ability.extra.over == #context.scoring_hand or 
                card.ability.extra.devo == #context.scoring_hand or 
                card.ability.extra.vola == #context.scoring_hand or
                card.ability.extra.supp == #context.scoring_hand then
                    card.ability.extra.des = true
            end
            card.ability.extra.over = 0
            card.ability.extra.devo = 0
            card.ability.extra.vola = 0
            card.ability.extra.supp = 0
            if card.ability.extra.des == true then
                card.ability.extra.des = false
                local any_selected = nil
                local _cards = {}
                for _, playing_card in ipairs(G.hand.cards) do
                    _cards[#_cards + 1] = playing_card
                end
                for i = 1, 1 do
                    if G.hand.cards[i] then
                        local selected_card, card_index = pseudorandom_element(_cards, pseudoseed('Balalalala'))
                        G.hand:add_to_highlighted(selected_card, true)
                        table.remove(_cards, card_index)
                        any_selected = true
                    end
                end
                if any_selected then G.FUNCS.discard_cards_from_highlighted(nil, true) end
                return {
                    xchips  = 1.5,
                    xmult = 1.5
                 }
            end
        end
    end
}

SMODS.Joker{
    key = "echo_of_vigilance",
    loc_txt = {
        name = "Echo of Vigilance",
        text = {
            "Once per blind, if the last hand of a blind wins,", -- Part A works
            "grant all scored cards {C:purple}Overshield{}",
            "Discarding 3 or more {C:purple}Overshield{} cards", -- Part B adds a hand per each Overshielded card discarded as long as 3 or more cards are discarded
            "will grant you {C:blue}+1{} hand" -- Triggers as many times as you meet the requirements
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
    pos = {x=1, y=3},
    config = {
        {
            flag = true
        }
    },
    calculate = function(self, card, context)
        local flag = true
        local count = 0
        if context.discard then
            for i, discardedCard in ipairs(G.hand.highlighted) do
                if SMODS.has_enhancement(discardedCard, "m_fm_overshield") then
                    count = count + 1
                end
            end
        end
        if context.post_joker then
            if flag == true then
                if  count >= 3 then
                    G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + 1
                    count = 0
                    flag = false
                end
            end
            if G.GAME.current_round.hands_left == 0 then
                for i, scoringCard in ipairs(context.scoring_hand) do
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0.5,
                        func = function()
                            scoringCard:flip()
                            scoringCard:juice_up()
                            scoringCard:set_ability(G.P_CENTERS.m_fm_overshield)
                            scoringCard:flip()
                            return true
                        end
                    }))
                end
            end
        end
        if context.end_of_round then
            flag = true
        end
    end
}

SMODS.Joker{
    key = "echo_of_persistence",
    loc_txt = {
        name = "Echo of Persistence",
        text = {
            "When at least one {C:purple}Void{} enhancement is included in a discard,", -- Wanted it to just be "When a Void card is discarded", but i couldn't make it work
            "all cards discarded with it return back to your hand", 
            "{C:red}-1{} discard",
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
    pos = {x=2, y=3},
    calculate = function(self, card, context)
        if context.setting_blind then
            G.GAME.current_round.discards_left = G.GAME.current_round.discards_left - 1 
        end
        if context.discard then
            local buffed = false
            G.E_MANAGER:add_event(Event({
                trigger = "immediate",
                func = function()
                    for i, discardedCard in ipairs(G.hand.highlighted) do
                        if SMODS.has_enhancement(discardedCard, "m_fm_overshield") or 
                        SMODS.has_enhancement(discardedCard, "m_fm_devour") or 
                        SMODS.has_enhancement(discardedCard, "m_fm_volatile") or
                        SMODS.has_enhancement(discardedCard, "m_fm_suppress") then
                            buffed = true
                        end
                    end
                    if buffed then
                        for i, discardedCard in ipairs(G.hand.highlighted) do
                            draw_card(G.discard, G.hand, 90, 'up', false, discardedCard)
                            discardedCard:flip()
                            return true
                        end
                    end
                end
            }))
        end
    end
}

SMODS.Joker{
    key = "echo_of_reprisal",
    loc_txt = {
        name = "Echo of Reprisal",
        text = {
            "Grants extra {C:attention}charges{} to",
            "{C:purple}Void Super{} cards",
            "for every card scored with the {C:attention}same suit{}",
            "with a scoring {C:purple}Void{} card"
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
    pos = {x=3, y=3},
    calculate = function(self, card, context)
        if context.joker_main then
            local void_suits = {}
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_overshield or
                   scoringCard.config.center == G.P_CENTERS.m_fm_devour or
                   scoringCard.config.center == G.P_CENTERS.m_fm_volatile or
                   scoringCard.config.center == G.P_CENTERS.m_fm_suppress then
                    void_suits[scoringCard.base.suit] = true
                end
            end

            local extra_charges = 0
            for suit, _ in pairs(void_suits) do
                for _, scoreCard in ipairs(context.scoring_hand) do
                    if scoreCard.base.suit == suit then
                        extra_charges = extra_charges + 1
                    end
                end
            end

            for _, joker in ipairs(G.jokers.cards) do
                if joker.config.center_key == "j_fm_ward_of_dawn" or joker.config.center_key == "j_fm_shadowshot" then
                    if extra_charges > 0 then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local prev_charge = joker.ability.extra.charge or 0
                                joker.ability.extra.charge = math.min(5, (joker.ability.extra.charge or 0) + extra_charges)
                                if prev_charge < 5 and joker.ability.extra.charge >= 5 then
                                    joker.ability.extra.state = "ready"
                                    juice_card_until(joker, function() return joker.ability.extra.state == "ready" end, true)
                                    SMODS.calculate_effect({
                                        message = "Ready!",
                                        sound = "fm_super_ready",
                                        colour = G.C.PURPLE
                                    }, joker)
                                else
                                    SMODS.calculate_effect({
                                        message = "+" .. extra_charges .. " Charge",
                                        colour = G.C.PURPLE,
                                        sound = "fm_super_charge"
                                    }, joker)
                                end
                                return true
                            end
                        }))
                    end
                end
            end
        end
    end
}

SMODS.Joker{
    key = "echo_of_instability",
    loc_txt = {
        name = "Echo of Instability",
        text = {
            "If your hand contains a {C:attention}#1#{}, grant",
            "the first card that was scored {C:purple}Volatile{}",
            "{C:inactive}(Changes each hand){}",
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
    pos = {x=4, y=3},
    config = {
        extra = {
            required_hand = nil
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.required_hand or "None" } }
    end,
    calculate = function(self, card, context)
        if context.after then
            local hands = {}
            for k, v in pairs(G.GAME.hands) do
                if v.visible then  
                    hands[#hands + 1] = k
                end
            end
            if #hands > 0 then
                card.ability.extra.required_hand = pseudorandom_element(hands, pseudoseed("PERFECT HATRED"))
            end
        end

        if context.joker_main and card.ability.extra.required_hand then
            if context.scoring_name == card.ability.extra.required_hand then
                for _, scoringCard in ipairs(context.scoring_hand) do
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0.5,
                        func = function()
                            scoringCard:flip()
                            scoringCard:juice_up()
                            scoringCard:set_ability(G.P_CENTERS.m_fm_volatile)
                            scoringCard:flip()
                            return true
                        end
                    }))
                    break
                end
            end
        end
    end
}

SMODS.Joker{
    key = "echo_of_starvation",
    loc_txt = {
        name = "Echo of Starvation",
        text = {
            "Whenever a {C:purple}Void Super{} Joker is fully charged,",
            "grant {C:purple}Devour{} to a random unenhanced card in hand"
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
    pos = {x=5, y=3},
    calculate = function(self, card, context)
        if context.joker_main then
            for _, joker in ipairs(G.jokers.cards) do
                if joker.config.center_key == "j_fm_ward_of_dawn" or joker.config.center_key == "j_fm_shadowshot" then
                    if joker.ability.extra.state == "ready" and not joker.ability.extra.starvation_applied then
                        joker.ability.extra.starvation_applied = true

                        local unenhanced = {}
                        for _, handCard in ipairs(G.hand.cards) do
                            if handCard.ability.set ~= "Enhanced" then
                                table.insert(unenhanced, handCard)
                            end
                        end

                        if #unenhanced > 0 then
                            local target = pseudorandom_element(unenhanced, pseudoseed('enhancements'))
                            SMODS.calculate_effect({
                                message = "Devoured!",
                                sound = "fm_void_fragment",
                                colour = G.C.PURPLE
                            }, target)
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    target:flip()
                                    target:set_ability(G.P_CENTERS.m_fm_devour)
                                    target:flip()
                                    return true
                                end
                            }))
                        end
                    elseif joker.ability.extra.state ~= "ready" then
                        joker.ability.extra.starvation_applied = false
                    end
                end
            end
        end

        if context.after then
            for _, joker in ipairs(G.jokers.cards) do
                if (joker.config.center_key == "j_fm_ward_of_dawn" or joker.config.center_key == "j_fm_shadowshot")
                    and joker.ability.extra.state == "ready"
                    and not joker.ability.extra.starvation_applied then

                    joker.ability.extra.starvation_applied = true

                    local unenhanced = {}
                    for _, handCard in ipairs(G.hand.cards) do
                        if handCard.ability.set ~= "Enhanced" then
                            table.insert(unenhanced, handCard)
                        end
                    end

                    if #unenhanced > 0 then
                        local target = pseudorandom_element(unenhanced, pseudoseed('enhancements'))
                        SMODS.calculate_effect({
                            message = "Devoured!",
                            sound = "fm_void_fragment",
                            colour = G.C.PURPLE
                        }, target)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                target:flip()
                                target:set_ability(G.P_CENTERS.m_fm_devour)
                                target:flip()
                                return true
                            end
                        }))
                    end
                end
            end
        end
    end
}

SMODS.Joker{
    key = "ember_of_wonder",
    loc_txt = {
        name = "Ember of Wonder",
        text = {
            "{c:attention}Igniting{} 2 {C:attention}Scorch{} cards in one hand",
            "will instantly charge one of your {C:attention}Solar Super{} cards",
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
    pos = {x=0, y=4},
    calculate = function(self, card, context)
        if context.joker_main then
            -- Count ignited Scorch cards in the scoring hand
            local ignited_scorch = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_scorch and
                scoringCard.ability.extra.stacks and scoringCard.ability.extra.stacks >= 3 then
                    ignited_scorch = ignited_scorch + 1
                end
            end

            if ignited_scorch >= 2 then
                -- Find all Solar Super Jokers in hand
                local solar_supers = {}
                for _, joker in ipairs(G.jokers.cards) do
                    if joker.config.center_key == "j_fm_well_of_radiance" or joker.config.center_key == "j_fm_golden_gun" then
                        table.insert(solar_supers, joker)
                    end
                end

                if #solar_supers > 0 then
                    local target_joker = pseudorandom_element(solar_supers, pseudoseed('solar supers'))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target_joker.ability.extra.charge = 5
                            target_joker.ability.extra.state = "ready"
                            juice_card_until(target_joker, function() return target_joker.ability.extra.state == "ready" end, true)
                            SMODS.calculate_effect({
                                message = "Instant Charge!",
                                sound = "fm_super_charge",
                                colour = G.C.ORANGE
                            }, target_joker)
                            return true
                        end
                    }))
                end
            end
        end
    end
}

SMODS.Joker{
    key = "ember_of_tempering",
    loc_txt = {
        name = "Ember of Tempering",
        text = {
            "If a {C:attention}Solar{} enhanced card is scored, grant the", -- I wanted it to be "Every other scored Solar card grants the leftmost unenhanced...", but it broke somewhere despite not touching it...
            "leftmost card in hand a random {C:attention}Solar{} enhancement",
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
    pos = {x=1, y=4},
    calculate = function(self, card, context)
        local count = 0
        local loop = 0
        local enhancements = {
            G.P_CENTERS.m_fm_radiant,
            G.P_CENTERS.m_fm_scorch,
            G.P_CENTERS.m_fm_restoration,
            G.P_CENTERS.m_fm_cure
        }
        if context.after then
            for i, Card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(Card, "m_fm_radiant") or SMODS.has_enhancement(Card, "m_fm_restoration") or SMODS.has_enhancement(Card, "m_fm_scorch") or SMODS.has_enhancement(Card, "m_fm_cure") then
                    count = count + 1
                end
            end
            count = math.ceil(count/2)
            if count > 0 then
                for i, Card in ipairs(G.hand.cards) do
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0.5,
                        func = function()
                            Card:flip()
                            Card:juice_up()
                            Card:set_ability(pseudorandom_element(enhancements, pseudoseed('balatrue...')))
                            Card:flip()
                            return true
                        end
                    }))
                    loop = loop + 1
                    if loop >= count then
                        count = 0
                        loop = 0
                        break
                    end
                    return {
                        message = "Enhanced!",
                        card = Card,
                    }
                end
            end
        end
    end
}

SMODS.Joker{
    key = "ember_of_char",
    loc_txt = {
        name = "Ember of Char",
        text = {
            "When a card {C:attention}Ignites{}, grant all {C:attention}Scorch{}", -- Works now, at first i wanted it for every card ignited but this feels more balanced
            "cards scored an additional {C:attention}Scorch{} stack",
            "(once per hand)"
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
    pos = {x=2, y=4},
    calculate = function(self, card, context)
        if context.joker_main then
            local ignis = false
            for i, scoredCard in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scoredCard, "m_fm_scorch") then
                    if scoredCard.ability.extra.stacks >= 3 then
                        ignis = true
                    end
                end
            end
            if ignis == true then
                ignis = false
                for i, scoredCard in ipairs(context.scoring_hand) do
                    if SMODS.has_enhancement(scoredCard, "m_fm_scorch") then
                        if scoredCard.ability.extra.stacks < 3 then
                            scoredCard.ability.extra.stacks = scoredCard.ability.extra.stacks + 1

                        end
                    end
                end
                return {
                    message = "BURN!",
                    sound = "fm_solar_fragment",
                }
            end
        end
    end
}

SMODS.Joker{
    key = "ember_of_mercy",
    loc_txt = {
        name = "Ember of Mercy",
        text = {
            "Every unenhanced card that is retriggered", -- IT WORKS, FUCK YEA
            "is sent back to the hand with {C:attention}Restoration{}",
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
    pos = {x=3, y=4},
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.end_of_round then
            context.other_card.count = (context.other_card.count or 0) + 1
        end
        if context.joker_main then
            for i, Card in ipairs(context.scoring_hand) do
                if Card.count >= 2 then
                    Card.count = 0
                    if Card.ability.set ~= "Enhanced" then
                        G.E_MANAGER:add_event(Event({
                            trigger = "immediate",
                            func = function()
                                draw_card(G.discard, G.hand, 90, 'up', false, Card)
                                Card:set_ability(G.P_CENTERS.m_fm_restoration)
                                Card:flip()
                                return true
                            end
                        }))
                    end
                end
            end
        end
    end
}

SMODS.Joker{
    key = "ember_of_torches",
    loc_txt = {
        name = "Ember of Torches",
        text = {
            "Scored {C:attention{}Restoration{} cards", 
            "become {C:attention}Radiant{} and gain a rank", -- Works! Very simple but I like it
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
    pos = {x=4, y=4},
    calculate = function(self, card, context)
        if context.post_joker then
            for i, Card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(Card, "m_fm_restoration") then
                    local current_rank = Card.base.value
                    local next_rank = nil
                    local found_current = false
                    for _, rank_key in ipairs(SMODS.Rank.obj_buffer) do
                        if found_current then
                            next_rank = rank_key
                            break
                        end
                        if rank_key == current_rank then
                            found_current = true
                        end
                    end
                    G.E_MANAGER:add_event(Event({
                        trigger = "immediate",
                        func = function()
                            Card:flip()
                            Card:set_ability(G.P_CENTERS.m_fm_radiant)
                            if Card.base.value ~= "Ace" then
                                SMODS.change_base(Card, Card.base.suit, next_rank)
                            end
                            Card:flip()
                            return true
                        end
                    }))
                    return {
                        message = "Radiant!",
                        sound = "fm_solar_fragment",
                    }
                end
            end
        end
    end
}

SMODS.Joker{
    key = "ember_of_solace",
    loc_txt = {
        name = "Ember of Solace",
        text = {
            "Retrigger all scored cards once if a", -- Couldn't make it retrigger only Restoration and Radiant cards, so I just ran with this
            "a scored card has {C:attention}Restoration{} or {C:attention}Radiant{}",
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
    pos = {x=5, y=4},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition and not context.repetition_only then
            local retry = false
            for i, scoredCard in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scoredCard, "m_fm_radiant") or SMODS.has_enhancement(scoredCard, "m_fm_restoration") then
                    retry = true
                end
            end
            if retry == true then
                for i, scoredCard in ipairs(context.scoring_hand) do
                    return {
                        message = "Again!",
                        sound = "fm_solar_fragment",
                        repetitions = 1,
                    }
                end
                retry = false
            end
        end
    end
}

SMODS.Joker{
    key = "spark_of_brilliance",
    loc_txt = {
        name = "Spark of Brilliance",
        text = {
            "Scored {C:blue}Blinded{} cards {C:blue}blind{} all", 
            "unenhanced cards scored next to them" -- Works!! Remember to fix the blinded cards not being flipped when drawn!
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
    pos = {x=0, y=5},
    calculate = function(self, card, context)
        if context.joker_main then
            for i, Card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(Card, "m_fm_blinded") then
                    if context.scoring_hand[i-1] then
                        if context.scoring_hand[i-1].ability.set ~= "Enhanced" then
                            G.E_MANAGER:add_event(Event({
                                trigger = "immediate",
                                func = function()
                                    context.scoring_hand[i-1]:flip()
                                    context.scoring_hand[i-1]:set_ability(G.P_CENTERS.m_fm_blinded)
                                    context.scoring_hand[i-1]:flip()
                                    return true
                                end
                            }))
                        end
                    end
                    if context.scoring_hand[i+1] then
                        if context.scoring_hand[i+1].ability.set ~= "Enhanced" then
                            G.E_MANAGER:add_event(Event({
                                trigger = "immediate",
                                func = function()
                                    context.scoring_hand[i+1]:flip()
                                    context.scoring_hand[i+1]:set_ability(G.P_CENTERS.m_fm_blinded)
                                    context.scoring_hand[i+1]:flip()
                                    return true
                                end
                            }))
                        end
                    end
                end
            end
        end
    end
}

SMODS.Joker{
    key = "spark_of_instinct",
    loc_txt = {
        name = "Spark of Instinct",
        text = {
            "When you have 2 hands or less remaining", -- Works!!
            "{C:blue}Jolt{} all unenhanced cards scored",
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
    pos = {x=1, y=5},
    calculate = function(self, card, context)
        if context.before then
            if G.GAME.current_round.hands_left < 2 then
                for i, scoredCard in ipairs(context.scoring_hand) do
                    if scoredCard.ability.set ~= "Enhanced" then
                        scoredCard:flip()
                        scoredCard:set_ability(G.P_CENTERS.m_fm_jolt)
                        scoredCard:flip()
                    end
                end
                return {
                    message = "Shocking!",
                    sound = "fm_arc_fragment",
                }
            end
        end
    end
}

SMODS.Joker{
    key = "spark_of_amplitude",
    loc_txt = {
        name = "Spark of Amplitude",
        text = {
            "Priming 3 or more {C:blue}Amplified{} cards in one hand",
            "will grant extra charges depending on the", 
            "number of {C:blue}Amplified{} cards primed",
            "to one random {C:blue}Arc Super{} card in hand",
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
    pos = {x=2, y=5},
    calculate = function(self, card, context)
        if context.after then
            -- Count primed Amplified cards in the hand
            local primed_amplified = 0
            for _, handCard in ipairs(G.hand.cards) do
                if handCard.config.center == G.P_CENTERS.m_fm_amplified and
                handCard.ability.extra.hands_seen >= 1 then
                    primed_amplified = primed_amplified + 1
                end
            end

            if primed_amplified >= 3 then
                -- Find all Arc Super Jokers in hand
                local arc_supers = {}
                for _, joker in ipairs(G.jokers.cards) do
                    if joker.config.center_key == "j_fm_thundercrash" or joker.config.center_key == "j_fm_gathering_storm" then
                        table.insert(arc_supers, joker)
                    end
                end

                if #arc_supers > 0 then
                    local target_joker = pseudorandom_element(arc_supers, pseudoseed('arc supers'))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target_joker.ability.extra.charge = math.min(5, (target_joker.ability.extra.charge or 0) + primed_amplified)
                            SMODS.calculate_effect({
                                message = "+" .. primed_amplified .. " Charge!",
                                sound = "fm_super_charge",
                                colour = G.C.BLUE
                            }, target_joker)
                            if target_joker.ability.extra.charge >= 5 then
                                target_joker.ability.extra.state = "ready"
                                juice_card_until(target_joker, function() return target_joker.ability.extra.state == "ready" end, true)
                            end
                            return true
                        end
                    }))
                end
            end
        end
    end
}

SMODS.Joker{
    key = "spark_of_beacons",
    loc_txt = {
        name = "Spark of Beacons",
        text = {
            "Scored {C:blue}Amplified{} cards {C:blue}Amplifies{}",
            "and primes an unenhanced card in hand"
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
    pos = {x=3, y=5},
    calculate = function(self, card, context)
        if context.after then
            for _, scoredCard in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scoredCard, "m_fm_amplified") then
                    local unenhancedCards = {}
                    for _, handCard in ipairs(G.hand.cards) do
                        if handCard.ability.set ~= "Enhanced" then
                            table.insert(unenhancedCards, handCard)
                        end
                    end
                    if #unenhancedCards > 0 then
                        local selected_card = pseudorandom_element(unenhancedCards, pseudoseed('Balalalala'))
                        selected_card:flip()
                        selected_card:set_ability(G.P_CENTERS.m_fm_amplified)
                        selected_card:flip()
                    end
                end
            end
        end
    end
}

SMODS.Joker{
    key = "spark_of_resistance",
    loc_txt = {
        name = "Spark of Resistance",
        text = {
            "Gain {C:blue}+1{} hand", -- The hardest one to date, but I got it working
            "Gain another hand if you have",
            "more than 20 {C:blue}Arc{} cards in your deck"
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
    pos = {x=4, y=5},
    calculate = function(self, card, context)
        if context.setting_blind then
            G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + 1

            local arc_count = 0
            for i = #G.deck.cards, 1, -1 do
                if G.deck.cards[i].config.center == G.P_CENTERS.m_fm_amplified or
                   G.deck.cards[i].config.center == G.P_CENTERS.m_fm_jolt or
                   G.deck.cards[i].config.center == G.P_CENTERS.m_fm_blinded or
                   G.deck.cards[i].config.center == G.P_CENTERS.m_fm_bolt_charge then
                    arc_count = arc_count + 1
                end
            end

            if arc_count > 20 then
                G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + 1
            end
        end
    end
}

SMODS.Joker{
    key = "spark_of_feedback",
    loc_txt = {
        name = "Spark of Feedback",
        text = {
            "Gain {X:blue,C:white}X2{} Chips if you",
            "scored less than your previous hand",
            "{C:inactive}(Last score: {C:attention}#1#{C:inactive})"
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
    pos = {x=5, y=5},
    config = { 
        extra = { 
            lastHand = 0
        } 
    },
    loc_vars = function(self, info_queue, card)
        return { 
            vars = { 
                card.ability.extra.lastHand
            } 
        }
    end,
    calculate = function(self, card, context)
        if context.final_scoring_step then
            if hand_chips*mult < card.ability.extra.lastHand then
                return {
                    xchips = 2,
                }
            end
        end
        if context.final_scoring_step then
            card.ability.extra.lastHand = hand_chips*mult
        end
        if context.end_of_round then
            card.ability.extra.lastHand = 0
        end
    end
}

SMODS.Joker{
    key = "whisper_of_bonds",
    loc_txt = {
        name = "Whisper of Bonds",
        text = {
            "Once per blind, scoring a {C:spades}Freeze{} card",
            "will grant super energy charges to a random {C:spades}Stasis Super{} card",
            "depending on the number of {C:spades}Shatter{} cards remaining in hand",
            "{C:inactive}(Used this blind: {C:attention}#1#{C:inactive})"
            -- Works
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
    pos = {x=0, y=6},
    config = {
        extra = {
            used_this_blind = false
        }
    },
    loc_vars = function(self, info_queue, card)
        local status = card.ability.extra.used_this_blind and "Used" or "Unused"
        return { vars = { status } }
    end,
    calculate = function(self, card, context)
        -- Reset flag at the start of each blind
        if context.setting_blind then
            card.ability.extra.used_this_blind = false
        end

        if context.joker_main and not card.ability.extra.used_this_blind then
            -- Check if a Freeze card was scored
            local freeze_scored = false
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_freeze then
                    freeze_scored = true
                    break
                end
            end

            if freeze_scored then
                -- Count Shatter cards in hand
                local shatter_count = 0
                for _, handCard in ipairs(G.hand.cards) do
                    if handCard.config.center == G.P_CENTERS.m_fm_shatter then
                        shatter_count = shatter_count + 1
                    end
                end

                if shatter_count > 0 then
                    -- Find all Stasis Super Jokers in hand
                    local stasis_supers = {}
                    for _, joker in ipairs(G.jokers.cards) do
                        if joker.config.center_key == "j_fm_winters_wrath" or joker.config.center_key == "j_fm_glacial_quake" then
                            table.insert(stasis_supers, joker)
                        end
                    end

                    if #stasis_supers > 0 then
                        local target_joker = pseudorandom_element(stasis_supers, pseudoseed('stasis supers'))
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                target_joker.ability.extra.charge = math.min(5, (target_joker.ability.extra.charge or 0) + shatter_count)
                                SMODS.calculate_effect({
                                    message = "+" .. shatter_count .. " Charge!",
                                    sound = "fm_super_charge",
                                    colour = G.C.SUITS.Spades
                                }, target_joker)
                                if target_joker.ability.extra.charge >= 5 then
                                    target_joker.ability.extra.state = "ready"
                                    juice_card_until(target_joker, function() return target_joker.ability.extra.state == "ready" end, true)
                                end
                                return true
                            end
                        }))
                    end
                end

                card.ability.extra.used_this_blind = true
            end
        end
    end
}

SMODS.Joker{
    key = "whisper_of_rending",
    loc_txt = {
        name = "Whisper of Rending",
        text = {
            "{C:spades}Freeze{} cards gain an extra return",
            "Grants {C:mult}+10{} Mult and {C:blue}+50{} Chips",
            "after using a {C:spades}Freeze{} card's extra return",
            -- Works
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
    pos = {x=1, y=6},
    add_to_deck = function(self, card, from_debuff)
        for _, handCard in ipairs(G.hand.cards) do
            if handCard.config.center == G.P_CENTERS.m_fm_freeze then
                if not handCard.ability.extra.max_returns or handCard.ability.extra.max_returns < 3 then
                    handCard.ability.extra.max_returns = 3
                end
            end
        end
        for i = #G.deck.cards, 1, -1 do
            if G.deck.cards[i].config.center == G.P_CENTERS.m_fm_freeze then
                if not G.deck.cards[i].ability.extra.max_returns or G.deck.cards[i].ability.extra.max_returns < 3 then
                    G.deck.cards[i].ability.extra.max_returns = 3
                end
            end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        for _, handCard in ipairs(G.hand.cards) do
            if handCard.config.center == G.P_CENTERS.m_fm_freeze then
                if not handCard.ability.extra.max_returns or handCard.ability.extra.max_returns > 2 then
                    handCard.ability.extra.max_returns = 2
                end
            end
        end
        for i = #G.deck.cards, 1, -1 do
            if G.deck.cards[i].config.center == G.P_CENTERS.m_fm_freeze then
                if not G.deck.cards[i].ability.extra.max_returns or G.deck.cards[i].ability.extra.max_returns > 2 then
                    G.deck.cards[i].ability.extra.max_returns = 2
                end
            end
        end
    end,
    calculate = function(self, card, context)
    -- Find a way to reset 3 returns back to 2 if the fragment is not active
    -- Always ensure all Freeze cards have at least 3 returns while this Joker is active
        -- for _, handCard in ipairs(G.hand.cards) do
        --     if handCard.config.center == G.P_CENTERS.m_fm_freeze then
        --         if not handCard.ability.extra.max_returns or handCard.ability.extra.max_returns < 3 then
        --             handCard.ability.extra.max_returns = 3
        --         end
        --     end
        -- end

        -- Grant bonus when a Freeze card uses its extra return
        if context.before then
            local bonus_mult = 0
            local bonus_chips = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_freeze and
                scoringCard.ability.extra.max_returns and scoringCard.ability.extra.max_returns > 2 and
                scoringCard.ability.extra.times_returned == scoringCard.ability.extra.max_returns then
                    bonus_mult = bonus_mult + 10
                    bonus_chips = bonus_chips + 50
                end
            end
            if bonus_mult > 0 or bonus_chips > 0 then
                return {
                    message = "Rended!",
                    mult = bonus_mult,
                    chips = bonus_chips,
                    colour = G.C.SUITS.Spades,
                    sound = "fm_stasis_fragment"
                }
            end
        end
    end
}

SMODS.Joker{
    key = "whisper_of_fissures",
    loc_txt = {
        name = "Whisper of Fissures",
        text = {
            "Retrigger all scored",
            "{C:spades}Shatter{} cards"
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
    pos = {x=2, y=6},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition and not context.repetition_only then
            local retriggered = false
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center == G.P_CENTERS.m_fm_shatter then
                    retriggered = true
                    -- G.E_MANAGER:add_event(Event({
                    --     func = function()
                    --         scoringCard:juice_up()
                    --         return true
                    --     end
                    -- }))
                end
            end
            if retriggered == true then
                return {
                    message = "Again!",
                    sound = "fm_stasis_fragment",
                    repetitions = 1,
                    colour = G.C.SUITS.Spades
                }
            end
        end
    end
}

SMODS.Joker{
    key = "whisper_of_fractures",
    loc_txt = {
        name = "Whisper of Fractures",
        text = {
            "Once per blind, when 2 {C:spades}Shatter{} cards",
            "gets destroyed in a single hand, gain {C:red}+2{} discards",
            "and {C:blue}+1{} hand",
            "{C:inactive}(Used this blind: {C:attention}#1#{C:inactive})"
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
    pos = {x=3, y=6},
    config = {
        extra = {
            used_this_blind = false
        }
    },
    loc_vars = function(self, info_queue, card)
        local status = card.ability.extra.used_this_blind and "Used" or "Unused"
        return { vars = { status } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.used_this_blind = false
        end

        if context.after and not card.ability.extra.used_this_blind then
            local shattered = G.FM_SHATTERED_THIS_HAND or 0
            if shattered >= 2 then
                card.ability.extra.used_this_blind = true
                G.GAME.current_round.discards_left = G.GAME.current_round.discards_left + 2
                G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + 1
                G.FM_SHATTERED_THIS_HAND = 0
                return {
                    message = "Bolstered!",
                    sound = "fm_stasis_fragment",
                    colour = G.C.SUITS.Spades
                }
            end
            -- Reset after checking
            G.FM_SHATTERED_THIS_HAND = 0
        end
    end
}

SMODS.Joker{
    key = "whisper_of_reversal",
    loc_txt = {
        name = "Whisper of Reversal",
        text = {
            "Scoring lower than your previous hand",
            "will grant {C:spades}Slow{} to a random",
            "unenhanced card in hand",
            "{C:inactive}(Last score: {C:attention}#1#{C:inactive})"
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
    pos = {x=4, y=6},
    config = {
        extra = {
            last_score = 0
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.last_score or 0 } }
    end,
    calculate = function(self, card, context)
        -- After scoring, check if current score is lower than previous
        if context.final_scoring_step then
            local current_score = hand_chips * mult
            if card.ability.extra.last_score > 0 and current_score < card.ability.extra.last_score then
                -- Find all unenhanced cards in hand
                local unenhanced = {}
                for _, handCard in ipairs(G.hand.cards) do
                    if handCard.ability.set ~= "Enhanced" then
                        table.insert(unenhanced, handCard)
                    end
                end
                if #unenhanced > 0 then
                    local target = pseudorandom_element(unenhanced, pseudoseed('unenhanced'))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target:flip()
                            target:set_ability(G.P_CENTERS.m_fm_slow)
                            target:flip()
                            return true
                        end
                    }))
                    SMODS.calculate_effect({
                        message = "Slowed!",
                        sound = "fm_stasis_fragment",
                        colour = G.C.SUITS.Spades
                    }, target)
                end
            end
            -- Update last_score for next hand
            card.ability.extra.last_score = current_score
        end
        -- Reset last_score at end of round
        if context.end_of_round then
            card.ability.extra.last_score = 0
        end
    end
}

SMODS.Joker{
    key = "whisper_of_durance",
    loc_txt = {
        name = "Whisper of Durance",
        text = {
            "Playing {C:attention}3{} of the same hand type in a row will",
            "grant {C:attention}$10{} to every {C:spades}Shatter{}",
            "card in hand",
            "{C:inactive}(Streak: {C:attention}#1#{C:inactive}, {C:attention}#2#{C:inactive}/3)"
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
    pos = {x=5, y=6},
    config = {
        extra = {
            current_hand_type = nil,
            hand_count = 0
        }
    },
    loc_vars = function(self, info_queue, card)
        local hand_type = card.ability.extra.current_hand_type or "None"
        local hand_count = card.ability.extra.hand_count or 0
        return { vars = { hand_type, hand_count } }
    end,
    calculate = function(self, card, context)
        -- Reset streak at the start of a blind
        if context.setting_blind then
            card.ability.extra.current_hand_type = nil
            card.ability.extra.hand_count = 0
        end

        -- After scoring, update streak and apply bonus if needed
        if context.final_scoring_step then
            local hand_type = context.scoring_name
            if hand_type then
                if card.ability.extra.current_hand_type == hand_type then
                    card.ability.extra.hand_count = card.ability.extra.hand_count + 1
                else
                    card.ability.extra.current_hand_type = hand_type
                    card.ability.extra.hand_count = 1
                end

                if card.ability.extra.hand_count >= 3 then
                    -- Grant $10 to every Shatter card in hand
                    for _, handCard in ipairs(G.hand.cards) do
                        if handCard.config.center == G.P_CENTERS.m_fm_shatter then
                            handCard.ability.extra.money = (handCard.ability.extra.money or 0) + 10
                            SMODS.calculate_effect({
                                message = "+$10",
                                sound = "fm_stasis_fragment",
                                colour = G.C.SUITS.Spades
                            }, handCard)
                        end
                    end
                    -- Reset streak after reward
                    card.ability.extra.hand_count = 0
                    card.ability.extra.current_hand_type = nil
                    return {
                        message = "Cash Out!",
                        sound = "fm_stasis_fragment",
                        colour = G.C.SUITS.Spades
                    }
                end
            end
        end
    end
}

SMODS.Joker{
    key = "thread_of_fury",
    loc_txt = {
        name = "Thread of Fury",
        text = {
            "Add half of every scored", 
            "{C:green}Strand{} card's Chips as Mult",
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
    pos = {x=0, y=7},
    calculate = function(self, card, context)
        if context.joker_main then
            local Mult = 0
            for i, scoredCard in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scoredCard, "m_fm_wovenmail") or 
                SMODS.has_enhancement(scoredCard, "m_fm_tangle") or 
                SMODS.has_enhancement(scoredCard, "m_fm_unravel") or
                SMODS.has_enhancement(scoredCard, "m_fm_suspend") then
                    Mult = Mult + ((scoredCard:get_chip_bonus())/2)
                end
            end
            return {
                mult = Mult
            }
        end
    end
}

SMODS.Joker{
    key = "thread_of_transmutation",
    loc_txt = {
        name = "Thread of Transmutation",
        text = {
            "Upon scoring a card with {C:green}Woven Mail{},",
            "grant an unenhanced card in hand {C:green}Tangle{}",
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
    pos = {x=1, y=7},
    calculate = function(self, card, context)
        if context.joker_main then
            local unenhancedCards = {}
            for i, handCard in ipairs(G.hand.cards) do
                if handCard.ability.set ~= "Enhanced" then
                    table.insert(unenhancedCards, handCard)
                end
            end
            for i, scoredCard in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scoredCard, "m_fm_wovenmail") then
                    if #unenhancedCards > 0 then
                        local card_index = pseudorandom("ugh", 1, #unenhancedCards)
                        local selectedCard = unenhancedCards[card_index]
                        selectedCard:flip()
                        selectedCard:set_ability(G.P_CENTERS.m_fm_tangle)
                        selectedCard:flip()
                        table.remove(unenhancedCards, card_index)
                    end
                end
            end
        end
    end
}

SMODS.Joker{
    key = "thread_of_warding",
    loc_txt = {
        name = "Thread of Warding",
        text = {
            "Upon fully charging a {C:green}Strand Super{}",
            "grant a random card in hand {C:green}Woven Mail{}",
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
    pos = {x=2, y=7},
    calculate = function(self, card, context)
        for _, joker in ipairs(G.jokers.cards) do
            if joker.config.center_key == "j_fm_bladefury" or joker.config.center_key == "j_fm_needlestorm" then
                -- Track last_state for each super
                joker.ability.extra.last_state = joker.ability.extra.last_state or joker.ability.extra.state

                -- If just transitioned to "ready", trigger the effect
                if joker.ability.extra.state == "ready" and joker.ability.extra.last_state ~= "ready" then
                    -- Find all unenhanced cards in hand
                    local unenhanced = {}
                    for _, handCard in ipairs(G.hand.cards) do
                        if handCard.ability.set ~= "Enhanced" then
                            table.insert(unenhanced, handCard)
                        end
                    end

                    if #unenhanced > 0 then
                        local target = pseudorandom_element(unenhanced, pseudoseed('unenhanced'))
                        SMODS.calculate_effect({
                            message = "Warded!",
                            sound = "fm_strand_fragment",
                            colour = G.C.GREEN
                        }, target)
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                target:flip()
                                target:set_ability(G.P_CENTERS.m_fm_wovenmail)
                                target:flip()
                                return true
                            end
                        }))
                    end
                end

                -- Update last_state for next check
                joker.ability.extra.last_state = joker.ability.extra.state
            end
        end
    end
}

SMODS.Joker{
    key = "thread_of_rebirth",
    loc_txt = {
        name = "Thread of Rebirth",
        text = {
            "Every {C:green}Strand{} card played has a {C:green}#1# in #2#{} chance of",
            "creating an {C:attention}unenhanced copy{} of it",
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
    pos = {x=3, y=7},
    config = {
        extra = {
            denom = 5
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal, card.ability.extra.denom or 5 } }
    end,
    calculate = function(self, card, context)
        if context.after then
            for i, scoredCard in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scoredCard, "m_fm_tangle") or
                   SMODS.has_enhancement(scoredCard, "m_fm_wovenmail") or
                   SMODS.has_enhancement(scoredCard, "m_fm_unravel") or
                   SMODS.has_enhancement(scoredCard, "m_fm_suspend") then
                    if pseudorandom('rebirth') < (G.GAME.probabilities.normal / (card.ability.extra.denom or 5)) then
                        local new_card = copy_card(scoredCard, nil, nil, G.playing_card)
                        new_card:set_ability(G.P_CENTERS.c_base)
                        new_card.T.y = scoredCard.T.y - G.CARD_H
                        table.insert(G.playing_cards, new_card)
                        G.deck.config.card_limit = G.deck.config.card_limit + 1
                        draw_card(G.play, G.hand, 90, 'up', nil, new_card)
                        new_card:start_materialize()
                    end
                end
            end
        end
    end
}

SMODS.Joker{
    key = "thread_of_evolution",
    loc_txt = {
        name = "Thread of Evolution",
        text = {
            "{C:green}Unravel{} cards gain {C:green}2 Threads{}",
            "instead of 1"
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
    pos = {x=4, y=7},
    add_to_deck = function(self, card, from_debuff)
        for _, handCard in ipairs(G.hand.cards) do
            if handCard.config.center == G.P_CENTERS.m_fm_unravel then
                handCard.ability.extra.threads_per_hand = 2
            end
        end
        for i = #G.deck.cards, 1, -1 do
            if G.deck.cards[i].config.center == G.P_CENTERS.m_fm_unravel then
                G.deck.cards[i].ability.extra.threads_per_hand = 2
            end
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        for _, handCard in ipairs(G.hand.cards) do
            if handCard.config.center == G.P_CENTERS.m_fm_unravel then
                handCard.ability.extra.threads_per_hand = 1
            end
        end
        for i = #G.deck.cards, 1, -1 do
            if G.deck.cards[i].config.center == G.P_CENTERS.m_fm_unravel then
                G.deck.cards[i].ability.extra.threads_per_hand = 1
            end
        end
    end,
    calculate = function(self, card, context)

    end
}

SMODS.Joker{
    key = "thread_of_finality",
    loc_txt = {
        name = "Thread of Finality",
        text = {
            "Create a random {C:green}Strand{} card",
            "when you have two or less hands remaining",
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
    pos = {x=5, y=7},
    calculate = function(self, card, context)
        if context.after and context.scoring_hand  then
            if G.GAME.current_round.hands_left < 3 then
                -- List of all possible Strand enhancements
                local strand_enhancements = {
                    G.P_CENTERS.m_fm_tangle,
                    G.P_CENTERS.m_fm_wovenmail,
                    G.P_CENTERS.m_fm_unravel,
                    G.P_CENTERS.m_fm_suspend
                }
                -- Pick a random enhancement
                local enhancement = pseudorandom_element(strand_enhancements, pseudoseed('strand enhancements'))

                -- Create a new Strand card with the chosen enhancement
                local suit = pseudorandom_element(SMODS.Suit.obj_buffer, pseudoseed('suit'))
                local rank = pseudorandom_element(SMODS.Rank.obj_buffer, pseudoseed('rank'))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        local new_card = Card(G.hand.T.x, G.hand.T.y, G.CARD_W, G.CARD_H, {suit=suit, value=rank}, enhancement)
                        new_card.T.y = 6 - G.CARD_H
                        SMODS.change_base(new_card, suit, rank)
                        new_card:start_materialize({G.C.SECONDARY_SET.Enhanced})
                        SMODS.calculate_effect({
                            sound = "fm_strand_fragment",
                            message = "!",
                            colour = G.C.GREEN
                        }, new_card)
                        G.play:emplace(new_card)
                        table.insert(G.playing_cards, new_card)
                        draw_card(G.play, G.hand, 90, 'up', nil, new_card)
                        return true
                    end
                }))
            end
        end
    end
}

SMODS.Joker{
    key = "splinter_of_subjugation",
    loc_txt = {
        name = "Splinter of Subjugation",
        text = {
            "{C:red}Discard{} the same hand you have previously played", 
            "to grant super charges to a random Resonance Super", 
            "depending on the number of cards discarded",
            "{C:inactive}(Last hand played: {C:attention}#1#{C:inactive})"
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
    pos = {x=0, y=8},
    config = {
        extra = {
            last_played_hand = nil
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.last_played_hand or "None" } }
    end,
    calculate = function(self, card, context)
        -- Track last played hand type after scoring
        if context.final_scoring_step then
            card.ability.extra.last_played_hand = context.scoring_name
        end

        -- On discard, check if hand matches last played hand type
        if context.pre_discard and card.ability.extra.last_played_hand then
            -- Determine the hand type of the cards being discarded
            local text, disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            local discard_hand_type = text

            if discard_hand_type == card.ability.extra.last_played_hand then
                -- Find all Resonance Super Jokers
                local resonance_supers = {}
                for _, joker in ipairs(G.jokers.cards) do
                    if joker.config.center_key == "j_fm_witnesss_shatter" or joker.config.center_key == "j_fm_resonate_whirlwind" then
                        table.insert(resonance_supers, joker)
                    end
                end
                if #resonance_supers > 0 then
                    local target_joker = pseudorandom_element(resonance_supers, pseudoseed('resonance supers'))
                    local num_discarded = #G.hand.highlighted
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target_joker.ability.extra.charge = math.min(5, (target_joker.ability.extra.charge or 0) + num_discarded)
                            SMODS.calculate_effect({
                                message = "+" .. num_discarded .. " Charge!",
                                sound = "fm_super_charge",
                                colour = G.C.BLACK
                            }, target_joker)
                            if target_joker.ability.extra.charge >= 5 then
                                target_joker.ability.extra.state = "ready"
                                juice_card_until(target_joker, function() return target_joker.ability.extra.state == "ready" end, true)
                            end
                            return true
                        end
                    }))
                end
            end
        end
    end
}

SMODS.Joker{
    key = "splinter_of_convergence",
    loc_txt = {
        name = "Splinter of Convergence",
        text = {
            "Scoring a hand with only Resonance cards {C:attention}merges{} them",
            "into one card with a random Resonance enhancement and new rank",
            "totaling the original ranks", 
            "{C:inactive}({C:red}High Cards{C:inactive} not included)"
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
    pos = {x=1, y=8},
    calculate = function(self, card, context)
        if context.after and context.scoring_hand and context.scoring_name ~= "High Card" then
            local resonance_keys = {
                "m_fm_resonant",
                "m_fm_finalized",
                "m_fm_dissected",
                "m_fm_rooted"
            }
            local resonance_centers = {}
            for _, k in ipairs(resonance_keys) do
                if G.P_CENTERS[k] then table.insert(resonance_centers, G.P_CENTERS[k]) end
            end

            local all_resonance = true
            local total_rank = 0
            for _, scoredCard in ipairs(context.scoring_hand) do
                local is_resonance = false
                for _, center in ipairs(resonance_centers) do
                    if scoredCard.config and scoredCard.config.center == center then
                        is_resonance = true
                        break
                    end
                end
                if not is_resonance then
                    all_resonance = false
                    break
                end
                total_rank = total_rank + (scoredCard.base and scoredCard.base.nominal or scoredCard:get_id())
            end

            if all_resonance and #context.scoring_hand > 1 then
                local max_rank = SMODS.Rank.obj_buffer[#SMODS.Rank.obj_buffer]
                if total_rank > SMODS.Ranks[max_rank].nominal then
                    total_rank = SMODS.Ranks[max_rank].nominal
                end

                local new_rank_key = SMODS.Rank.obj_buffer[1]
                for _, k in ipairs(SMODS.Rank.obj_buffer) do
                    if SMODS.Ranks[k].nominal <= total_rank then
                        new_rank_key = k
                    else
                        break
                    end
                end

                local enhancement = pseudorandom_element(resonance_centers, pseudoseed('resonance centers'))
                local suit = context.scoring_hand[1].base and context.scoring_hand[1].base.suit or pseudorandom_element(SMODS.Suit.obj_buffer, pseudoseed('suit'))

                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        for _, scoredCard in ipairs(context.scoring_hand) do
                            scoredCard:start_dissolve()
                        end

                        local new_card = Card(G.hand.T.x, G.hand.T.y, G.CARD_W, G.CARD_H, {suit=suit, value=new_rank_key}, enhancement)
                        new_card.T.y = 6 - G.CARD_H
                        SMODS.change_base(new_card, suit, new_rank_key)
                        new_card:start_materialize({G.C.SECONDARY_SET.Enhanced})
                        SMODS.calculate_effect({
                            message = "Converged!",
                            sound = "fm_resonance_fragment",
                            colour = G.C.BLACK
                        }, new_card)

                        G.play:emplace(new_card)
                        table.insert(G.playing_cards, new_card)
                        draw_card(G.play, G.hand, 90, 'up', nil)
                        return true
                    end
                }))
            end
        end
    end
}

SMODS.Joker{
    key = "splinter_of_verity",
    loc_txt = {
        name = "Splinter of Verity",
        text = {
            "All Dissected cards will only switch",
            "to face cards and Aces"
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
    pos = {x=2, y=8},
    calculate = function(self, card, context)

    end
}

SMODS.Joker{
    key = "splinter_of_dread",
    loc_txt = {
        name = "Splinter of Dread",
        text = {
            ""
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
    pos = {x=3, y=8},
    calculate = function(self, card, context)

    end
}

SMODS.Joker{
    key = "splinter_of_corruption",
    loc_txt = {
        name = "Splinter of Corruption",
        text = {
            "Catatonic cards scale up faster by increments of {C:red}+20{} Mult",
            "{C:red}-1{} hand size"
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
    pos = {x=4, y=8},
    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(-1)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(1)
    end
}

SMODS.Joker{
    key = "splinter_of_dissent",
    loc_txt = {
        name = "Splinter of Dissent",
        text = {
            "Scoring 3 Finalized cards in a single hand",
            "will cause the highest ranked one to be",
            "split into 3 unenhanced cards of smaller but equal ranks"
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
    pos = {x=5, y=8},
    calculate = function(self, card, context)

    end
}

-- EXOTIC JOKERS

SMODS.Joker{
    key = "microcosm",
    loc_txt = {
        name = "Microcosm",
        text = {
            "Every time you play 3 or more cards, draw a card and give it polychrome",
            "If a played hand only has scoring cards of one Subclass, give the",
            "highest and lowest cards in hand a random buff from said Subclass"
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
    pos = {x=2, y=9},
    calculate = function(self, card, context)
        if context.joker_main then
            local solarEnhancements = {
                G.P_CENTERS.m_fm_radiant,-- Solar
                G.P_CENTERS.m_fm_scorch,
                G.P_CENTERS.m_fm_restoration,
                G.P_CENTERS.m_fm_cure
            }
            local voidEnhancements = {
                G.P_CENTERS.m_fm_overshield, -- Void
                G.P_CENTERS.m_fm_volatile,
                G.P_CENTERS.m_fm_devour,
                G.P_CENTERS.m_fm_suppress
            }
            local arcEnhancements = {
                G.P_CENTERS.m_fm_amplified, -- Arc
                G.P_CENTERS.m_fm_jolt,
                G.P_CENTERS.m_fm_blinded,
                G.P_CENTERS.m_fm_bolt_charge
            }
            local stasisEnhancements = {
                G.P_CENTERS.m_fm_shatter, -- Stasis
                G.P_CENTERS.m_fm_freeze,
                G.P_CENTERS.m_fm_slow,
                G.P_CENTERS.m_fm_stasis_crystal
            }
            local strandEnhancements = {
                G.P_CENTERS.m_fm_wovenmail, -- Strand
                G.P_CENTERS.m_fm_tangle,
                G.P_CENTERS.m_fm_unravel,
                G.P_CENTERS.m_fm_suspend
            }
            local resonantEnhancements = {
                G.P_CENTERS.m_fm_resonant, -- Resonant
                G.P_CENTERS.m_fm_finalized,
                G.P_CENTERS.m_fm_dissected,
                G.P_CENTERS.m_fm_rooted
            }
            local Voidd = 0
            local Solarr = 0
            local Arcc = 0
            local Stasiss = 0
            local Strandd = 0
            local Resonancee = 0

            for _, scored_card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scored_card, "m_fm_overshield") or SMODS.has_enhancement(scored_card, "m_fm_devour") or SMODS.has_enhancement(scored_card, "m_fm_volatile") or SMODS.has_enhancement(scored_card, "m_fm_suppress") then
                    Voidd = Voidd + 1
                elseif SMODS.has_enhancement(scored_card, "m_fm_radiant") or SMODS.has_enhancement(scored_card, "m_fm_restoration") or SMODS.has_enhancement(scored_card, "m_fm_scorch") or SMODS.has_enhancement(scored_card, "m_fm_cure") then
                    Solarr = Solarr + 1
                elseif SMODS.has_enhancement(scored_card, "m_fm_blinded") or SMODS.has_enhancement(scored_card, "m_fm_jolt") or SMODS.has_enhancement(scored_card, "m_fm_amplified") or SMODS.has_enhancement(scored_card, "m_fm_bolt_charge") then
                    Arcc = Arcc + 1
                elseif SMODS.has_enhancement(scored_card, "m_fm_slow") or SMODS.has_enhancement(scored_card, "m_fm_freeze") or SMODS.has_enhancement(scored_card, "m_fm_shatter") or SMODS.has_enhancement(scored_card, "m_fm_stasis_crystal") then
                    Stasiss = Stasiss + 1
                elseif SMODS.has_enhancement(scored_card, "m_fm_wovenmail") or SMODS.has_enhancement(scored_card, "m_fm_tangle") or SMODS.has_enhancement(scored_card, "m_fm_unravel") or SMODS.has_enhancement(scored_card, "m_fm_suspend") then
                    Strandd = Strandd + 1
                elseif SMODS.has_enhancement(scored_card, "m_fm_resonant") or SMODS.has_enhancement(scored_card, "m_fm_finalized") or SMODS.has_enhancement(scored_card, "m_fm_dissected") or SMODS.has_enhancement(scored_card, "m_fm_rooted") then
                    Resonancee = Resonancee + 1
                end
            end

            if Voidd == #context.scoring_hand then
                G.hand.cards[1]:flip()
                G.hand.cards[1]:set_ability(pseudorandom_element(voidEnhancements, pseudoseed('Break Through')))
                G.hand.cards[1]:flip()
                G.hand.cards[#G.hand.cards]:flip()
                G.hand.cards[#G.hand.cards]:set_ability(pseudorandom_element(voidEnhancements, pseudoseed('Break Through')))
                G.hand.cards[#G.hand.cards]:flip()
            elseif Solarr == #context.scoring_hand then
                G.hand.cards[1]:flip()
                G.hand.cards[1]:set_ability(pseudorandom_element(solarEnhancements, pseudoseed('Break Through')))
                G.hand.cards[1]:flip()
                G.hand.cards[#G.hand.cards]:flip()
                G.hand.cards[#G.hand.cards]:set_ability(pseudorandom_element(solarEnhancements, pseudoseed('Break Through')))
                G.hand.cards[#G.hand.cards]:flip()
            elseif Arcc == #context.scoring_hand then
                G.hand.cards[1]:flip()
                G.hand.cards[1]:set_ability(pseudorandom_element(arcEnhancements, pseudoseed('Break Through')))
                G.hand.cards[1]:flip()
                G.hand.cards[#G.hand.cards]:flip()
                G.hand.cards[#G.hand.cards]:set_ability(pseudorandom_element(arcEnhancements, pseudoseed('Break Through')))
                G.hand.cards[#G.hand.cards]:flip()
            elseif Stasiss == #context.scoring_hand then
                G.hand.cards[1]:flip()
                G.hand.cards[1]:set_ability(pseudorandom_element(stasisEnhancements, pseudoseed('Break Through')))
                G.hand.cards[1]:flip()
                G.hand.cards[#G.hand.cards]:flip()
                G.hand.cards[#G.hand.cards]:set_ability(pseudorandom_element(stasisEnhancements, pseudoseed('Break Through')))
                G.hand.cards[#G.hand.cards]:flip()
            elseif Strandd == #context.scoring_hand then
                G.hand.cards[1]:flip()
                G.hand.cards[1]:set_ability(pseudorandom_element(strandEnhancements, pseudoseed('Break Through')))
                G.hand.cards[1]:flip()
                G.hand.cards[#G.hand.cards]:flip()
                G.hand.cards[#G.hand.cards]:set_ability(pseudorandom_element(strandEnhancements, pseudoseed('Break Through')))
                G.hand.cards[#G.hand.cards]:flip()
            elseif Resonancee == #context.scoring_hand then
                G.hand.cards[1]:flip()
                G.hand.cards[1]:set_ability(pseudorandom_element(resonantEnhancements, pseudoseed('Break Through')))
                G.hand.cards[1]:flip()
                G.hand.cards[#G.hand.cards]:flip()
                G.hand.cards[#G.hand.cards]:set_ability(pseudorandom_element(resonantEnhancements, pseudoseed('Break Through')))
                G.hand.cards[#G.hand.cards]:flip()
            end


            if #context.scoring_hand >= 3 then
                local _cards = {}
                for _, playing_card in ipairs(G.playing_cards) do
                    _cards[#_cards + 1] = playing_card
                end
                local selected_card = pseudorandom_element(_cards, pseudoseed('Balalalala'))

                draw_card(G.deck, G.hand, 90, 'up', nil, selected_card)

                selected_card:flip()
                selected_card:set_edition("e_polychrome")
                selected_card:flip()
            end
        end
    end
}

SMODS.Joker{
    key = "graviton_lance", -- you keep forgetting "remove = true" on cards that are supposed to destroy themselves. You also forgot "context.destroying_card == card" and "context.cardarea == G.play" on the preceding if statement.
    loc_txt = {
        name = "Graviton Lance",
        text = {
            "Every even numbered hand has base chips and mult doubled",
            "Volatile cards retrigger but the retrigger halves the Mult bonus",
            "each Volatile card in hand gains the amount that was removed",
            "(First ability is calculated based on the number of hands before hitting play)",
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
    pos = {x=3, y=2},
    calculate = function(self, card, context)
        if context.modify_hand then
            if ((G.GAME.current_round.hands_left + 1) % 2)  == 0 then
                mult = mult*2
                hand_chips = hand_chips*2
                update_hand_text({ sound = 'chips2', modded = true }, { chips = hand_chips, mult = mult })
            end
        end
        if context.repetition and not context.repetition_only and not context.end_of_round and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, "m_fm_volatile") then
            context.other_card.ability.extra.mult = context.other_card.ability.extra.mult/2
            for i, handCard in ipairs (G.hand.cards) do
                if SMODS.has_enhancement(handCard, "m_fm_volatile") then
                    handCard:flip()
                    handCard.ability.extra.mult = handCard.ability.extra.mult + (context.other_card.ability.extra.mult / 2)
                    handCard:flip()
                end
            end
            return {
                card = context.other_card,
                repetitions = 1,
            }
        end
    end
}

SMODS.Joker{
    key = "sunshot",
    loc_txt = {
        name = "Sunshot",
        text = {
            "After scoring, grant the first",
            "card scored one stack of Scorch",
            "If the played hand only contains solar buffed",
            "cards, ignite any scored scorched cards",
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
    pos = {x=4, y=2},
    calculate = function(self, card, context)
        local Solarr = 0

        if context.joker_main then
            for i, scored_card in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scored_card, "m_fm_radiant") or SMODS.has_enhancement(scored_card, "m_fm_restoration") or SMODS.has_enhancement(scored_card, "m_fm_scorch") or SMODS.has_enhancement(scored_card, "m_fm_cure") then
                    Solarr = Solarr + 1
                end
            end
            if Solarr == #context.scoring_hand then
                for i, scored_card in ipairs(context.scoring_hand) do
                    if SMODS.has_enhancement(scored_card, "m_fm_scorch") then
                        scored_card.ability.extra.stacks = 3
                    end
                end
            end
        end

        if context.after then
            if not SMODS.has_enhancement(G.play.cards[1], "m_fm_scorch") then
                G.play.cards[1]:flip()
                G.play.cards[1]:set_ability(G.P_CENTERS.m_fm_scorch)
                G.play.cards[1]:flip()
            else
                G.play.cards[1].ability.extra.stacks = G.play.cards[1].ability.extra.stacks + 1
            end
        end
    end
}

SMODS.Joker{
    key = "wicked_implement",
    loc_txt = {
        name = "Wicked Implement",
        text = {
            "Every unenhanced card scored is slowed,",
            "and every slowed card scored is frozen",
            "When a Freeze card is played, retrigger it twice and Shatter it",
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
    pos = {x=6, y=2},
    calculate = function(self, card, context)
        if context.joker_main then
            for i, scoredCard in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scoredCard, "m_fm_slow") then
                    scoredCard:flip()
                    scoredCard:set_ability(G.P_CENTERS.m_fm_freeze)
                    scoredCard:flip()
                elseif scoredCard.ability.set ~= "Enhanced" then
                    scoredCard:flip()
                    scoredCard:set_ability(G.P_CENTERS.m_fm_slow)
                    scoredCard:flip()
                end
            end
        end
        if context.repetition and not context.repetition_only and not context.end_of_round and context.cardarea == G.play and SMODS.has_enhancement(context.other_card, "m_fm_freeze") then
            context.other_card:flip()
            context.other_card:set_ability(G.P_CENTERS.m_fm_shatter)
            context.other_card:flip()
            return {
                repetitions = 2,
            }
        end
    end
}

SMODS.Joker{
    key = "ace_of_spades",
    loc_txt = {
        name = "Ace of Spades",
        text = {
            "Scoring {C:attention}Aces{} will build up stacks of {C:attention}Memento Mori{}",
            "At {C:attention}6{} stacks, every {C:attention}Ace{} scored will become {C:attention}Scorched{}",
            "Scoring {C:attention}Aces of Spades{} will instantly",
            "{C:attention}ignite{} when {C:attention}Memento Mori{} is active",
            "{C:inactive}(Currently {C:attention}#1#{C:inactive}/6)",
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
    pos = {x=1, y=9},
    config = {
        extra = {
            memento_mori = 0
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.memento_mori or 0 } }
    end,
    calculate = function(self, card, context)
        -- Add stacks for each Ace scored
        if context.before then
            local gained = 0
            for _, scoredCard in ipairs(context.scoring_hand) do
                if scoredCard.base.value == "Ace" then
                    card.ability.extra.memento_mori = card.ability.extra.memento_mori + 1
                    gained = gained + 1
                end
            end
            if gained > 0 then
                SMODS.calculate_effect({
                    message = "+" .. gained .. " Memento Mori",
                    -- sound = "fm_memento_stack",
                    colour = G.C.RED
                }, card)
            end
        end

        -- When 6 stacks are reached, ignite all scored Aces
        if context.joker_main then
            if card.ability.extra.memento_mori >= 6 then
                if card.ability.extra.memento_mori > 6 then
                    card.ability.extra.memento_mori = 6
                end
                SMODS.calculate_effect({
                    message = "Draw!",
                    -- sound = "fm_memento_ready",
                    colour = G.C.RED
                }, card)
                for _, scoredCard in ipairs(context.scoring_hand) do
                    if scoredCard.base.value == "Ace" then
                        scoredCard:flip()
                        scoredCard:set_ability(G.P_CENTERS.m_fm_scorch)
                        scoredCard:flip()
                        SMODS.calculate_effect({
                            message = "Scorched!",
                            -- sound = "fm_memento_scorch",
                            colour = G.C.ORANGE
                        }, scoredCard)
                        if scoredCard.base.suit == "Spades" then
                            scoredCard.ability.extra.stacks = 3
                            SMODS.calculate_effect({
                                message = "Ignited!",
                                -- sound = "fm_memento_ignite",
                                colour = G.C.ORANGE
                            }, scoredCard)
                        end
                    end
                end
            end
        end

        -- Reset stacks after effect triggers
        if context.after then
            if card.ability.extra.memento_mori >= 6 then
                card.ability.extra.memento_mori = 0
            end
        end
    end
}

SMODS.Joker{
    key = "finalitys_auger",
    loc_txt = {
        name = "Finality's Auger",
        text = {
            "If all cards in hand contain Resonance enhancements,",
            "grant all scoring cards Resonant and",
            "Dissect all debuffed cards in hand",
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
        local buffedHand = 0
        if context.joker_main then
            for i, handCard in ipairs(G.hand.cards) do
                if SMODS.has_enhancement(handCard, "m_fm_resonant") or SMODS.has_enhancement(handCard, "m_fm_finalized") or SMODS.has_enhancement(handCard, "m_fm_dissected") or SMODS.has_enhancement(handCard, "m_fm_rooted") then
                    buffedHand = buffedHand + 1
                end
            end
            if buffedHand == #G.hand.cards then
                buffedHand = 0
                for i, scoredCard in ipairs(context.scoring_hand) do
                    scoredCard:flip()
                    scoredCard:set_ability(G.P_CENTERS.m_fm_resonant)
                    scoredCard:flip()
                end
                for i, handCard in ipairs(G.hand.cards) do
                    if handCard.debuff then
                        handCard:flip()
                        handCard:set_ability(G.P_CENTERS.m_fm_dissected)
                        handCard:flip()
                    end
                end
            end
        end
    end
}

SMODS.Joker{
    key = "hard_liquor",
    loc_txt = {
        name = "Hard Light",
        text = {
            "For every hand played, this Joker will cycle through Void, Solar and Arc",
            "Scoring respective elemental enhancements will grant +$5 for each scoring card",
            "(Currently: x)",
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
            type = "Void"
        }
    },
    calculate = function(self, card, context)
        if context.joker_main then
            local amount = 0
            if card.ability.extra.type == "Void" then
                for i, scoredCard in ipairs(context.scoring_hand) do
                    if SMODS.has_enhancement(scoredCard, "m_fm_overshield") or SMODS.has_enhancement(scoredCard, "m_fm_devour") or SMODS.has_enhancement(scoredCard, "m_fm_volatile") or SMODS.has_enhancement(scoredCard, "m_fm_suppress") then
                        amount = amount + 1
                    end
                end
                card.ability.extra.type = "Solar"
            elseif card.ability.extra.type == "Solar" then
                for i, scoredCard in ipairs(context.scoring_hand) do
                    if SMODS.has_enhancement(scoredCard, "m_fm_radiant") or SMODS.has_enhancement(scoredCard, "m_fm_restoration") or SMODS.has_enhancement(scoredCard, "m_fm_scorch") or SMODS.has_enhancement(scoredCard, "m_fm_cure") then
                        amount = amount + 1
                    end
                end
                card.ability.extra.type = "Arc"
            elseif card.ability.extra.type == "Arc" then
                for i, scoredCard in ipairs(context.scoring_hand) do
                    if SMODS.has_enhancement(scoredCard, "m_fm_blinded") or SMODS.has_enhancement(scoredCard, "m_fm_jolt") or SMODS.has_enhancement(scoredCard, "m_fm_amplified") or SMODS.has_enhancement(scoredCard, "m_fm_bolt_charge") then
                        amount = amount + 1
                    end
                end
                card.ability.extra.type = "Void"
            end
            return {
                dollars = 5 * amount,
            }
        end
    end
}

SMODS.Joker{
    key = "icefall_mantle",
    loc_txt = {
        name = "Icefall Mantle",
        text = {
            "All Shattered cards do not become destroyed on their effect being triggered",
            "After scoring, any Shattered cards that have $0 are Slowed",
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
        if context.before then 
            for i, deckCard in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(deckCard, "m_fm_shatter") then
                    deckCard.ability.extra.destroy = false
                end
            end
        end
        if context.after then
            for i, scoredCard in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(scoredCard, "m_fm_shatter") then
                    if scoredCard.ability.extra.money == 0 then
                        scoredCard:flip()
                        scoredCard:set_ability(G.P_CENTERS.m_fm_slow)
                        scoredCard:flip()
                    end
                end
            end
        end
        if context.selling_self or context.end_of_round then
            for i, deckCard in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(deckCard, "m_fm_shatter") then
                    deckCard.ability.extra.destroy = true
                end
            end
        end
    end
}
-- works
SMODS.Enhancement {
    key = "resonant",
    loc_txt = {
        name = "Resonant",
        text = {
            "RESONANCE",
            "When scored, gain {X:mult,C:white}X0.5{}",
            "Mult for each {C:attention}debuffed{} or {C:attention}Catatonic{}",
            "card in hand"
        }
    },
    atlas = 'Enhancements',
    pos = {x=0, y=6},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            local debuffed_count = 0
            for _, handCard in ipairs(G.hand.cards) do
                if handCard.debuff or handCard.ability.fm_catatonic then
                    debuffed_count = debuffed_count + 1
                end
            end
            
            if debuffed_count > 0 then
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "Resonant!",
                    sound = "fm_resonant",
                    colour = G.C.BLACK
                })
                return{
                    x_mult = 1 + (0.5 * debuffed_count)
                }
            end
        end
    end
}

-- works
SMODS.Enhancement {
    key = "finalized",
    loc_txt = {
        name = "Finalized",
        text = {
            "RESONANCE",
            "Has a {C:green}#1# in #2#{} chance to convert 3",
            "random cards in hand to this",
            "card's suit when scored"
        }
    },
    config = {
        extra = {
            denom = 4
        }
    },
    atlas = 'Enhancements',
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal, card.ability.extra.denom } }
    end,
    pos = {x=1, y=6},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            if pseudorandom('finalized') < G.GAME.probabilities.normal / card.ability.extra.denom then
                local eligible_cards = {}
                for _, handCard in ipairs(G.hand.cards) do
                    if handCard.base.suit ~= card.base.suit then
                        table.insert(eligible_cards, handCard)
                    end
                end
     
                for i = 1, math.min(3, #eligible_cards) do
                    local random_index = pseudorandom("eligible_cards", 1, #eligible_cards)
                    local target_card = table.remove(eligible_cards, random_index)
                    target_card:flip()
                    SMODS.calculate_effect({
                        message = ("Finalized!"),
                        sound = "fm_finalized",
                        colour = G.C.BLACK
                    }, target_card)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            target_card:change_suit(card.base.suit)
                            target_card:flip()
                            return true
                        end
                    }))
                end
            end
        end
    end
}

SMODS.Enhancement {
    key = "dissected",
    loc_txt = {
        name = "Dissected",
        text = {
            "RESONANCE",
            "When scored, randomizes rank and suit and",
            "then gains {C:attention}double{} the chips",
            "If the new rank is higher",
            "than the original, gain {X:mult,C:white}X1.5{} Mult"
        }
    },
    atlas = 'Enhancements',
    config = {
        chips = 0
    },
    pos = {x=2, y=6},
    calculate = function(self, card, context)
        local splinter_of_verity = false
        for _, joker in ipairs(G.jokers.cards) do
            if joker.config.center_key == "j_fm_splinter_of_verity" then
                splinter_of_verity = true
                break
            end
        end
        if context.cardarea == G.play and context.main_scoring then
            local original_rank_id = card:get_id()
            
            local random_suit_index = pseudorandom_element(SMODS.Suit.obj_buffer, pseudoseed('dissected_suit'))
            local new_suit = SMODS.Suit.obj_buffer[random_suit_index]
            
            local new_rank_key
            if splinter_of_verity then
                local face_ranks = {}
                for k, v in pairs(SMODS.Ranks) do
                    if v.face or k == "Ace" then
                        table.insert(face_ranks, k)
                    end
                end
                new_rank_key = pseudorandom_element(face_ranks, pseudoseed('dissected_rank'))
            else
                local new_rank = pseudorandom_element(SMODS.Rank.obj_buffer, pseudoseed('dissected_rank'))
                new_rank_key = tostring(new_rank)
            end
            
            local new_rank_id = SMODS.Ranks[new_rank_key].id
            
            card:flip()
            SMODS.change_base(card, new_suit, new_rank_key)
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "Reshaped!",
                sound = "fm_dissected",
                colour = G.C.BLACK
            })
            card:flip()
            
            if new_rank_id > original_rank_id then
                return {
                    chips = new_rank_id * 2,
                    x_mult = 1.5
                }
            else
                return {
                    chips = new_rank_id * 2
                }
            end
        end
    end
}

SMODS.Enhancement {
    key = "rooted",
    loc_txt = {
        name = "Rooted",
        text = {
            "RESONANCE",
            "Each turn in hand, gain {C:blue}+20{} Chips",
            "Decrements in rank each turn in hand",
            "Becomes Catatonic when rank reaches 2",
            "{C:inactive}(Currently: {C:blue}+#1# {C:inactive}Chips)"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            chips = 0
        }
    },
    pos = {x=4, y=7},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.hand and context.main_scoring then
            card.ability.extra.chips = (card.ability.extra.chips or 0) + 20
            return {
                chips = card.ability.extra.chips,
                message = "Chips Up!",
                colour = G.C.BLUE,
                -- sound = "fm_rooted"
            }
        end
        if context.cardarea == G.hand and context.after then
            local current_rank = card.base.value
            local num_steps = -1
            
            local current_index = nil
            for idx, rank_key in ipairs(SMODS.Rank.obj_buffer) do
                if rank_key == current_rank then
                    current_index = idx
                    break
                end
            end
            
            if current_index then
                local new_index = math.max(current_index + num_steps, 1)
                local new_rank = SMODS.Rank.obj_buffer[new_index]
                
                card:flip()
                SMODS.change_base(card, card.base.suit, new_rank)
                card:flip()
                
                if new_index == 1 then
                    -- Apply Catatonic effect
                    SMODS.calculate_effect({
                        message = "Catatonic!",
                        sound = "fm_witnesss_shatter",
                        colour = G.C.BLACK
                    }, card)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            card:juice_up()
                            SMODS.Stickers.fm_catatonic:apply(card, true)
                            card:set_ability(G.P_CENTERS.c_base)
                            return true
                        end
                    }))
                end
            end
        end
    end
}
-- works
SMODS.Enhancement {
    key = "resonant",
    loc_txt = {
        name = "Resonant",
        text = {
            "RESONANCE",
            "When scored, gain {X:mult,C:white}X0.5{}",
            "Mult for each {C:attention}debuffed{}",
            "card in hand"
        }
    },
    atlas = 'Enhancements',
    pos = {x=0, y=6},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            local debuffed_count = 0
            for _, handCard in ipairs(G.hand.cards) do
                if handCard.debuff then
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
            "Has a {C:green}#1# in #2#{} chance to convert 5",
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
     
                for i = 1, math.min(5, #eligible_cards) do
                    local random_index = math.random(1, #eligible_cards)
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
            "if the new rank is higher than the original",
            "gain {X:mult,C:white}X1.5{} Mult"
        }
    },
    atlas = 'Enhancements',
    config = {
        chips = 0
    },
    pos = {x=2, y=6},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            local original_rank_id = card:get_id()
            
            local random_suit_index = math.random(1, #SMODS.Suit.obj_buffer)
            local new_suit = SMODS.Suit.obj_buffer[random_suit_index]
            
            local random_rank_index = math.random(1, #SMODS.Rank.obj_buffer)
            local new_rank = SMODS.Rank.obj_buffer[random_rank_index]
            
            local new_rank_id = SMODS.Ranks[new_rank].id
            
            card:flip()
            SMODS.change_base(card, new_suit, new_rank)
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
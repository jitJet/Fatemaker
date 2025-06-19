-- works
SMODS.Enhancement {
    key = "slow",
    loc_txt = {
        name = "Slow",
        text = {
            "{C:spades}STASIS{}",
            "Has a {C:green}#1# in #2#{} chance of returning",
            "to hand after being played.",
            "Will {C:spades}Freeze{} when played",
            "with adjacent {C:spades}Slow{} cards"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            frozen = false,
            denom = 4
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.probabilities.normal, card.ability.extra.denom } }
    end,
    pos = {x=0, y=5},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            for i, playedCard in ipairs(context.scoring_hand) do
                if playedCard == card then
                    local adjacent_slow = false
                    local cards_to_freeze = {}
                    
                    local j = i - 1
                    while j >= 1 and context.scoring_hand[j].config.center == G.P_CENTERS.m_fm_slow do
                        table.insert(cards_to_freeze, context.scoring_hande[j])
                        adjacent_slow = true
                        j = j - 1
                    end
                    
                    j = i + 1
                    while j <= #context.scoring_hand and context.scoring_hand[j].config.center == G.P_CENTERS.m_fm_slow do
                        table.insert(cards_to_freeze, context.scoring_hand[j])
                        adjacent_slow = true
                        j = j + 1
                    end
    
                    if adjacent_slow then
                        table.insert(cards_to_freeze, card)
                        for _, card_to_freeze in ipairs(cards_to_freeze) do
                            card_to_freeze:flip()
                            card_to_freeze:set_ability(G.P_CENTERS.m_fm_freeze, nil, true)
                            card_to_freeze.ability.extra = { times_returned = 0 }
                            card_eval_status_text(card_to_freeze, 'extra', nil, nil, nil, {
                                message = "Frozen!",
                                sound = "fm_freeze",
                                colour = G.C.SUITS.Spades
                            })
                            card_to_freeze:flip()
                        end
                    end
                    break
                end
            end
        end
    end
}

-- works
SMODS.Enhancement {
    key = "freeze",
    loc_txt = {
        name = "Freeze",
        text = {
            "{C:spades}STASIS{}",
            "Returns to hand up to {C:attention}#2#{} times.",
            "Cards of the same suit to the left",
            "become {C:spades}Slowed{}",
            "{C:inactive}(Currently {C:attention}#1#{C:inactive}/#2# returns)"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            times_returned = 0,
            max_returns = 2
        }
    },
    set_ability = function(self, card, initial)
        card.ability.extra.times_returned = 0
        card.ability.max_returns = card.ability.extra.max_returns or 2
    end,
    pos = {x=1, y=5},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.times_returned or 0, card.ability.extra.max_returns or 2 } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            for i, playedCard in ipairs(context.scoring_hand) do
                if playedCard == card then
                    if i > 1 then
                        local left_card = context.scoring_hand[i-1]
                        if left_card and left_card.base.suit == card.base.suit and left_card.ability.set ~= "Enhanced" then
                            left_card:flip()
                            left_card:set_ability(G.P_CENTERS.m_fm_slow, nil, true)
                            card.ability.extra = { frozen = false }
                            card_eval_status_text(left_card, 'extra', nil, nil, nil, {
                                message = "Slowed!",
                                sound = "fm_slow",
                                colour = G.C.SUITS.Spades
                            })
                            left_card:flip()
                        end
                    end
                    break
                end
            end
        end
    end
}

-- works
SMODS.Enhancement {
    key = "shatter",
    loc_txt = {
        name = "Shatter",
        text = {
            "{C:spades}STASIS{}",
            "Scoring {C:spades}Stasis{} cards grants",
            "{C:money}$3{} each to this card. Has a {C:green}#2# in #3#{}",
            "chance of being destroyed and granting {C:money}$#1#{}",
        }
    },
    atlas = 'Enhancements',
    shatters = true,
    config = {
        extra = {
            money = 0,
            denom = 4,
            destroy = true
        }
    },
    pos = {x=2, y=5},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money, G.GAME.probabilities.normal, card.ability.extra.denom }}
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.hand and context.main_scoring then
            for _, scoredCard in ipairs(context.scoring_hand) do
                if scoredCard.config.center == G.P_CENTERS.m_fm_slow or
                   scoredCard.config.center == G.P_CENTERS.m_fm_freeze or
                   scoredCard.config.center == G.P_CENTERS.m_fm_stasis_crystal or
                   scoredCard.config.center == G.P_CENTERS.m_fm_shatter then
                    card.ability.extra.money = card.ability.extra.money + 3
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Cracked!",
                        sound = "fm_cracked",
                        colour = G.C.SUITS.Spades
                    })
                end
            end
        end
    
        if context.destroying_card and context.destroy_card == card and pseudorandom('shatter') < G.GAME.probabilities.normal / card.ability.extra.denom then
            G.FM_SHATTERED_THIS_HAND = (G.FM_SHATTERED_THIS_HAND or 0) + 1
            local amount = card.ability.extra.money
            card.ability.extra.money = 0
            return {
                dollars = amount,
                message = 'Shattered!',
                sound = 'fm_shatter',
                colour = G.C.SUITS.Spades,
                remove = card.ability.extra.destroy,
            }  
        end
    end
}

SMODS.Enhancement {
    key = "stasis_crystal",
    loc_txt = {
        name = "Stasis Crystal",
        text = {
            "{C:spades}STASIS{}",
            "Scores {C:mult}+3{} Mult.",
            "Each {C:spades}Freeze{} card scored adds",
            "{C:mult}+5{} Mult to this card.",
            "Destroyed after {C:attention}3{} played hands.",
            "{C:inactive}({C:mult}#1#{C:inactive} hands left)",
            "{C:inactive}(Currently: {C:mult}+#2#{C:inactive} Mult)"
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    config = {
        extra = {
            stored_mult = 3,
            hands_remaining = 3
        }
    },
    pos = {x=3, y=5},
    overrides_base_rank = true,
    replace_base_card = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hands_remaining, card.ability.extra.stored_mult } }
    end,
    calculate = function(self, card, context)
        -- Check for Freeze cards
        if context.cardarea == G.hand and context.after then
            local freeze_count = 0
            for _, playedCard in ipairs(G.play.cards) do
                if playedCard.config.center == G.P_CENTERS.m_fm_freeze then
                    freeze_count = freeze_count + 1
                end
            end
           
            -- Decrement counter
            if card.ability.extra.hands_remaining > 0 then
                card.ability.extra.hands_remaining = card.ability.extra.hands_remaining - 1
            end
           
            -- Add bonus if Freeze cards present
            if freeze_count > 0 then
                card.ability.extra.stored_mult = card.ability.extra.stored_mult + (5 * freeze_count)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        return {
                            message = "Reinforced!",
                            sound = "fm_shatter",
                            colour = G.C.SUITS.Spades
                        }
                    end
                }))
            end
        end
        if context.cardarea == G.hand and context.main_scoring and card.ability.extra.hands_remaining <= 0 then
            local final_mult = card.ability.extra.stored_mult
            G.E_MANAGER:add_event(Event({
                func = function()
                    card:start_dissolve({G.C.SUITS.Spades})
                    return true
                end
            }))
            return {
                mult = final_mult,
                message = "Shattered!",
                sound = "fm_shatter",
                colour = G.C.SUITS.Spades
            }
        end
     
        -- Normal scoring when played
        if context.cardarea == G.play and context.main_scoring then
            local current_mult = card.ability.extra.stored_mult
            G.E_MANAGER:add_event(Event({
                func = function()
                    card:start_dissolve({G.C.SUITS.Spades})
                    return true
                end
            }))
            return {
                mult = current_mult,
                message = "Shattered!",
                sound = "fm_shatter",
                colour = G.C.SUITS.Spades
            }
        end
    end
}
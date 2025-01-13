-- works
SMODS.Enhancement {
    key = "slow",
    loc_txt = {
        name = "Slow",
        text = {
            "{C:spades}STASIS{}",
            "Has a {C:green}#1# in #2#{} chance of returning",
            "to hand after being played.",
            "Will {C:attention}Freeze{} when played",
            "with adjacent {C:attention}Slow{} cards"
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
                            card_to_freeze.config.center = G.P_CENTERS.m_fm_freeze
                            card_to_freeze.ability.extra = { times_returned = 0 }
                            card_eval_status_text(card_to_freeze, 'extra', nil, nil, nil, {
                                message = "Frozen!",
                                sound = "fm_freeze",
                                colour = G.C.SUITS.Spades
                            })
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
            "Returns to hand up to {C:attention}2{} times.",
            "Cards of the same suit to the left",
            "become {C:attention}Slowed{}",
            "{C:inactive}(Currently {C:attention}#1#{C:inactive}/2 returns)"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            times_returned = 0
        }
    },
    set_ability = function(self, card, initial)
        card.ability.extra.times_returned = 0
    end,
    pos = {x=1, y=5},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.times_returned or 0 } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            for i, playedCard in ipairs(context.scoring_hand) do
                if playedCard == card then
                    if i > 1 then
                        local left_card = context.scoring_hand[i-1]
                        if left_card and left_card.base.suit == card.base.suit and left_card.ability.set ~= "Enhanced" then
                            left_card:set_ability(G.P_CENTERS.m_fm_slow, nil, true)
                            card.ability.extra = { frozen = false }
                            card_eval_status_text(left_card, 'extra', nil, nil, nil, {
                                message = "Slowed!",
                                sound = "fm_slow",
                                colour = G.C.SUITS.Spades
                            })
                        end
                    end
                    break
                end
            end
        end
    end
}

-- I assume it works because I'm too lucky that it doesn't shatter
SMODS.Enhancement {
    key = "shatter",
    loc_txt = {
        name = "Shatter",
        text = {
            "{C:spades}STASIS{}",
            "Has a {C:green}#2# in #3#{} chance of being",
            "destroyed. Before destroyed,",
            "each scored {C:attention}Stasis{} card",
            "grants {C:money}$3{} while this card",
            "is in hand and unplayed",
            "{C:inactive}(Currently {C:money}$#1#{C:inactive})"
        }
    },
    atlas = 'Enhancements',
    shatters = true,
    config = {
        extra = {
            money = 0,
            denom = 4
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
    
        if context.destroying_card and pseudorandom('shatter') < G.GAME.probabilities.normal / card.ability.extra.denom then
            return {
                dollars = card.ability.extra.money,
                message = 'Shattered!',
                sound = 'fm_shatter',
                colour = G.C.SUITS.Spades,
            }  
        end
    end
}
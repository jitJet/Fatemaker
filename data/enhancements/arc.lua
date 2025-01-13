-- works
SMODS.Enhancement {
    key = "amplified",
    loc_txt = {
        name = "Amplified",
        text = {
            "{C:blue}ARC{}",
            "While in hand and not played once,",
            "gain {C:mult}+15{} Mult when scored",
            "{C:inactive}(Currently {C:attention}#1#{C:inactive}/1 hand)"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            hands_seen = 0,
            mult = 0
        }
    },
    pos = {x=0, y=4},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hands_seen } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.hand and context.after and not context.end_of_round
            and card.ability.extra.hands_seen < 1 then
            card.ability.extra.hands_seen = card.ability.extra.hands_seen + 1
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "Amplified!",
                sound = "fm_amplified", 
                colour = G.C.BLUE
            })
        end
        if context.cardarea == G.play and context.main_scoring then
            if card.ability.extra.hands_seen > 0 then
                card.ability.extra.hands_seen = 0
                return{
                    mult = 15
                }
            end
        end
    end
}

-- works
SMODS.Enhancement {
    key = "jolt",
    loc_txt = {
        name = "Jolt",
        text = {
            "{C:blue}ARC{}",
            "When not played, this card gains",
            "{C:chips}+20%{} chips on top of each",
            "unplayed card's chip worth and",
            "{C:mult}+5{} Mult for each one",
            "Bonuses applied when scored",
            "{C:inactive}(Currently {C:chips}+#1#{C:inactive} chips",
            "{C:inactive}and {C:mult}+#2#{C:inactive} Mult)"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            stored_chips = 0,
            stored_mult = 0
        }
    },
    pos = {x=1, y=4},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.stored_chips, card.ability.extra.stored_mult } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.hand and context.main_scoring and not context.before then
            local charged = card.ability.extra.stored_chips > 0
            local chips_bonus = 0
            local mult_bonus = 0
            
            for _, handCard in ipairs(G.hand.cards) do
                if handCard ~= card then
                    chips_bonus = chips_bonus + math.floor(handCard:get_id() * 1.2)
                    mult_bonus = mult_bonus + 5
                end
            end
            
            if chips_bonus > 0 and not charged then
                card.ability.extra.stored_chips = chips_bonus
                card.ability.extra.stored_mult = mult_bonus
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "Charged!",
                    sound = "fm_jolt",
                    colour = G.C.BLUE
                })
            end
        end
    
        if context.cardarea == G.play and context.main_scoring then
            if card.ability.extra.stored_chips > 0 or card.ability.extra.stored_mult > 0 then
                local return_value = {
                    chips = card.ability.extra.stored_chips,
                    mult = card.ability.extra.stored_mult
                }
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "Jolted!",
                    sound = "fm_jolt",
                    colour = G.C.BLUE
                })
                card.ability.extra.stored_chips = 0
                card.ability.extra.stored_mult = 0
                return return_value
            end
        end
    end
}

-- works
SMODS.Enhancement {
    key = "blinded",
    loc_txt = {
        name = "Blinded",
        text = {
            "{C:blue}ARC{}",
            "Card is drawn face down,",
            "but if scored, gain {X:mult,C:white}X3{} Mult"
        }
    },
    atlas = 'Enhancements',
    pos = {x=2, y=4},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            local return_value = {
                x_mult = 3
            }
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = "Unblinded!",
                sound = "fm_blind",
                colour = G.C.BLUE
            })
            return return_value
        end
    end
}
-- works
SMODS.Enhancement {
    key = "radiant",
    loc_txt = {
        name = "Radiant",
        text = {
            "{C:attention}SOLAR{}",
            "Grants {X:mult,C:white}X0.5{} Mult for",
            "each {C:attention}Solar{} card in",
            "hand or played",
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            x_mult = 1
        }
    },
    pos = {x=0, y=3},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            local solar_count = 0
            for _, handCard in ipairs(G.hand.cards) do
                if handCard.config.center_key == "m_fm_radiant" or
                   handCard.config.center_key == "m_fm_restoration" or 
                   handCard.config.center_key == "m_fm_scorch" then
                    solar_count = solar_count + 1
                end
            end
            
            for _, playedCard in ipairs(G.play.cards) do
                if playedCard.config.center_key == "m_fm_radiant" or
                   playedCard.config.center_key == "m_fm_restoration" or 
                   playedCard.config.center_key == "m_fm_scorch" then
                    solar_count = solar_count + 1
                end
            end
 
            if solar_count > 0 then
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "Radiant!",
                    sound = "fm_radiant",
                    colour = G.C.ORANGE
                })
                return{
                    x_mult = 1 + (0.5 * solar_count)
                }
            end
        end
    end
}

-- works
SMODS.Enhancement {
    key = "scorch",
    loc_txt = {
        name = "Scorch",
        text = {
            "{C:attention}SOLAR{}",
            "Scoring this card will increase",
            "{C:attention}Scorch{} stacks.",
            "At {C:attention}3{} stacks, {C:attention}it will ignite{},",
            "destroying it but granting {X:mult,C:white}X3{} Mult",
            "{C:inactive}(Currently {C:red}#1#{C:inactive} Stacks)"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            stacks = 0,
            x_mult = 1
        }
    },
    pos = {x=1, y=3},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.stacks } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            card.ability.extra.stacks = card.ability.extra.stacks + 1
            return {
                message = 'Scorched!',
                colour = G.C.ORANGE,
                sound = 'fm_scorch'
            }
        end
        if context.destroying_card and card.ability.extra.stacks == 3 then
            return {
                x_mult = 3,
                message = 'Ignited!',
                sound = 'fm_ignition',
                colour = G.C.ORANGE
            }
        end
    end
}

-- works
SMODS.Enhancement {
    key = "restoration",
    loc_txt = {
        name = "Restoration",
        text = {
            "{C:attention}SOLAR{}",
            "Card's rank increases by 1",
            "after each hand played",
            "Resets after playing"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            base_rank = 0,
            current_rank = 0,
            hands_seen = 0
        }
    },
    pos = {x=2, y=3},
    calculate = function(self, card, context)
        if context.cardarea == G.hand and context.after and not context.end_of_round then
            if card.ability.extra.base_rank == 0 then
                card.ability.extra.base_rank = card:get_id()
                card.ability.extra.current_rank = card:get_id()
            end
            card.ability.extra.current_rank = math.min(card.ability.extra.current_rank + 1, 14)
            local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
            local rank_suffix = card.ability.extra.current_rank < 10 and tostring(card.ability.extra.current_rank)
                or card.ability.extra.current_rank == 10 and 'T'
                or card.ability.extra.current_rank == 11 and 'J'
                or card.ability.extra.current_rank == 12 and 'Q'
                or card.ability.extra.current_rank == 13 and 'K'
                or 'A'
            card:flip()
            SMODS.calculate_effect({
                message = "Rank Up!",
                sound = "fm_restoration",
                colour = G.C.ORANGE
            }, card)
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.3,
                func = function()
                    card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                    card:flip()
                    return true
                end
            }))
        end
 
        if context.cardarea == G.play and context.main_scoring then
            local original_rank = card.ability.extra.base_rank
            return {
                func = function()
                    local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                    local rank_suffix = original_rank < 10 and tostring(original_rank)
                        or original_rank == 10 and 'T'
                        or original_rank == 11 and 'J'
                        or original_rank == 12 and 'Q'
                        or original_rank == 13 and 'K'
                        or 'A'
                    card:flip()
                    SMODS.calculate_effect({
                        message = "Reset!",
                        sound = "fm_restoration",
                        colour = G.C.ORANGE
                    }, card)
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        func = function()
                            card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                            card.ability.extra.current_rank = original_rank
                            card:flip()
                            return true
                        end
                    }))
                end
            }
        end
    end
}
-- works
SMODS.Enhancement {
    key = "radiant",
    loc_txt = {
        name = "Radiant",
        text = {
            "{C:attention}SOLAR{}",
            "Grants {X:mult,C:white}X0.2{} Mult for",
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
                   handCard.config.center_key == "m_fm_scorch" or
                   handCard.config.center_key == "m_fm_cure" then
                    solar_count = solar_count + 1
                end
            end
            
            for _, playedCard in ipairs(G.play.cards) do
                if playedCard.config.center_key == "m_fm_radiant" or
                   playedCard.config.center_key == "m_fm_restoration" or 
                   playedCard.config.center_key == "m_fm_scorch" or
                   playedCard.config.center_key == "m_fm_cure" then
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
                    x_mult = 1 + (0.2 * solar_count)
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
            stacks = 0
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
        if context.destroy_card and context.destroy_card == card and card.ability.extra.stacks >= 3 then
            return {
                xmult = 3,
                message = 'Ignited!',
                sound = 'fm_ignition',
                colour = G.C.ORANGE,
                remove = true
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
            "When in hand,",
            "adjacent cards to it",
            "will rank up if they",
            "share the same suit"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            rank_increase = 0
        }
    },
    pos = {x=2, y=3},
    calculate = function(self, card, context)
        if context.final_scoring_step and context.cardarea == G.hand then
            for i, handCard in ipairs(G.hand.cards) do
                if handCard == card then
                    if i > 1 and G.hand.cards[i-1].base.suit == card.base.suit then
                        local leftCard = G.hand.cards[i-1]
                        local current_rank = leftCard.base.value
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
                        
                        if next_rank then
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    if leftCard.area == G.hand then
                                        leftCard:flip()
                                        SMODS.change_base(leftCard, leftCard.base.suit, next_rank)
                                        leftCard:flip()
                                        SMODS.calculate_effect({
                                            message = "Rank Up!",
                                            sound = "fm_restoration",
                                            colour = G.C.ORANGE
                                        }, leftCard)
                                    end
                                    return true
                                end
                            }))
                        end
                    end

                    if i < #G.hand.cards and G.hand.cards[i+1].base.suit == card.base.suit then
                        local rightCard = G.hand.cards[i+1]
                        local current_rank = rightCard.base.value
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
                        if next_rank then
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    if rightCard.area == G.hand then
                                        rightCard:flip()
                                        SMODS.change_base(rightCard, rightCard.base.suit, next_rank)
                                        rightCard:flip()
                                        SMODS.calculate_effect({
                                            message = "Rank Up!",
                                            sound = "fm_restoration",
                                            colour = G.C.ORANGE
                                        }, rightCard)
                                    end
                                    return true
                                end
                            }))
                        end
                    end
                    break
                end
            end
        end
    end
}

SMODS.Enhancement {
    key = "cure",
    loc_txt = {
        name = "Cure",
        text = {
            "{C:attention}SOLAR{}",
            "Each {C:attention}Cure{} card scored in the same hand",
            "will incrementally grant {C:blue}+30{} chips"
        }
    },
    atlas = 'Enhancements',
    pos = {x=1, y=7},
    config = {
        extra = { chips = 0 }
    },
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            local cure_count = 0
            for _, scoringCard in ipairs(context.scoring_hand) do
                if scoringCard.config.center_key == "m_fm_cure" then
                    cure_count = cure_count + 1
                end
            end
            if cure_count > 0 then
                card.ability.extra.chips = card.ability.extra.chips + (30 * cure_count)
                return {
                    chips = card.ability.extra.chips,
                    message = "Cured!",
                    -- sound = "fm_cure",
                    colour = G.C.ORANGE
                }
            end
        end
    end
}
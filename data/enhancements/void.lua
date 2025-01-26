-- works
SMODS.Enhancement {
    key = "overshield",
    loc_txt = {
        name = "Overshield",
        text = {
            "{C:purple}VOID{}",
            "When discarded,",
            "remove all {C:attention}debuffs{}",
            "from the current hand"
        }
    },
    atlas = 'Enhancements',
    pos = {x=0, y=1},
    calculate = function(self, card, context)
        if context.pre_discard then
            if table.contains(context.full_hand, card) then
                for _, handCard in ipairs(G.hand.cards) do
                    if handCard.debuff then
                        SMODS.calculate_effect({
                            message = "Protected!",
                            sound = "fm_overshield",
                            colour = G.C.PURPLE,
                            card = card
                        }, handCard)
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.2,
                            func = function ()
                                handCard.debuff = nil
                                return true
                            end
                        }))
                    end
                end
            end
            return {effect = true}
        end
    end
}

-- works
SMODS.Enhancement {
    key = "devour",
    loc_txt = {
        name = "Devour",
        text = {
            "{C:purple}VOID{}",
            "Discarding cards adjacent",
            "to it will grant {C:mult}+3{} Mult",
            "Resets when played",
            "{C:inactive}(Currently {C:red}+#1#{C:inactive} Mult)"
        }
    },
    atlas = 'Enhancements',
    config = { extra = { mult = 0 } },
    pos = {x=1, y=1},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.pre_discard then
            for i, handCard in ipairs(G.hand.cards) do
                if handCard == card then
                    local bonus = 0
                    if i > 1 and table.contains(context.full_hand, G.hand.cards[i-1]) then
                        bonus = bonus + 3
                    end
                    if i < #G.hand.cards and table.contains(context.full_hand, G.hand.cards[i+1]) then
                        bonus = bonus + 3
                    end
                    if bonus > 0 and card.ability.extra.mult then
                        card_eval_status_text(card, 'extra', nil, nil, nil,
                            {
                                message = "Devoured!",
                                sound = "fm_devour",
                                colour = G.C.PURPLE
                            }
                        )
                        card.ability.extra.mult = card.ability.extra.mult + bonus
                    end
                    break
                end
            end
        end

        if context.cardarea == G.play and context.main_scoring then
            if card.ability.extra.mult > 0 then
                local return_value = {
                    mult = card.ability.extra.mult
                }
                card.ability.extra.mult = 0
                return return_value
            end
        end
    end
}

-- works
SMODS.Enhancement {
    key = "volatile",
    loc_txt = {
        name = "Volatile",
        text = {
            "{C:purple}VOID{}",
            "When discarded with other cards,",
            "gain {C:mult}additional Mult{} equal to",
            "their combined ranks.",
            "When scored, this card",
            "is {C:attention}destroyed{}",
            "{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = { mult = 0 }
    },
    pos = {x=2, y=1},
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.pre_discard then
            if table.contains(context.full_hand, card) then
                local rank_sum = 0
                for _, discarded_card in ipairs(context.full_hand) do
                    if discarded_card ~= card then
                        rank_sum = rank_sum + discarded_card:get_id()
                    end
                end
                
                if rank_sum > 0 then
                    card.ability.extra.mult = rank_sum
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Primed!",
                        sound = "fm_primed",
                        colour = G.C.PURPLE
                    })
                end
            end
        end

        if context.cardarea == G.play and context.main_scoring then
            return {
                mult = card.ability.extra.mult
            }
        end
        if context.destroying_card and card.ability.extra.mult > 0 then
            -- local voidParticles = {}
            -- for i = 1, 2 do
            --     voidParticles[i] = Particles(1, 1, 0, 0, {
            --         timer = 0.05,
            --         scale = 0.3 * i,
            --         initialize = true,
            --         lifespan = 1,
            --         speed = 4 * i,
            --         padding = -1,
            --         attach = G.hand.highlighted[1],
            --         colours = {G.C.WHITE, lighten(G.C.PURPLE, 0.5)},
            --         fill = true,
            --     })
            -- end
            -- G.E_MANAGER:add_event(Event({
            --     trigger = 'after',
            --     delay = 0.1,
            --     func = function ()
            --         for i = 1, #voidParticles do
            --             voidParticles[i].fade_alpha = 0
            --             voidParticles[i]:fade(0.3, 1)
            --         end
            --         return true
            --     end
            -- }))
            return {
                message = 'Blasted!',
                sound = 'fm_volatile',
                colour = G.C.PURPLE
            }
        end
    end
}
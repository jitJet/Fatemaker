-- Scores its original rank's worth of chips, and then scores adjacent cards worth of chips with the highest rank amongst them
SMODS.Enhancement {
    key = "tangle",
    loc_txt = {
        name = "Tangle",
        text = {
            "{C:green}STRAND{}",
            "When scored with adjacent cards,",
            "this rank will score the number of chips",
            "of the highest rank amongst them and multiplied",
            "by the number of adjacent cards"
        }
    },
    atlas = 'Enhancements',
    config = {
        chips = 0
    },
    pos = {x=0, y=0},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            local left_card, right_card
            for i, playedCard in ipairs(context.scoring_hand) do
                if playedCard == card then
                    if i > 1 and context.scoring_hand[i-1] then
                        left_card = context.scoring_hand[i-1]
                    end
                    if i < #context.scoring_hand and context.scoring_hand[i+1] then
                        right_card = context.scoring_hand[i+1]
                    end
                    break
                end
            end
            local card_count = 1
            local highest_rank = card:get_id()
            
            if left_card then
                card_count = card_count + 1
                highest_rank = math.max(highest_rank, left_card:get_id())
            end
            if right_card then
                card_count = card_count + 1
                highest_rank = math.max(highest_rank, right_card:get_id())
            end
    
            if card_count > 1 then
                card_eval_status_text(card, 'extra', nil, nil, nil, 
                    {
                        message = "Tangled!",
                        sound = "fm_tangle",
                        colour = G.C.GREEN
                })
                return{
                    chips = highest_rank * card_count
                }
            end
        end
    end
}

-- works
SMODS.Enhancement {
    key = "wovenmail",
    loc_txt = {
        name = "Woven Mail",
        text = {
            "{C:green}STRAND{}",
            "Immune to {C:attention}debuffs{}",
            "Adjacent cards with a lower rank than this",
            "score {C:blue}+75{} chips"
        }
    },
    atlas = 'Enhancements',
    pos = {x=1, y=0},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            -- Find this card's position in the scoring hand
            local bonus = 0
            for i, playedCard in ipairs(context.scoring_hand) do
                if playedCard == card then
                    local my_rank = card:get_id()
                    -- Check left
                    if i > 1 then
                        local left = context.scoring_hand[i-1]
                        if left:get_id() < my_rank then
                            bonus = bonus + 75
                        end
                    end
                    -- Check right
                    if i < #context.scoring_hand then
                        local right = context.scoring_hand[i+1]
                        if right:get_id() < my_rank then
                            bonus = bonus + 75
                        end
                    end
                end
                if bonus > 0 then
                    return { 
                        message = 'Woven!',
                        sound = 'fm_wovenmail',
                        colour = G.C.GREEN,
                        chips = bonus
                    }
                end
            end
        end
    end
}

-- works
SMODS.Enhancement {
    key = "unravel",
    loc_txt = {
        name = "Unravel",
        text = {
            "{C:green}STRAND{}",
            "Each hand played stores {C:attention}#4#{} Thread(s)",
            "Has a {C:green}#2# in #3#{} chance of breaking",
            "Once broken, 3 unplayed cards with the lowest ranks",
            "will increase in rank by number of",
            "stored Threads",
            "{C:inactive}(Currently {C:attention}#1#{C:inactive} Threads stored)"
        }
    },
    atlas = 'Enhancements',
    pos = {x=2, y=0},
    shatters = true,
    config = {
        extra = {
            threads = 0,
            rank_boost = 0,
            denom = 4,
            threads_per_hand = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.threads, G.GAME.probabilities.normal, card.ability.extra.denom, card.ability.extra.threads_per_hand or 1 } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            card.ability.extra.threads = card.ability.extra.threads + (card.ability.extra.threads_per_hand or 1)
            return {
                message = 'Threaded!',
                sound = 'fm_threaded',
                colour = G.C.GREEN
            }
        end
   
        if context.destroying_card and pseudorandom('unravel') < G.GAME.probabilities.normal / card.ability.extra.denom then
            local lowest_cards = {}
            for _, handCard in ipairs(G.hand.cards) do
                table.insert(lowest_cards, handCard)
            end
            table.sort(lowest_cards, function(a, b) return a:get_id() < b:get_id() end)
   
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.3,
                func = function()
                    for i = 1, math.min(3, #lowest_cards) do
                        local handCard = lowest_cards[i]
                        handCard:flip()
                        SMODS.calculate_effect({
                            message = string.format("+%d Rank!", card.ability.extra.threads),
                            sound = "fm_unravel",
                            colour = G.C.GREEN
                        }, handCard)
                       
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.2,
                            func = function()
                                local current_rank = handCard.base.value
                                local num_steps = card.ability.extra.threads
                                
                                local current_index = nil
                                for idx, rank_key in ipairs(SMODS.Rank.obj_buffer) do
                                    if rank_key == current_rank then
                                        current_index = idx
                                        break
                                    end
                                end
                                
                                if current_index then
                                    local new_index = math.min(current_index + num_steps, #SMODS.Rank.obj_buffer)
                                    local new_rank = SMODS.Rank.obj_buffer[new_index]
                                    
                                    SMODS.change_base(handCard, handCard.base.suit, new_rank)
                                end
                                
                                handCard:flip()
                                return true
                            end
                        }))
                    end
                    return true
                end
            }))
           
            return {
                message = 'Unraveled!',
                sound = 'fm_unravel',
                colour = G.C.GREEN
            }
        end
    end
}

SMODS.Enhancement {
    key = "suspend",
    loc_txt = {
        name = "Suspend",
        text = {
            "{C:green}STRAND{}",
            "{C:red}Forcibly selected{} after two played hands",
            "For each {C:green}Strand{} card scored before it,",
            "gain {C:mult}+10{} Mult each",
        }
    },
    atlas = 'Enhancements',
    pos = {x=3, y=7},
    calculate = function(self, card, context)
        
    end
}
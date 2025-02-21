SMODS.Blind{
    key = "corrupted_wish",
    loc_txt = {
        name = "Corrupted Wish",
        text = {
            "Grant yourself freedom,",
            "o' jester mine."
        }
    },
    dollars = 8,
    mult = 3,
    boss = {
        showdown = true
    },
    boss_colour = HEX('4B0082'),
    atlas = 'Blinds',
    pos = {x = 0, y = 0},
    hands = {
        ["Pair"] = true,
        ["Two Pair"] = true,
        ["Three of a Kind"] = true,
        ["Full House"] = true,
        ["Four of a Kind"] = true,
        ["Five of a Kind"] = true,
        ["Straight"] = true,
        ["Flush"] = true,
        ["Straight Flush"] = true,
        ["Royal Flush"] = true,
        ["Flush Five"] = true,
        ["Flush House"] = true,
        ["High Card"] = false
    },

    set_blind = function(self, reset, silent)
        ease_hands_played(15)
        ease_discard(15)
        G.hand:change_size(5)

        local wish_centers = {
            G.P_CENTERS.m_fm_diving_bird,
            G.P_CENTERS.m_fm_flying_bird,
            G.P_CENTERS.m_fm_envious_bird,
            G.P_CENTERS.m_fm_spear_dragon,
            G.P_CENTERS.m_fm_slain_dragon,
            G.P_CENTERS.m_fm_fire_dragon,
            G.P_CENTERS.m_fm_infinity_snake,
            G.P_CENTERS.m_fm_twin_headed_snake,
            G.P_CENTERS.m_fm_conjoined_snakes,
            G.P_CENTERS.m_fm_arching_fish,
            G.P_CENTERS.m_fm_hiding_fish,
            G.P_CENTERS.m_fm_circling_fish
        }
        
        for _, center in ipairs(wish_centers) do
            for i = 1, 4 do
                local front = pseudorandom_element(G.P_CARDS, pseudoseed('bl_wish'))
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local card = Card(G.play.T.x + G.play.T.w / 2, G.play.T.y, G.CARD_W, G.CARD_H, front, center, {
                    playing_card = G.playing_card
                })
            
                card:start_materialize({G.C.SECONDARY_SET.Enhanced})
                G.play:emplace(card)
                table.insert(G.playing_cards, card)
            
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                draw_card(G.play, G.deck, 90, 'up', nil)
            end
        end
    end,

    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
        local wish_sequence = {}
        
        for i = 1, #cards do
            local center = cards[i].config.center
            if center == G.P_CENTERS.m_fm_diving_bird or
               center == G.P_CENTERS.m_fm_flying_bird or
               center == G.P_CENTERS.m_fm_envious_bird or
               center == G.P_CENTERS.m_fm_spear_dragon or
               center == G.P_CENTERS.m_fm_slain_dragon or
               center == G.P_CENTERS.m_fm_fire_dragon or
               center == G.P_CENTERS.m_fm_infinity_snake or
               center == G.P_CENTERS.m_fm_twin_headed_snake or
               center == G.P_CENTERS.m_fm_conjoined_snakes or
               center == G.P_CENTERS.m_fm_arching_fish or
               center == G.P_CENTERS.m_fm_hiding_fish or
               center == G.P_CENTERS.m_fm_circling_fish then
                table.insert(wish_sequence, center)
            end
        end
    
        if #wish_sequence == 3 then
            local w1, w2, w3 = wish_sequence[1], wish_sequence[2], wish_sequence[3]
            
            -- Flips 4 cards
            if w1 == G.P_CENTERS.m_fm_diving_bird and 
                w2 == G.P_CENTERS.m_fm_diving_bird and 
                w3 == G.P_CENTERS.m_fm_diving_bird and 
                self.hands["Pair"] then
                    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
                    self.hands["Pair"] = false
                    self:show_unlock_message("Pair")
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 5,
                        func = function() 
                            local available_cards = {}
                            for _, card in ipairs(G.hand.cards) do
                                if card.facing == 'front' then
                                    table.insert(available_cards, card)
                                end
                            end
                            
                            for i = 1, math.min(4, #available_cards) do
                                local card, card_index = pseudorandom_element(available_cards, pseudoseed('wish_flip'))
                                SMODS.calculate_effect({
                                    message = ("Taken!"),
                                    sound = "fm_corrupted_wish_taken",
                                    colour = G.C.BLACK
                                }, card)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        card:flip()
                                        return true
                                    end
                                }))
                                table.remove(available_cards, card_index)
                            end
                            return true
                        end
                    }))
            
            -- Flips 8 cards
            elseif w1 == G.P_CENTERS.m_fm_flying_bird and 
                w2 == G.P_CENTERS.m_fm_flying_bird and 
                w3 == G.P_CENTERS.m_fm_diving_bird and 
                self.hands["Two Pair"] then
                    self.hands["Two Pair"] = false
                    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
                    self:show_unlock_message("Two Pair")
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 5,
                        func = function() 
                            local available_cards = {}
                            for _, card in ipairs(G.hand.cards) do
                                if card.facing == 'front' then
                                    table.insert(available_cards, card)
                                end
                            end
                            
                            for i = 1, math.min(8, #available_cards) do
                                local card, card_index = pseudorandom_element(available_cards, pseudoseed('wish_flip'))
                                SMODS.calculate_effect({
                                    message = ("Taken!"),
                                    sound = "fm_corrupted_wish_taken",
                                    colour = G.C.BLACK
                                }, card)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        card:flip()
                                        return true
                                    end
                                }))
                                table.remove(available_cards, card_index)
                            end
                            return true
                        end
                    }))
            
            -- Debuffs 3 cards
            elseif w1 == G.P_CENTERS.m_fm_spear_dragon and 
                w2 == G.P_CENTERS.m_fm_twin_headed_snake and 
                w3 == G.P_CENTERS.m_fm_twin_headed_snake and 
                self.hands["Three of a Kind"] then
                    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
                    self.hands["Three of a Kind"] = false
                    self:show_unlock_message("Three of a Kind")
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 5,
                        func = function() 
                            local available_cards = {}
                            for _, card in ipairs(G.hand.cards) do
                                if not card.debuff then
                                    table.insert(available_cards, card)
                                end
                            end
                            
                            for i = 1, math.min(3, #available_cards) do
                                local card, card_index = pseudorandom_element(available_cards, pseudoseed('wish_debuff'))
                                SMODS.calculate_effect({
                                    message = ("Taken!"),
                                    sound = "fm_corrupted_wish_taken",
                                    colour = G.C.BLACK
                                }, card)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        card:set_debuff(true)
                                        return true
                                    end
                                }))
                                table.remove(available_cards, card_index)
                            end
                            return true
                        end
                    }))
            
            -- Destroys 4 cards
            elseif w1 == G.P_CENTERS.m_fm_slain_dragon and 
                w2 == G.P_CENTERS.m_fm_diving_bird and 
                w3 == G.P_CENTERS.m_fm_diving_bird and 
                self.hands["Four of a Kind"] then
                    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
                    self.hands["Four of a Kind"] = false
                    self:show_unlock_message("Four of a Kind")
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 5,
                        func = function() 
                            local available_cards = {}
                            for _, card in ipairs(G.hand.cards) do
                                table.insert(available_cards, card)
                            end
                            
                            for i = 1, math.min(4, #available_cards) do
                                local card, card_index = pseudorandom_element(available_cards, pseudoseed('wish_destroy'))
                                SMODS.calculate_effect({
                                    message = ("Taken!"),
                                    sound = "fm_corrupted_wish_taken",
                                    colour = G.C.BLACK
                                }, card)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        card:start_dissolve()
                                        return true
                                    end
                                }))
                                table.remove(available_cards, card_index)
                            end
                            return true
                        end
                    }))
            
            -- Destroys 1 Joker
            elseif w1 == G.P_CENTERS.m_fm_arching_fish and 
                w2 == G.P_CENTERS.m_fm_twin_headed_snake and 
                w3 == G.P_CENTERS.m_fm_twin_headed_snake and 
                self.hands["Five of a Kind"] then
                    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
                    self.hands["Five of a Kind"] = false
                    self:show_unlock_message("Five of a Kind")
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 5,
                        func = function() 
                            local available_jokers = {}
                            for _, joker in ipairs(G.jokers.cards) do
                                if not joker.ability.eternal then
                                    table.insert(available_jokers, joker)
                                end
                            end
                            
                            if #available_jokers > 0 then
                                local joker, joker_index = pseudorandom_element(available_jokers, pseudoseed('wish_joker_destroy'))
                                SMODS.calculate_effect({
                                    message = ("Taken!"),
                                    sound = "fm_corrupted_wish_taken",
                                    colour = G.C.BLACK
                                }, joker)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        joker.start_dissolve()
                                        return true
                                    end
                                }))
                            end
                            return true
                        end
                    }))
            
            -- Discards 5 cards
            elseif w1 == G.P_CENTERS.m_fm_infinity_snake and 
                w2 == G.P_CENTERS.m_fm_spear_dragon and 
                w3 == G.P_CENTERS.m_fm_spear_dragon and 
                self.hands["Straight"] then
                    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
                    self.hands["Straight"] = false
                    self:show_unlock_message("Straight")
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 5,
                        func = function() 
                            local available_cards = {}
                            for _, card in ipairs(G.hand.cards) do
                                table.insert(available_cards, card)
                            end
                            
                            for i = 1, math.min(5, #available_cards) do
                                local card, card_index = pseudorandom_element(available_cards, pseudoseed('wish_discard'))
                                SMODS.calculate_effect({
                                    message = ("Taken!"),
                                    sound = "fm_corrupted_wish_taken",
                                    colour = G.C.BLACK
                                }, card)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        draw_card(G.hand, G.discard, 90, 'down', false, card)
                                        return true
                                    end
                                }))
                                table.remove(available_cards, card_index)
                            end
                            return true
                        end
                    }))
            
            -- Debuffs a Joker
            elseif w1 == G.P_CENTERS.m_fm_spear_dragon and 
                w2 == G.P_CENTERS.m_fm_spear_dragon and 
                w3 == G.P_CENTERS.m_fm_hiding_fish and 
                self.hands["Flush"] then
                    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
                    self.hands["Flush"] = false
                    self:show_unlock_message("Flush")
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 5,
                        func = function() 
                            local available_jokers = {}
                            for _, joker in ipairs(G.jokers.cards) do
                                if not joker.debuff then
                                    table.insert(available_jokers, joker)
                                end
                            end
                            
                            if #available_jokers > 0 then
                                local joker, joker_index = pseudorandom_element(available_jokers, pseudoseed('wish_joker_debuff'))
                                SMODS.calculate_effect({
                                    message = ("Taken!"),
                                    sound = "fm_corrupted_wish_taken",
                                    colour = G.C.BLACK
                                }, joker)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        joker:set_debuff(true)
                                        return true
                                    end
                                }))
                            end
                            return true
                        end
                    }))
            
            -- Debuffs 5 random cards
            elseif w1 == G.P_CENTERS.m_fm_twin_headed_snake and 
                w2 == G.P_CENTERS.m_fm_hiding_fish and 
                w3 == G.P_CENTERS.m_fm_hiding_fish and 
                self.hands["Full House"] then
                    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
                    self.hands["Full House"] = false
                    self:show_unlock_message("Full House")
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 5,
                        func = function() 
                            local available_cards = {}
                            for _, card in ipairs(G.hand.cards) do
                                if not card.debuff then
                                    table.insert(available_cards, card)
                                end
                            end
                            
                            for i = 1, math.min(5, #available_cards) do
                                local card, card_index = pseudorandom_element(available_cards, pseudoseed('wish_debuff'))
                                SMODS.calculate_effect({
                                    message = ("Taken!"),
                                    sound = "fm_corrupted_wish_taken",
                                    colour = G.C.BLACK
                                }, card)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        card:set_debuff(true)
                                        return true
                                    end
                                }))
                                table.remove(available_cards, card_index)
                            end
                            return true
                        end
                    }))
            
            -- Destroys all cards of the same suit
            elseif w1 == G.P_CENTERS.m_fm_envious_bird and 
                w2 == G.P_CENTERS.m_fm_slain_dragon and 
                w3 == G.P_CENTERS.m_fm_fire_dragon and 
                self.hands["Flush Five"] then
                    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
                    self.hands["Flush Five"] = false
                    self:show_unlock_message("Flush Five")
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 5,
                        func = function() 
                            local target_suit = pseudorandom_element(G.hand.cards, pseudoseed('wish_suit')).base.suit
                            for _, card in ipairs(G.hand.cards) do
                                if card.base.suit == target_suit then
                                    SMODS.calculate_effect({
                                        message = ("Taken!"),
                                        sound = "fm_corrupted_wish_taken",
                                        colour = G.C.BLACK
                                    }, card)
                                    G.E_MANAGER:add_event(Event({
                                        func = function()
                                            card:start_dissolve()
                                            return true
                                        end
                                    }))
                                end
                            end
                            return true
                        end
                    }))
            
            -- Discards all enhanced cards
            elseif w1 == G.P_CENTERS.m_fm_twin_headed_snake and 
                w2 == G.P_CENTERS.m_fm_fire_dragon and 
                w3 == G.P_CENTERS.m_fm_slain_dragon and 
                self.hands["Flush House"] then
                    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
                    self.hands["Flush House"] = false
                    self:show_unlock_message("Flush House")
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 5,
                        func = function() 
                            for _, card in ipairs(G.hand.cards) do
                                if card.config.center and card.ability.set == "Enhanced" then
                                    SMODS.calculate_effect({
                                        message = ("Taken!"),
                                        sound = "fm_corrupted_wish_taken",
                                        colour = G.C.BLACK
                                    }, card)
                                    G.E_MANAGER:add_event(Event({
                                        func = function()
                                            draw_card(G.hand, G.discard, 90, 'down', false, card)
                                            return true
                                        end
                                    }))
                                end
                            end
                            return true
                        end
                    }))
            
            -- Debuffs two random Jokers
            elseif w1 == G.P_CENTERS.m_fm_infinity_snake and 
                w2 == G.P_CENTERS.m_fm_infinity_snake and 
                w3 == G.P_CENTERS.m_fm_conjoined_snakes and 
                self.hands["Straight Flush"] then
                    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
                    self.hands["Straight Flush"] = false
                    self:show_unlock_message("Straight Flush")
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 5,
                        func = function() 
                            local available_jokers = {}
                            for _, joker in ipairs(G.jokers.cards) do
                                if not joker.debuff then
                                    table.insert(available_jokers, joker)
                                end
                            end
                            
                            for i = 1, math.min(2, #available_jokers) do
                                local joker, joker_index = pseudorandom_element(available_jokers, pseudoseed('wish_joker_debuff'))
                                SMODS.calculate_effect({
                                    message = ("Taken!"),
                                    sound = "fm_corrupted_wish_taken",
                                    colour = G.C.BLACK
                                }, joker)
                                G.E_MANAGER:add_event(Event({
                                    func = function()
                                        joker:set_debuff(true)
                                        return true
                                    end
                                }))
                                table.remove(available_jokers, joker_index)
                            end
                            return true
                        end
                    }))
            
            -- Destroys all face cards
            elseif w1 == G.P_CENTERS.m_fm_circling_fish and 
                w2 == G.P_CENTERS.m_fm_arching_fish and 
                w3 == G.P_CENTERS.m_fm_diving_bird and 
                self.hands["Royal Flush"] then
                    ease_background_colour{new_colour = G.C.BLACK, contrast = 1}
                    self.hands["Royal Flush"] = false
                    self:show_unlock_message("Royal Flush")
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 5,
                        func = function() 
                            for _, card in ipairs(G.hand.cards) do
                                if card.base.id >= 11 then
                                    SMODS.calculate_effect({
                                        message = ("Taken!"),
                                        sound = "fm_corrupted_wish_taken",
                                        colour = G.C.BLACK
                                    }, card)
                                    G.E_MANAGER:add_event(Event({
                                        func = function()
                                            card:start_dissolve()
                                            return true
                                        end
                                    }))
                                end
                            end
                            return true
                        end
                    }))
            end
        end
        return mult, hand_chips, true
    end,

    show_unlock_message = function(self, hand_type)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                attention_text({
                    text = hand_type .. " Unlocked",
                    scale = 1.3,
                    hold = 5,
                    major = G.play,
                    backdrop_colour = G.C.SECONDARY_SET.Tarot
                })
                play_sound("fm_corrupted_wish_wish_granted")
                G.play:juice_up(0.1, 0.2)
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    func = function() 
                        attention_text({
                            text = "Your wish brings consequences, o' victim mine.",
                            scale = 0.5,
                            hold = 25,
                            offset = {x = 0,y = -2.7},
                            major = G.play,
                        })
                        return true
                    end
                }))
                return true
            end
        }))
    end,

    debuff_hand = function(self, cards, hand, handname, check)
        return self.hands[handname]
    end,

    defeat = function(self)
        G.hand:change_size(-5)     
        for i = #G.deck.cards, 1, -1 do
            if G.deck.cards[i].config.center == G.P_CENTERS.m_fm_diving_bird or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_flying_bird or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_envious_bird or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_spear_dragon or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_slain_dragon or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_fire_dragon or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_infinity_snake or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_twin_headed_snake or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_conjoined_snakes or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_arching_fish or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_hiding_fish or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_circling_fish then
                G.deck.cards[i]:start_dissolve({G.C.PURPLE})
            end
        end
    end
}

---------------------- BLIND-SPECIFIC CARDS -------------------------------------

SMODS.Enhancement {
    key = "diving_bird",
    loc_txt = {
        name = "Diving Bird",
        text = {
            "{X:dark_edition,C:white}WISH{}",
            "A wish for easy prey.",
            "A tale of three birds who dove,",
            "Out to the steep waters,",
            "In search of prey, greedily and deep,",
            "But only a pair returned unscathed."
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function(self)
        return false
    end,
    overrides_base_rank = true,
    replace_base_card = true,
    pos = {x=3, y=0}
}

SMODS.Enhancement {
    key = "flying_bird",
    loc_txt = {
        name = "Flying Bird",
        text = {
            "{X:dark_edition,C:white}WISH{}",
            "A wish to reach the heavens.",
            "A battle for dominance.",
            "Two aloft, fighting for the one who descends.",
            "An intruder. Another dive swoops past, seemingly invisible.",
            "In the sky, two pairs lashed out in bloody battle."
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function(self)
        return false
    end,
    overrides_base_rank = true,
    replace_base_card = true,
    pos = {x=4, y=0}
}

SMODS.Enhancement {
    key = "envious_bird",
    loc_txt = {
        name = "Envious Bird",
        text = {
            "{X:dark_edition,C:white}WISH{}",
            "A wish to fulfill all wants.",
            "A desire to become a beast majestic.",
            "It sees two dragons soaring through the air,",
            "Its eyes seething with envy, but quickly replaced,",
            "As the first dragon was slain, the second roared.",
            "It witnesses five more slain by commoners,",
            "All fell to the ground in a uniform manner."
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function(self)
        return false
    end,
    overrides_base_rank = true,
    replace_base_card = true,
    pos = {x=3, y=1}
}

SMODS.Enhancement {
    key = "spear_dragon",
    loc_txt = {
        name = "Spear Dragon",
        text = {
            "{X:dark_edition,C:white}WISH{}",
            "A wish to be valiant and brave.",
            "A tale of leading, growing in power and mutualism.",
            "A mighty beast raises its spear, rallying stragglers.",
            "Twin serpents coiled around the spear,",
            "And they found a triplication in strength."
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function(self)
        return false
    end,
    overrides_base_rank = true,
    replace_base_card = true,
    pos = {x=5, y=0}
}

SMODS.Enhancement {
    key = "slain_dragon",
    loc_txt = {
        name = "Slain Dragon",
        text = {
            "{X:dark_edition,C:white}WISH{}",
            "A wish to be sacrificed without vain.",
            "A beast who died for a greater good.",
            "Two carnivorous birds, dove headfirst,",
            "Seeking to turn the predator into prey",
            "Splitting the beast into foul and even quarters."
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function(self)
        return false
    end,
    overrides_base_rank = true,
    replace_base_card = true,
    pos = {x=6, y=0}
}

SMODS.Enhancement {
    key = "fire_dragon",
    loc_txt = {
        name = "Fire Dragon",
        text = {
            "{X:dark_edition,C:white}WISH{}",
            "A wish for destruction and chaos.",
            "'What dost thou seek? Speak truth or be vanquished.'",
            "A two-headed snake spat. Two equal yet great beasts thought long.",
            "One sought destruction. The other desired a kingdom.",
            "'Speak to mine heart, and thou wish shalt form.'",
            "The sun falls under the house of the serpent,",
            "One walked out a monster. The other never did."
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function(self)
        return false
    end,
    overrides_base_rank = true,
    replace_base_card = true,
    pos = {x=4, y=1}
}

SMODS.Enhancement {
    key = "infinity_snake",
    loc_txt = {
        name = "Infinity Snake",
        text = {
            "{X:dark_edition,C:white}WISH{}",
            "A wish to comprehend the infinite.",
            "Could a beast comprehend the cosmos?",
            "The concept of oblivion and nothingness?",
            "Two roaring beasts with spears came with an answer.",
            "A death to set it straight."
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function(self)
        return false
    end,
    overrides_base_rank = true,
    replace_base_card = true,
    pos = {x=7, y=0}
}

SMODS.Enhancement {
    key = "twin_headed_snake",
    loc_txt = {
        name = "Twin-Headed Snake",
        text = {
            "{X:dark_edition,C:white}WISH{}",
            "A wish to be understood and known.",
            "Two heads, but which one knows the truth?",
            "The harshest truths are best kept from hiders, keepers.",
            "Two heads, but three minds,",
            "Housed under the two who have hidden.",
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function(self)
        return false
    end,
    overrides_base_rank = true,
    replace_base_card = true,
    pos = {x=8, y=0}
}

SMODS.Enhancement {
    key = "conjoined_snakes",
    loc_txt = {
        name = "Conjoined Snakes",
        text = {
            "{X:dark_edition,C:white}WISH{}",
            "A wish for companionship.",
            "Near extinction. Serpentines meet their end en masse.",
            "They bite their own tails in search of respite.",
            "However, two sought companionship in trying times.",
            "They intertwined, never to let go.",
            "More followed, finding their own companions.",
            "Extinction follows. Snakes of the same colour of blood,",
            "of different scales, all shared the same fate."
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function(self)
        return false
    end,
    overrides_base_rank = true,
    replace_base_card = true,
    pos = {x=5, y=1}
}

SMODS.Enhancement {
    key = "arching_fish",
    loc_txt = {
        name = "Arching Fish",
        text = {
            "{X:dark_edition,C:white}WISH{}",
            "A wish for a breath of fresh air; to be renewed.",
            "A leap of faith, to feel the breeze,",
            "An invigoration from threats, so they leaped,",
            "Between twin serpents curved.",
            "Five came up, five came down.",
            "And swam with vigour, guided by sameness."
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function(self)
        return false
    end,
    overrides_base_rank = true,
    replace_base_card = true,
    pos = {x=9, y=0}
}

SMODS.Enhancement {
    key = "hiding_fish",
    loc_txt = {
        name = "Hiding Fish",
        text = {
            "{X:dark_edition,C:white}WISH{}",
            "A wish for secrecy and safety.",
            "Two beasts of nobles stand guard,",
            "Spears pointing to the heavens above,",
            "Guarding an eternal and cruel kingdom,",
            "But it only took one who came out of hiding,",
            "One of bravery - or foolishness - to undo it all,",
            "And sought to bring all echelons to par."
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function(self)
        return false
    end,
    overrides_base_rank = true,
    replace_base_card = true,
    pos = {x=10, y=0}
}

SMODS.Enhancement {
    key = "circling_fish",
    loc_txt = {
        name = "Circling Fish",
        text = {
            "{X:dark_edition,C:white}WISH{}",
            "A wish for royalty.",
            "A couple shared the same pond.",
            "They danced and swam with no care in the world.",
            "Peace proved short-lived as a bigger one approached.",
            "It who requires everyone to respect it; to tithe to it.",
            "Oppression. Unrest. The high echelon must fall.",
            "The couple went into hiding; leaving the unruly ruler exposed.",
            "A swooping predator snatched the largest prey it could find.",
            "The monarchy is dead."
        }
    },
    atlas = 'Enhancements',
    no_rank = true,
    no_suit = true,
    always_scores = true,
    in_pool = function(self)
        return false
    end,
    overrides_base_rank = true,
    replace_base_card = true,
    pos = {x=6, y=1}
}
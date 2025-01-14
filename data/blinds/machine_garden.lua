SMODS.Blind{
    key = "machine_garden",
    loc_txt = {
        name = "Machine Garden",
        text = {
            "The Artifact beckons you",
            "to find harmony"
        }
    },
    dollars = 8,
    mult = 3,
    boss = {
        showdown = true
    },
    boss_colour = HEX('006328'),
    atlas = 'Blinds',
    light_gauge = 0,
    dark_gauge = 0,
    enlightened_hands = 0,
    blind_alignment = nil,
    pos = {x = 0, y = 1},

    set_blind = function(self, reset, silent)
        self.light_gauge = 0
        self.dark_gauge = 0
        self.enlightened_hands = 0

        ease_hands_played(15)
        ease_discard(15)
        G.hand:change_size(3)

        for i = 1, 2 do
            local card = Card(G.play.T.x + G.play.T.w / 2, G.play.T.y, G.CARD_W, G.CARD_H, 
                pseudorandom_element(G.P_CARDS, pseudoseed('bl_tether')), 
                G.P_CENTERS.m_fm_unpowered_tether, 
                {playing_card = G.playing_card})
            card:start_materialize({G.C.SECONDARY_SET.Enhanced})
            G.play:emplace(card)
            draw_card(G.play, G.hand, 90, 'up', nil)
        end
    end,

    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
        light_gained = 0
        dark_gained = 0
     
        for _, card in ipairs(cards) do
            -- Check suits first
            if card.base.suit == "Hearts" or card.base.suit == "Diamonds" then
                light_gained = light_gained + 1
            elseif card.base.suit == "Spades" or card.base.suit == "Clubs" then
                dark_gained = dark_gained + 1
            end
     
            -- Check for enhancement bonuses
            if card.config.center then
                -- Light cards bonus (Solar, Arc)
                if card.config.center == G.P_CENTERS.m_fm_radiant or
                   card.config.center == G.P_CENTERS.m_fm_restoration or
                   card.config.center == G.P_CENTERS.m_fm_scorch or
                   card.config.center == G.P_CENTERS.m_fm_amplified or
                   card.config.center == G.P_CENTERS.m_fm_jolt or
                   card.config.center == G.P_CENTERS.m_fm_blinded or
                   card.config.center == G.P_CENTERS.m_fm_volatile or
                   card.config.center == G.P_CENTERS.m_fm_devour or
                   card.config.center == G.P_CENTERS.m_fm_overshield then
                    light_gained = light_gained + 2
                -- Dark cards bonus (Void, Stasis, Strand)
                elseif card.config.center == G.P_CENTERS.m_fm_resonant or
                       card.config.center == G.P_CENTERS.m_fm_finalized or
                       card.config.center == G.P_CENTERS.m_fm_dissected or
                       card.config.center == G.P_CENTERS.m_fm_slow or
                       card.config.center == G.P_CENTERS.m_fm_freeze or
                       card.config.center == G.P_CENTERS.m_fm_shatter or
                       card.config.center == G.P_CENTERS.m_fm_tangle or
                       card.config.center == G.P_CENTERS.m_fm_wovenmail or
                       card.config.center == G.P_CENTERS.m_fm_unravel then
                        dark_gained = dark_gained + 2
                -- Prismatic cards
                elseif card.config.center == G.P_CENTERS.m_fm_transcendent then
                    light_gained = light_gained + 3
                    dark_gained = dark_gained + 3
                end
            end
        end
     
        -- Update gauges
        self.light_gauge = math.min(self.light_gauge + light_gained, 5)
        self.dark_gauge = math.min(self.dark_gauge + dark_gained, 5)
     
        -- Show gauge status
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                attention_text({
                    text = string.format("Light: %d/5 | Dark: %d/5", 
                        self.light_gauge or 0, self.dark_gauge or 0),
                    scale = 0.5,
                    hold = 15,
                    offset = {x = 0, y = -2.7},
                    major = G.play,
                })
                -- CHANGE THE SOUND LATER
                play_sound("fm_machine_garden_gauge_fill")
                G.play:juice_up(0.1, 0.2)
                return true
            end
        }))
            
        -- Check if gauges are full
        if self.light_gauge >= 5 and self.dark_gauge >= 5 then
            if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                -- Set alignment on G.GAME.blind instead of self
                play_sound("fm_machine_garden_mote_spawn", nil, 0.3)
                G.GAME.blind.blind_alignment = pseudorandom('bl_mote') < G.GAME.probabilities.normal / 2 and 'light' or 'dark'
                
                -- Change blind icon
                G.GAME.blind:juice_up()
                G.GAME.blind.children.animatedSprite:set_sprite_pos({
                    x = 0,
                    y = G.GAME.blind.blind_alignment == 'light' and 3 or 2
                })    
                -- Create Light Mote
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    func = function()
                        local card = SMODS.add_card({
                            set = "raid_elements",
                            area = G.consumeables,
                            key = "c_fm_voltaic_mote"
                        })
                        G.GAME.consumeable_buffer = 0
                        return true
                    end
                }))
     
                -- Create Dark Mote
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.3,
                    func = function()
                        local card = SMODS.add_card({
                            set = "raid_elements",
                            area = G.consumeables,
                            key = "c_fm_tainted_voltaic_mote"
                        })
                        G.GAME.consumeable_buffer = 0
                        return true
                    end
                }))
            end
            
            self.light_gauge = 0
            self.dark_gauge = 0
        end

        if #cards >= 5 then
            for i = 1, #cards - 4 do
                if (cards[i].config.center.key == "m_fm_powered_tether_light" or
                    cards[i].config.center.key == "m_fm_powered_tether_dark") and
                   cards[i+1].ability.fm_voltaic_overflow and
                   cards[i+2].ability.fm_voltaic_overflow and
                   cards[i+3].ability.fm_voltaic_overflow and
                   (cards[i+4].config.center.key == "m_fm_powered_tether_light" or
                    cards[i+4].config.center.key == "m_fm_powered_tether_dark") then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.4,
                            func = function()
                                attention_text({
                                    text = string.format("ENLIGHTENED"),
                                    scale = 1.3,
                                    hold = 10,
                                    major = G.play,
                                    backdrop_colour = G.C.WHITE
                                })
                                -- CHANGE THE SOUND LATER
                                play_sound("fm_machine_garden_tether_linked")
                                G.play:juice_up(0.1, 0.2)
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'after',
                                    delay = 0.15,
                                    func = function()
                                        for _, card in ipairs(G.hand.cards) do
                                            if card.config.center.key == "m_fm_powered_tether_light" or
                                               card.config.center.key == "m_fm_powered_tether_dark" then
                                                card:set_ability(G.P_CENTERS.m_fm_unpowered_tether)
                                                card:juice_up(0.1, 0.2)
                                            end
                                        end
                                        G.GAME.blind:juice_up()
                                        G.GAME.blind.children.animatedSprite:set_sprite_pos({x = 0, y = 1})
                                        G.GAME.blind_alignment = nil
                                        return true
                                    end
                                }))
                                return true
                            end
                        }))
                    self.enlightened_hands = 4
                    self.scoring_disabled = false
                    break
                end
            end
        end
     
        if self.enlightened_hands > 0 and not found_pattern then
            self.enlightened_hands = self.enlightened_hands - 1
            if self.enlightened_hands == 0 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        attention_text({
                            text = string.format("ENLIGHTENED EXPIRED"),
                            scale = 1.3,
                            hold = 10,
                            major = G.play,
                            backdrop_colour = G.C.WHITE
                        })
                        -- CHANGE THE SOUND LATER
                        play_sound("fm_corrupted_wish_wish_granted")
                        G.play:juice_up(0.1, 0.2)
                        return true
                    end
                }))
                self.scoring_disabled = true
            end
        end
     
        return mult, hand_chips, true
    end,

    defeat = function(self)
        G.hand:change_size(-3)
        for i = #G.deck.cards, 1, -1 do
            if G.deck.cards[i].config.center == G.P_CENTERS.m_fm_unpowered_tether or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_powered_tether_dark or
               G.deck.cards[i].config.center == G.P_CENTERS.m_fm_powered_tether_light then
                G.deck.cards[i]:start_dissolve({G.C.GREEN})
            end
        end
    end
}

SMODS.Enhancement {
    key = "unpowered_tether",
    loc_txt = {
        name = "Unpowered Tether",
        text = {
            "{X:dark_edition,C:white}TETHER{}",
            "The Tether remains dormant..."
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
    pos = {x=3, y=2}
}

SMODS.Enhancement {
    key = "powered_tether_light",
    loc_txt = {
        name = "Powered Tether (Light)",
        text = {
            "{X:dark_edition,C:white}TETHER{}",
            "The Tether surges with {C:blue}voltaic{} energy."
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
    pos = {x=4, y=2}
}

SMODS.Enhancement {
    key = "powered_tether_dark",
    loc_txt = {
        name = "Powered Tether (Dark)",
        text = {
            "{X:dark_edition,C:white}TETHER{}",
            "The Tether surges with {C:attention}tainted voltaic{} energy."
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
    pos = {x=5, y=2}
}

SMODS.Sticker {
    key = "voltaic_overflow",
    loc_txt = {
        name = "Voltaic Overflow",
        text = {
            "It rumbles with a flood of energy,",
            "seems to seek out on its own."
        }
    },
    atlas = 'Stickers',
    default_compat = true,
    sets = {
        Joker = false
    },
    pos = {x=0, y=0},
    calculate = function(self, card, context)
        if card.area == G.hand and context.after then
            local DETONATE_AMOUNT = 9
            -- Check for correct pattern
            local pattern_found = false
            if #context.scoring_hand >= 5 then
                for i = 1, #context.scoring_hand - 4 do
                    if (context.scoring_hand[i].config.center.key == "m_fm_powered_tether_light" or
                        context.scoring_hand[i].config.center.key == "m_fm_powered_tether_dark") and
                        context.scoring_hand[i+1].ability.fm_voltaic_overflow and
                        context.scoring_hand[i+2].ability.fm_voltaic_overflow and
                        context.scoring_hand[i+3].ability.fm_voltaic_overflow and
                        (context.scoring_hand[i+4].config.center.key == "m_fm_powered_tether_light" or
                        context.scoring_hand[i+4].config.center.key == "m_fm_powered_tether_dark") then
                        pattern_found = true
                        break
                    end
                end
            end

            -- If any Voltaic cards played without correct pattern
            local any_voltaic = false
            for _, scoring_card in ipairs(context.scoring_hand) do
                if scoring_card.ability.fm_voltaic_overflow then
                    any_voltaic = true
                    break
                end
            end

            if any_voltaic and not pattern_found then
                -- Reset tethers and blind
                for _, hand_card in ipairs(G.hand.cards) do
                    if hand_card.config.center.key == "m_fm_powered_tether_light" or
                        hand_card.config.center.key == "m_fm_powered_tether_dark" then
                        play_sound("fm_machine_garden_tether_unpowering")
                        hand_card:set_ability(G.P_CENTERS.m_fm_unpowered_tether)
                    end
                end
                for _, play_card in ipairs(G.play.cards) do
                    if play_card.config.center.key == "m_fm_powered_tether_light" or
                        play_card.config.center.key == "m_fm_powered_tether_dark" then
                        play_sound("fm_machine_garden_tether_unpowering")
                        play_card:set_ability(G.P_CENTERS.m_fm_unpowered_tether)
                    end
                end
                G.GAME.blind:juice_up()
                G.GAME.blind.children.animatedSprite:set_sprite_pos({x = 0, y = 1})
                G.GAME.blind.blind_alignment = nil

                -- Remove Voltaic stickers
                for _, hand_card in ipairs(G.hand.cards) do
                    if hand_card.ability.fm_voltaic_overflow then
                        SMODS.Stickers.fm_voltaic_overflow:apply(hand_card)
                    end
                end
                for _, play_card in ipairs(G.play.cards) do
                    if play_card.ability.fm_voltaic_overflow then
                        SMODS.Stickers.fm_voltaic_overflow:apply(play_card)
                    end
                end

                -- Destroy random cards
                local destroyable_cards = {}
                for _, hand_card in ipairs(G.hand.cards) do
                    if hand_card.config.center ~= G.P_CENTERS.m_fm_unpowered_tether and
                        hand_card.config.center ~= G.P_CENTERS.m_fm_powered_tether_light and
                        hand_card.config.center ~= G.P_CENTERS.m_fm_powered_tether_dark then
                        table.insert(destroyable_cards, hand_card)
                    end
                end

                for i = 1, math.min(DETONATE_AMOUNT, #destroyable_cards) do
                    local idx = math.random(1, #destroyable_cards)
                    destroyable_cards[idx]:start_dissolve()
                    table.remove(destroyable_cards, idx)
                end
                
                return {
                    message = "Detonated!",
                    colour = G.C.RED
                }
            end
        end
    end
}

SMODS.Consumable {
    key = "voltaic_mote",
    set = "raid_elements",
    loc_txt = {
        name = "Voltaic Mote",
        text = {
            "A coalesced essence of",
            "{C:blue}voltaic energy{}."
        }
    },
    atlas = "Consumables",
    in_pool = function(self)
        return false
    end,
    pos = {x=0, y=0},
    use = function(self, card, area, copier)
        -- Check if correct mote is used
        local is_correct_mote = (G.GAME.blind.blind_alignment == 'light')
        
        if not is_correct_mote then
            -- Destroy hand except tethers
            ease_background_colour{new_colour = G.C.RED, contrast = 3}
            G.ROOM.jiggle = G.ROOM.jiggle + 100
            play_sound("fm_machine_garden_explosion")
            for _, handCard in ipairs(G.hand.cards) do
                if handCard.config.center ~= G.P_CENTERS.m_fm_unpowered_tether and
                   handCard.config.center ~= G.P_CENTERS.m_fm_powered_tether_light and
                   handCard.config.center ~= G.P_CENTERS.m_fm_powered_tether_dark then
                    handCard:start_dissolve()
                end
            end
            
            -- Destroy random joker
            if #G.jokers.cards > 0 then
                local random_joker = G.jokers.cards[math.random(1, #G.jokers.cards)]
                random_joker:start_dissolve()
            end

            for _, consumable in ipairs(G.consumeables.cards) do
                if consumable.config.center.key == "c_fm_tainted_voltaic_mote" then
                    consumable:start_dissolve()
                end
            end

            G.GAME.blind:juice_up()
            G.GAME.blind.children.animatedSprite:set_sprite_pos({x = 0, y = 1})
            G.GAME.blind_alignment = nil
            return
        end
     
        -- Power up tethers
        for _, handCard in ipairs(G.hand.cards) do
            if handCard.config.center == G.P_CENTERS.m_fm_unpowered_tether then
                SMODS.calculate_effect({
                    message = "Charged!",
                    sound = "fm_machine_garden_tether_powered",
                    colour = G.C.BLUE
                }, handCard)
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        handCard:set_ability(G.P_CENTERS.m_fm_powered_tether_light)
                        return true
                    end
                }))
            end
        end
     
        -- Destroy other mote
        for _, consumable in ipairs(G.consumeables.cards) do
            if consumable.config.center.key == "c_fm_tainted_voltaic_mote" then
                consumable:start_dissolve()
            end
        end
     
        -- Add Voltaic Overflow to three cards
        local available_cards = {}
        for _, handCard in ipairs(G.hand.cards) do
            if not handCard.ability.fm_voltaic_overflow and 
               handCard.config.center ~= G.P_CENTERS.m_fm_unpowered_tether and
               handCard.config.center ~= G.P_CENTERS.m_fm_powered_tether_light and
               handCard.config.center ~= G.P_CENTERS.m_fm_powered_tether_dark then
                table.insert(available_cards, handCard)
            end
        end
     
        for i = 1, math.min(3, #available_cards) do
            local _card = pseudorandom_element(available_cards, pseudoseed('jolt'))
            while _card.jolted do
                _card = pseudorandom_element(available_cards, pseudoseed('jolt_reroll'))
            end
            SMODS.calculate_effect({
                message = "!",
                sound = "fm_machine_garden_voltaic_overflow_spawn",
                colour = G.C.BLUE
            }, _card)
            _card.jolted = true
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    SMODS.Stickers.fm_voltaic_overflow:apply(_card, true)
                    _card.jolted = nil               
                    return true
                end
            }))
        end
    end,
    can_use = function(self, card)
        for _, handCard in ipairs(G.hand.cards) do
            if handCard.config.center == G.P_CENTERS.m_fm_unpowered_tether then
                return true
            end
        end
        return false
    end
}

SMODS.Consumable {
    key = "tainted_voltaic_mote",
    set = "raid_elements",
    loc_txt = {
        name = "Tainted Voltaic Mote",
        text = {
            "A coalesced essence of",
            "{C:attention}tainted voltaic energy{}."
        }
    },
    atlas = "Consumables",
    in_pool = function(self)
        return false
    end,
    pos = {x=1, y=0},
    use = function(self, card, area, copier)
        local is_correct_mote = (G.GAME.blind.blind_alignment == 'dark')
        
        if not is_correct_mote then
            -- Destroy hand except tethers
            ease_background_colour{new_colour = G.C.RED, contrast = 3}
            G.ROOM.jiggle = G.ROOM.jiggle + 100
            play_sound("fm_machine_garden_explosion")
            for _, handCard in ipairs(G.hand.cards) do
                if handCard.config.center ~= G.P_CENTERS.m_fm_unpowered_tether and
                    handCard.config.center ~= G.P_CENTERS.m_fm_powered_tether_light and
                    handCard.config.center ~= G.P_CENTERS.m_fm_powered_tether_dark then
                    handCard:start_dissolve()
                end
            end
        
            -- Destroy random joker
            if #G.jokers.cards > 0 then
                local random_joker = G.jokers.cards[math.random(1, #G.jokers.cards)]
                random_joker:start_dissolve()
            end

            for _, consumable in ipairs(G.consumeables.cards) do
                if consumable.config.center.key == "c_fm_voltaic_mote" then
                    consumable:start_dissolve()
                end
            end

            G.GAME.blind:juice_up()
            G.GAME.blind.children.animatedSprite:set_sprite_pos({x = 0, y = 1})
            G.GAME.blind_alignment = nil
            return
        end
        
        -- Power up tethers
        for _, handCard in ipairs(G.hand.cards) do
            if handCard.config.center == G.P_CENTERS.m_fm_unpowered_tether then
                SMODS.calculate_effect({
                    message = "Charged!",
                    sound = "fm_machine_garden_tether_powered",
                    colour = G.C.ORANGE
                }, handCard)
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        handCard:set_ability(G.P_CENTERS.m_fm_powered_tether_dark)
                        return true
                    end
                }))
            end
        end
        
        -- Destroy other mote
        for _, consumable in ipairs(G.consumeables.cards) do
            if consumable.config.center.key == "c_fm_voltaic_mote" then
                consumable:start_dissolve()
            end
        end
        
        -- Add Voltaic Overflow to three cards
        local available_cards = {}
        for _, handCard in ipairs(G.hand.cards) do
            if not handCard.ability.fm_voltaic_overflow and 
                handCard.config.center ~= G.P_CENTERS.m_fm_unpowered_tether and
                handCard.config.center ~= G.P_CENTERS.m_fm_powered_tether_light and
                handCard.config.center ~= G.P_CENTERS.m_fm_powered_tether_dark then
                table.insert(available_cards, handCard)
            end
        end
        
        for i = 1, math.min(3, #available_cards) do
            local _card = pseudorandom_element(available_cards, pseudoseed('jolt'))
            while _card.jolted do
                _card = pseudorandom_element(available_cards, pseudoseed('jolt_reroll'))
            end
            SMODS.calculate_effect({
                message = "!",
                sound = "fm_machine_garden_voltaic_overflow_spawn",
                colour = G.C.ORANGE
            }, _card)
            _card.jolted = true
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    SMODS.Stickers.fm_voltaic_overflow:apply(_card, true)
                    _card.jolted = nil               
                    return true
                end
            }))
        end
    end,
    can_use = function(self, card)
        for _, handCard in ipairs(G.hand.cards) do
            if handCard.config.center == G.P_CENTERS.m_fm_unpowered_tether then
                return true
            end
        end
        return false
    end
}
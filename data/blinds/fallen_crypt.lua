SMODS.Blind{
    key = "fallen_crypt",
    loc_txt = {
        name = "Fallen Crypt",
        text = {
            "You now face godlike judgement,",
            "may it extend eternally"
        }
    },
    dollars = 8,
    mult = 3,
    boss = {
        showdown = true
    },
    boss_colour = HEX('00FFCA'),
    atlas = 'Blinds',
    pos = {x = 0, y = 4},

    set_blind = function(self, reset, silent)
        ease_hands_played(15)
        ease_discard(15)
        G.hand:change_size(3)

        G.FM_OPERATOR_SUCCESSES = 0

        -- Spawn operator panel cards
        for i = 1, 1 do
            local card = SMODS.add_card{ key = "j_fm_operator_panel", area = G.mechanic_sprites }
            card:start_materialize({G.C.SECONDARY_SET.Enhanced})
        end
    end,

    modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
        -- Initialize tracking variables if not present
        if not G.FM_SENTINEL_HANDS then G.FM_SENTINEL_HANDS = 0 end
        if not G.FM_SENTINEL_NEXT then G.FM_SENTINEL_NEXT = pseudorandom("sentinel_next", 1, 3) end

        -- Check if a Sentinel Joker exists
        local sentinel_exists = false
        for _, joker in ipairs(G.jokers.cards) do
            if joker.config.center_key == "j_fm_sentinel" then
                sentinel_exists = true
                break
            end
        end

        -- Increment hand counter
        G.FM_SENTINEL_HANDS = G.FM_SENTINEL_HANDS + 1

        -- Spawn Sentinel if interval reached and none exists
        if not sentinel_exists and G.FM_SENTINEL_HANDS >= G.FM_SENTINEL_NEXT then
            local card = Card(G.jokers.T.x, G.jokers.T.y, G.CARD_W, G.CARD_H, nil, G.P_CENTERS.j_fm_sentinel)
            card:start_materialize({G.C.SECONDARY_SET.Enhanced})
            G.jokers:emplace(card)
            draw_card(G.jokers, G.jokers, 90, 'up', nil, card)
            -- Reset counter and pick new interval
            SMODS.calculate_effect({
                message = "!",
                sound = "fm_fallen_crypt_sentinel",
                colour = G.C.DARK_EDITION
            }, card)
            G.FM_SENTINEL_HANDS = 0
            G.FM_SENTINEL_NEXT = pseudorandom("sentinel_next", 1, 3)
        end

        return mult, hand_chips, true
    end,

    defeat = function(self)
        G.hand:change_size(-3)
        for i = #G.deck.cards, 1, -1 do
            if G.deck.cards[i].ability.fm_operator then
                SMODS.Stickers.fm_operator:apply(G.deck.cards[i])
            elseif G.deck.cards[i].ability.fm_scanner then
                SMODS.Stickers.fm_scanner:apply(G.deck.cards[i])
            elseif G.deck.cards[i].ability.fm_suppressor then
                SMODS.Stickers.fm_suppressor:apply(G.deck.cards[i])
            end
        end
    end
}

SMODS.Consumable {
    key = 'augment',
    loc_txt = {
        name = "Augment (TEMP)",
        text = {
            ".."
        }
    },
    atlas = 'Consumables',
    set = 'traits',
    pos = { x = 3, y = 1 },
    use = function(self, card, area, copier)
        for i, selectedCard in ipairs(G.hand.highlighted) do
            SMODS.Stickers.fm_scanner:apply(selectedCard, true)
        end
    end,
    can_use = function(self, card)
        return G.consumeables and #G.hand.highlighted == 1
    end
}

SMODS.Joker{
    key = "operator_panel",
    loc_txt = {
        name = "Operator Panel",
        text = {
            "{C:green}>{} BOOT SUCCESSFUL",
            "{C:green}>{} AUTHORIZATION {C:red}#1#{}{C:green}#2#{}",
            "{C:green}>{} #3# {C:green}#4#{}",
            "{C:green}>{} #5#",
            "{C:green}>{} #6# {C:attention}'#7#'{}",
        }
    },
    atlas = 'Jokers',
    in_pool = function(self)
        return false
    end,
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    pos = {x=2, y=0},
    config = {
        extra = {
            state = "inactive", -- "inactive", "scanner", "success"
            last_codename = "???"
        }
    },
    loc_vars = function(self, info_queue, card)
        local codename = card.ability.extra.last_codename or "???"
        if card.ability.extra.state == "scanner" or card.ability.extra.state == "success" then
            return { vars = {
                "", "SUCCESSFUL", "SCANNER PROTOCOL:", "ACTIVE", "GENERATING CODENAME", "CONFIRM INPUT:", codename
            }}
        else
            return { vars = {
                "REQUIRED", "", "...", "", "...", "...", ""
            }}
        end
    end,
    calculate = function(self, card, context)
        local hand_codename = {
            ["High Card"] = "HC",
            ["Pair"] = "P",
            ["Two Pair"] = "2P",
            ["Three of a Kind"] = "3OAK",
            ["Straight"] = "S",
            ["Flush"] = "F",
            ["Full House"] = "Full_H",
            ["Four of a Kind"] = "4OAK",
            ["Straight Flush"] = "SF",
            ["Royal Flush"] = "RF",
            ["Five of a Kind"] = "5OAK",
            ["Flush House"] = "Flush_H",
            ["Flush Five"] = "F5"
        }
        local codename_list = {
            "HC", "P", "2P", "3OAK", "S", "F", "Full_H", "4OAK", "SF", "RF", "5OAK", "Flush_H", "F5"
        }
        local codename_to_hand = {}
        for k, v in pairs(hand_codename) do codename_to_hand[v] = k end

        if context.joker_main then
            -- Initial trigger for scanner state (if a scanner card is scored)
            for _, scoredCard in ipairs(context.scoring_hand or {}) do
                if scoredCard.ability.fm_scanner then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            card.ability.extra.state = "scanner"
                            -- Pick a random codename
                            local idx = pseudorandom("operator_panel_codename_", 1, #codename_list)
                            card.ability.extra.last_codename = codename_list[idx]
                            card:juice_up()
                            card.children.center:set_sprite_pos({ x = 3, y = 0 })
                            return true
                        end
                    }))
                    return {
                        message = "Scanned!",
                        sound = "fm_fallen_crypt_scanner",
                        colour = G.C.ORANGE
                    }
                end
                if card.ability.extra.state == "scanner" then
                    for _, scoredCard in ipairs(context.scoring_hand or {}) do
                        if scoredCard.ability.fm_operator then
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    local idx = pseudorandom("operator_panel_codename_reroll_", 1, #codename_list)
                                    card.ability.extra.last_codename = codename_list[idx]
                                    card:juice_up()
                                    card.children.center:set_sprite_pos({ x = 3, y = 0 })
                                    return true
                                end
                            }))
                            return {
                                message = "Rebooted!",
                                sound = "fm_fallen_crypt_operator",
                                colour = G.C.RED
                            }
                        end
                    end
                end
            end

            -- If in scanner state, check for matching hand to succeed
            if card.ability.extra.state == "scanner" and card.ability.extra.last_codename ~= "???" then
                local needed = codename_to_hand[card.ability.extra.last_codename]
                if needed and context.scoring_name == needed then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            card.ability.extra.state = "success"
                            card:juice_up()
                            card.children.center:set_sprite_pos({ x = 4, y = 0 })
                            -- Increment success counter
                            G.FM_OPERATOR_SUCCESSES = (G.FM_OPERATOR_SUCCESSES or 0) + 1
                            -- Spawn another Operator Panel if less than 5 successes
                            if G.FM_OPERATOR_SUCCESSES < 5 then
                                local new_card = SMODS.add_card{ key = "j_fm_operator_panel", area = G.mechanic_sprites }
                                new_card:start_materialize({G.C.SECONDARY_SET.Enhanced})
                            end
                            return true
                        end
                    }))
                    return {
                        message = "Success!",
                        sound = "fm_fallen_crypt_scanner",
                        colour = G.C.GREEN,
                        G.E_MANAGER:add_event(Event({
                            delay = 1.0,
                            func = function()
                                card:start_dissolve()
                                return true
                            end
                        }))
                    }
                end
            end
        end
    end
}

SMODS.Joker{
    key = "sentinel",
    loc_txt = {
        name = "Sentinel",
        text = {
            "The Sentinel beckons for a trade...",
            "{C:inactive}(Goal: {C:attention}#1#{C:inactive} Chips)"
        }
    },
    atlas = 'Jokers',
    in_pool = function(self)
        return false
    end,
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    pos = {x=5, y=0},
    config = {
        extra = {
            goal = 0,
            last_score = 0,
            completed = false
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = {
                card.ability.extra.goal or 0,
                card.ability.extra.last_score or 0
            }
        }
    end,
    calculate = function(self, card, context)
        if card.ability.extra.goal == 0 then
            card.ability.extra.goal = pseudorandom("goal", 10000, 35000)
        end

        -- After scoring, check if current score meets or exceeds the goal
        if context.final_scoring_step and not card.ability.extra.completed then
            local current_score = hand_chips * mult
            card.ability.extra.last_score = current_score

            if current_score >= card.ability.extra.goal then
                -- Find all cards in hand
                local hand_cards = {}
                for _, handCard in ipairs(G.hand.cards) do
                    table.insert(hand_cards, handCard)
                end
                -- Shuffle and pick 3 random cards
                if #hand_cards >= 3 then
                    -- Shuffle using pseudorandom
                    for i = #hand_cards, 2, -1 do
                        local j = math.floor(pseudorandom('sentinel_shuffle'..i) * i) + 1
                        hand_cards[i], hand_cards[j] = hand_cards[j], hand_cards[i]
                    end
                    -- Only select cards that do NOT have any of the stickers
                    local eligible = {}
                    for _, c in ipairs(hand_cards) do
                        if not (c.ability.fm_operator or c.ability.fm_scanner or c.ability.fm_suppressor) then
                            table.insert(eligible, c)
                        end
                    end
                    if #eligible >= 3 then
                        local targets = {eligible[1], eligible[2], eligible[3]}
                        local stickers = {"fm_operator", "fm_scanner", "fm_suppressor"}
                        for i, target in ipairs(targets) do
                            local sticker_key = stickers[i]
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    SMODS.Stickers[sticker_key]:apply(target, true)
                                    target:juice_up()
                                    return true
                                end
                            }))
                        end
                        card.ability.extra.completed = true
                        return{
                            message = "Granted!",
                            colour = G.C.ORANGE,
                                G.E_MANAGER:add_event(Event({
                                delay = 1.0,
                                func = function()
                                    card:start_dissolve()
                                    return true
                                end
                            }))
                        }
                    end
                end
            end
        end
        -- Destroy the card after the goal is met
        if card.ability.extra.completed and context.destroy_card and context.destroy_card == card then
            return {remove = true}
        end
        -- Reset for next round if needed
        if context.end_of_round then
            card.ability.extra.last_score = 0
        end
    end
}

SMODS.Sticker {
    key = "operator",
    loc_txt = {
        name = "Operator",
        text = { 
            "> AWAITING INPUT:",
            "> G.PLAY"
        }
    },
    atlas = "Stickers",
    pos = {x = 4, y = 0},
    default_compat = true,
    draw = function(self, card, layer)
        local t = G.TIMERS.REAL
        local cycle = math.sin(0.5 * t)
        local pulse = 0.5 + 0.3 * cycle
        
        G.shared_stickers[self.key].role.draw_major = card
        
        G.shared_stickers[self.key]:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse)
    end
}

SMODS.Sticker {
    key = "scanner",
    loc_txt = {
        name = "Scanner",
        text = { 
            "> AWAITING INPUT:",
            "> G.PLAY"
        }
    },
    atlas = "Stickers",
    pos = {x = 4, y = 1},
    default_compat = true,
    draw = function(self, card, layer)
        local t = G.TIMERS.REAL
        local cycle = math.sin(0.5 * t)
        local pulse = 0.5 + 0.3 * cycle
        
        G.shared_stickers[self.key].role.draw_major = card
        
        G.shared_stickers[self.key]:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse)
    end
}

SMODS.Sticker {
    key = "suppressor",
    loc_txt = {
        name = "Suppressor",
        text = { 
            "> AWAITING INPUT:",
            "> G.PLAY"
        }
    },
    atlas = "Stickers",
    pos = {x = 3, y = 1},
    default_compat = true,
    draw = function(self, card, layer)
        local t = G.TIMERS.REAL
        local cycle = math.sin(0.5 * t)
        local pulse = 0.5 + 0.3 * cycle
        
        G.shared_stickers[self.key].role.draw_major = card

        G.shared_stickers[self.key]:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse)
    end
}
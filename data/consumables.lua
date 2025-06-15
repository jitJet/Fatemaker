SMODS.Consumable {
    key = 'clown_cartridge',
    loc_txt = {
        name = "Clown Cartridge",
        text = {
            "Draw up to {C:attention}5{} extra cards"
        }
    },
    set = 'traits',
    atlas = 'Consumables',
    pos = { x = 4, y = 0 },
    use = function(self, card, area, copier)
        local odds = {
            1,
            2,
            3,
            4,
            5
        }
        for i = 1, pseudorandom_element(odds, pseudoseed('Balalalala')) do
            draw_card(G.deck, G.hand, 90, 'up', nil)
        end
    end,
    can_use = function(self, card)
        return G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit
    end
}

SMODS.Consumable {
    key = 'vivisection',
    loc_txt = {
        name = "Vivisection",
        text = {
            "Draw a card, Dissect it but",
            "debuff it until the end of the round"
        }
    },
    set = 'traits',
    atlas = 'Consumables',
    pos = { x = 6, y = 0 },
    use = function(self, card, area, copier)
        local _cards = {}
        for _, playing_card in ipairs(G.playing_cards) do
            _cards[#_cards + 1] = playing_card
        end
        local selected_card = pseudorandom_element(_cards, pseudoseed('Balalalala'))

        draw_card(G.deck, G.hand, 90, 'up', nil, selected_card)

        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.5,
            func = function()
                selected_card:flip()
                selected_card:set_ability(G.P_CENTERS.m_fm_dissected)
                SMODS.debuff_card(selected_card, true, "vivisected")
                selected_card.ability.vivisected = true
                selected_card:flip()
                return true
            end
        }))

        local end_round_ref = end_round
        function end_round()
            local ret = end_round_ref()
            for _,v in ipairs(G.playing_cards) do
                if v.ability.vivisected then
                    v.ability.vivisected = false
                    SMODS.debuff_card(v, false, "vivisected")
                end
            end
            return ret
        end
    end,
    can_use = function(self, card)
        return G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit
    end
}
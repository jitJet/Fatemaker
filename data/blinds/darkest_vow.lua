-- SMODS.Blind{
--     key = "darkest_vow",
--     loc_txt = {
--         name = "Darkest Vow",
--         text = {
--             "Drown in the Deep,",
--             "or rise from it."
--         }
--     },
--     dollars = 8,
--     mult = 3,
--     boss = {
--         showdown = true
--     },
--     boss_colour = HEX('00FFCA'),
--     atlas = 'Blinds',
--     blind_alignment = nil,
--     pos = {x = 0, y = 4},

--     set_blind = function(self, reset, silent)
--         ease_hands_played(15)
--         ease_discard(15)
--         G.hand:change_size(3)

--         -- for i = 1, 2 do
--         --     local card = Card(G.play.T.x + G.play.T.w / 2, G.play.T.y, G.CARD_W, G.CARD_H, 
--         --         pseudorandom_element(G.P_CARDS, pseudoseed('bl_tether')), 
--         --         G.P_CENTERS.m_fm_unpowered_tether, 
--         --         {playing_card = G.playing_card})
--         --     card:start_materialize({G.C.SECONDARY_SET.Enhanced})
--         --     G.play:emplace(card)
--         --     draw_card(G.play, G.hand, 90, 'up', nil)
--         -- end
--     end,

--     modify_hand = function(self, cards, poker_hands, text, mult, hand_chips)
     
--         return mult, hand_chips, true
--     end,

--     defeat = function(self)
--         G.hand:change_size(-3)
--         -- for i = #G.deck.cards, 1, -1 do
--         --     if G.deck.cards[i].config.center == G.P_CENTERS.m_fm_unpowered_tether or
--         --        G.deck.cards[i].config.center == G.P_CENTERS.m_fm_powered_tether_dark or
--         --        G.deck.cards[i].config.center == G.P_CENTERS.m_fm_powered_tether_light then
--         --         G.deck.cards[i]:start_dissolve({G.C.GREEN})
--         --     end
--         --     if G.deck.cards[i].ability.fm_voltaic_overflow then
--         --         SMODS.Stickers.fm_voltaic_overflow:apply(G.deck.cards[i])
--         --     end
--         -- end
--     end
-- }
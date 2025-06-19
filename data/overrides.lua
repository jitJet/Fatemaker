SMODS.ConsumableType ({
    key = "raid_elements",
    primary_colour = HEX('3c4242'),
    secondary_colour = HEX('181c1f'),
    loc_txt = {
        name = "Raid Element",
        collection = "Raid Elements",
        undiscovered = {
            name = "Undiscovered",
            text = {
                "Seek a greater challenge,",
                "and it will be revealed."
            }
        }
    },
    shop_rate = 0
})

SMODS.ConsumableType ({
    key = "traits",
    primary_colour = HEX('96cbf9'),
    secondary_colour = HEX('7cb3e3'),
    loc_txt = {
        name = "Trait",
        collection = "Traits",
        undiscovered = {
            name = "Undiscovered",
            text = {
                "Banshee-44 sends his",
                "regards, Guardian."
            }
        }
    },
    shop_rate = 1
})

SMODS.current_mod.optional_features = function()
    return {
    cardareas = {
            discard = true,
            deck = true
        }
    }
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local alias_draw_from_play_to_discard = G.FUNCS.draw_from_play_to_discard
G.FUNCS.draw_from_play_to_discard = function(e)
   local play_count = #G.play.cards
   local it = 1
   for k, v in ipairs(G.play.cards) do
       if (not v.shattered) and (not v.destroyed) then
           if v.config.center == G.P_CENTERS.m_fm_freeze and not v.ability.extra.times_returned then
               v.ability.extra.times_returned = 0
           end
           if v.config.center == G.P_CENTERS.m_fm_unpowered_tether or
           v.config.center == G.P_CENTERS.m_fm_powered_tether_light or 
           v.config.center == G.P_CENTERS.m_fm_powered_tether_dark then
               draw_card(G.play, G.hand, it*100/play_count, 'down', false, v)
               
            -- to add more returning cards, do elseif v.config.center == G.P_CENTERS.m_fm_...... then
           elseif v.config.center == G.P_CENTERS.m_fm_slow and pseudorandom('finalized') < G.GAME.probabilities.normal / 4 then
               draw_card(G.play, G.hand, it*100/play_count, 'down', false, v)
               card_eval_status_text(v, 'extra', nil, nil, nil, {
                   message = "Slowed!",
                   sound = "fm_slow",
                   colour = G.C.SUITS.Spades
               })
           elseif v.config.center == G.P_CENTERS.m_fm_freeze then
                local max_returns = v.ability.extra.max_returns or 2
                if v.ability.extra.converted then
                    draw_card(G.play, G.discard, it*100/play_count, 'down', false, v)
                elseif v.ability.extra.times_returned < max_returns then
                    draw_card(G.play, G.hand, it*100/play_count, 'down', false, v)
                    v.ability.extra.times_returned = v.ability.extra.times_returned + 1
                    card_eval_status_text(v, 'extra', nil, nil, nil, {
                        message = "Frozen!",
                        sound = "fm_freeze",
                        colour = G.C.SUITS.Spades
                    })
                else
                    v.ability.extra.times_returned = 0
                    draw_card(G.play, G.discard, it*100/play_count, 'down', false, v)
                end
           else
               draw_card(G.play, G.discard, it*100/play_count, 'down', false, v)
           end
           it = it + 1
       end
   end
end

local alias_set_debuff = Card.set_debuff
function Card:set_debuff(should_debuff)
    if self.config.center_key == "m_fm_wovenmail" then
        self.debuff = false 
        return
    end
        return alias_set_debuff(self, should_debuff)
end

local alias_disable = Blind.disable
function Blind:disable(should_disable)
    if G.GAME.blind.config.blind.key == "bl_fm_corrupted_wish" or
    G.GAME.blind.config.blind.key == "bl_fm_machine_garden" or
    G.GAME.blind.config.blind.key == "bl_fm_fallen_crypt" or
    G.GAME.blind.config.blind.key == "bl_fm_darkest_vow" or
    G.GAME.blind.config.blind.key == "bl_fm_harmonic_root" or
    G.GAME.blind.config.blind.key == "bl_fm_reshaped_edge" then
        self.disabled = false
        return
    end
    return alias_disable(self, should_disable)
end

local alias_can_discard = G.FUNCS.can_discard
G.FUNCS.can_discard = function(e)
   for _, card in ipairs(G.hand.highlighted) do
       if card.config.center == G.P_CENTERS.m_fm_unpowered_tether or
       card.config.center == G.P_CENTERS.m_fm_powered_tether_dark or
       card.config.center == G.P_CENTERS.m_fm_powered_tether_light or
       card.ability.fm_catatonic then
           e.config.colour = G.C.UI.BACKGROUND_INACTIVE
           e.config.button = nil
           return
       end
   end
   alias_can_discard(e)
end

local alias_can_play = G.FUNCS.can_play
G.FUNCS.can_play = function(e)
    for _, card in ipairs(G.hand.highlighted) do
        if card.ability.fm_catatonic or card.config.center == G.P_CENTERS.m_fm_suppress then
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
            return
        end
    end
    alias_can_play(e)
end
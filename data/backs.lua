SMODS.Back {
    key = "deck_solar",
    loc_txt = {
        name = "Solar Deck",
        text = {
            'You wield the duality of the',
            'life-giving fire of our Sun;',
            "to scorch and to heal,",
            "to burn and to cauterize."
        }
    },
    pos = { x = 1, y = 3 },
    unlocked = true,
    apply = function(self, back)
        local tf = {
            true,
            true,
            true,
            false
        }
        local enhancements = {
            G.P_CENTERS.m_fm_radiant,-- Solar
            G.P_CENTERS.m_fm_scorch,
            G.P_CENTERS.m_fm_restoration,
            G.P_CENTERS.m_fm_cure
        }
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if pseudorandom_element(tf, pseudoseed('Idk')) then
                        v:set_ability(pseudorandom_element(enhancements, pseudoseed('Break Through')))
                    end
                end
                return true
            end
        }))
    end
}
SMODS.Back {
    key = "deck_void",
    loc_txt = {
        name = "Void Deck",
        text = {
            "You ventured to the deepest depths",
            "of the Void and asked a question;",
            "the answer is as clear as",
            "the secrets of the universe."
        }
    },
    pos = { x = 1, y = 3 },
    unlocked = true,
    apply = function(self, back)
        local tf = {
            true,
            true,
            true,
            false
        }
        local enhancements = {
            G.P_CENTERS.m_fm_overshield, -- Void
            G.P_CENTERS.m_fm_volatile,
            G.P_CENTERS.m_fm_devour,
            G.P_CENTERS.m_fm_suppress
        }
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if pseudorandom_element(tf, pseudoseed('Idk')) then
                        v:set_ability(pseudorandom_element(enhancements, pseudoseed('Break Through')))
                    end
                end
                return true
            end
        }))
    end
}
SMODS.Back {
    key = "deck_arc",
    loc_txt = {
        name = "Arc Deck",
        text = {
            'You leave a bold',
            'statement in your wake;',
            'A spark of chaos shining',
            'in just an arm\'s reach.'
        }
    },
    pos = { x = 1, y = 3 },
    unlocked = true,
    apply = function(self, back)
        local tf = {
            true,
            true,
            true,
            false
        }
        local enhancements = {
            G.P_CENTERS.m_fm_amplified, -- Arc
            G.P_CENTERS.m_fm_jolt,
            G.P_CENTERS.m_fm_blinded,
            G.P_CENTERS.m_fm_bolt_charge
        }
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if pseudorandom_element(tf, pseudoseed('Idk')) then
                        v:set_ability(pseudorandom_element(enhancements, pseudoseed('Break Through')))
                    end
                end
                return true
            end
        }))
    end
}
SMODS.Back {
    key = "deck_stasis",
    loc_txt = {
        name = "Stasis Deck",
        text = {
            'The coldest reaches of your mind;',
            'you are steeled against the',
            'temptations of the Dark, unwavering.'
        }
    },
    pos = { x = 1, y = 3 },
    unlocked = true,
    apply = function(self, back)
        local tf = {
            true,
            true,
            true,
            false
        }
        local enhancements = {
            G.P_CENTERS.m_fm_shatter, -- Stasis
            G.P_CENTERS.m_fm_freeze,
            G.P_CENTERS.m_fm_slow,
            G.P_CENTERS.m_fm_stasis_crystal
        }
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if pseudorandom_element(tf, pseudoseed('Idk')) then
                        v:set_ability(pseudorandom_element(enhancements, pseudoseed('Break Through')))
                    end
                end
                return true
            end
        }))
    end
}
SMODS.Back {
    key = "deck_strand",
    loc_txt = {
        name = "Strand Deck",
        text = {
            'The minds of every iota',
            'of being sing to you;',
            'and you will wield it',
            'so, with it weaving and',
            'dancing through your fingers.'
        }
    },
    pos = { x = 1, y = 3 },
    unlocked = true,
    apply = function(self, back)
        local tf = {
            true,
            true,
            true,
            false
        }
        local enhancements = {
            G.P_CENTERS.m_fm_wovenmail, -- Strand
            G.P_CENTERS.m_fm_tangle,
            G.P_CENTERS.m_fm_unravel,
            G.P_CENTERS.m_fm_suspend
        }
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if pseudorandom_element(tf, pseudoseed('Idk')) then
                        v:set_ability(pseudorandom_element(enhancements, pseudoseed('Break Through')))
                    end
                end
                return true
            end
        }))
    end
}
SMODS.Back {
    key = "deck_resonant",
    loc_txt = {
        name = "Resonance Deck",
        text = {
            "You wear a commanding presence",
            "like a cloak; you will bring",
            "about unbound subjugation and",
            "domination for all to witness."
        }
    },
    pos = { x = 1, y = 3 },
    unlocked = true,
    apply = function(self, back)
        local tf = {
            true,
            true,
            true,
            false
        }
        local enhancements = {
            G.P_CENTERS.m_fm_resonant, -- Resonant
            G.P_CENTERS.m_fm_finalized,
            G.P_CENTERS.m_fm_dissected,
            G.P_CENTERS.m_fm_rooted
        }
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if pseudorandom_element(tf, pseudoseed('Idk')) then
                        v:set_ability(pseudorandom_element(enhancements, pseudoseed('Resonant')))
                    end
                end
                return true
            end
        }))
    end
}
SMODS.Back {
    key = "deck_prismatic",
    loc_txt = {
        name = "Prismatic Deck",
        text = {
            "You have braved the temptations of the",
            "Dark and the chaos of the Light;",
            "your greatness have been made known",
            "by gods of the Sky and the Deep."
        }
    },
    pos = { x = 1, y = 3 },
    unlocked = true,
    apply = function(self, back)
        local tf = {
            true,
            true,
            false
        }
        local enhancements = {
            G.P_CENTERS.m_fm_radiant,-- Solar
            G.P_CENTERS.m_fm_scorch,
            G.P_CENTERS.m_fm_restoration,
            G.P_CENTERS.m_fm_cure,
            G.P_CENTERS.m_fm_overshield, -- Void
            G.P_CENTERS.m_fm_volatile,
            G.P_CENTERS.m_fm_devour,
            G.P_CENTERS.m_fm_suppress,
            G.P_CENTERS.m_fm_amplified, -- Arc
            G.P_CENTERS.m_fm_jolt,
            G.P_CENTERS.m_fm_blinded,
            G.P_CENTERS.m_fm_bolt_charge,
            G.P_CENTERS.m_fm_shatter, -- Stasis
            G.P_CENTERS.m_fm_freeze,
            G.P_CENTERS.m_fm_slow,
            G.P_CENTERS.m_fm_stasis_crystal,
            G.P_CENTERS.m_fm_wovenmail, -- Strand
            G.P_CENTERS.m_fm_tangle,
            G.P_CENTERS.m_fm_unravel,
            G.P_CENTERS.m_fm_suspend,
            G.P_CENTERS.m_fm_resonant, -- Resonant
            G.P_CENTERS.m_fm_finalized,
            G.P_CENTERS.m_fm_dissected,
            G.P_CENTERS.m_fm_rooted
        }
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.playing_cards) do
                    if v.base.value == 'Ace' then
                        v:set_ability(G.P_CENTERS.m_fm_transcendent)
                    else
                        if pseudorandom_element(tf, pseudoseed('Idk')) then
                            v:set_ability(pseudorandom_element(enhancements, pseudoseed('Break Through')))
                        end
                    end
                end
                return true
            end
        }))
    end
}
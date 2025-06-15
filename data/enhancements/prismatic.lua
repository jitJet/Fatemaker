SMODS.Enhancement {
    key = "transcendent",
    loc_txt = {
        name = "Transcendent",
        text = {
            "{X:dark_edition,C:white}PRISMATIC{}",
            "When scored, either {C:attention}triple{} the lower",
            "value between scored {C:chips}Chips{} or {C:mult}Mult{},",
            "or gain {X:mult,C:white}X1.5{} Mult for each",
            "Light, Dark or Prismatic card played"
        }
    },
    atlas = 'Enhancements',
    config = {
        extra = {
            denom = 2
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.denom } }
    end,
    pos = {x=0, y=2},
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.main_scoring then
            local hand_chips = G.GAME.current_round.current_hand.chips or 0
            local hand_mult = G.GAME.current_round.current_hand.mult or 0
           
            if pseudorandom('finalized') < G.GAME.probabilities.normal / card.ability.extra.denom then
                if hand_chips < hand_mult then
                    return {
                        chips = hand_chips * 2,
                        message = "X3 Scored Chips",
                        sound = "fm_transcendent",
                        colour = G.C.DARK_EDITION
                    }
                else
                    return {
                        mult = hand_mult * 2,
                        message = "X3 Scored Mult",
                        sound = "fm_transcendent",
                        colour = G.C.DARK_EDITION
                    }
                end
            else
                local special_count = 0
                for _, playedCard in ipairs(context.scoring_hand) do
                    if playedCard.config.center == G.P_CENTERS.m_fm_transcendent or
                       playedCard.config.center == G.P_CENTERS.m_fm_slow or
                       playedCard.config.center == G.P_CENTERS.m_fm_freeze or
                       playedCard.config.center == G.P_CENTERS.m_fm_stasis_crystal or
                       playedCard.config.center == G.P_CENTERS.m_fm_shatter or
                       playedCard.config.center == G.P_CENTERS.m_fm_unravel or
                       playedCard.config.center == G.P_CENTERS.m_fm_wovenmail or
                       playedCard.config.center == G.P_CENTERS.m_fm_tangle or
                       playedCard.config.center == G.P_CENTERS.m_fm_suspend or
                       playedCard.config.center == G.P_CENTERS.m_fm_resonant or
                       playedCard.config.center == G.P_CENTERS.m_fm_rooted or
                       playedCard.config.center == G.P_CENTERS.m_fm_finalized or
                       playedCard.config.center == G.P_CENTERS.m_fm_dissected or
                       playedCard.config.center == G.P_CENTERS.m_fm_radiant or
                       playedCard.config.center == G.P_CENTERS.m_fm_cure or
                       playedCard.config.center == G.P_CENTERS.m_fm_restoration or
                       playedCard.config.center == G.P_CENTERS.m_fm_scorch or
                       playedCard.config.center == G.P_CENTERS.m_fm_blinded or
                       playedCard.config.center == G.P_CENTERS.m_fm_amplified or
                       playedCard.config.center == G.P_CENTERS.m_fm_bolt_charge or
                       playedCard.config.center == G.P_CENTERS.m_fm_jolt or
                       playedCard.config.center == G.P_CENTERS.m_fm_volatile or
                       playedCard.config.center == G.P_CENTERS.m_fm_devour or
                       playedCard.config.center == G.P_CENTERS.m_fm_overshield or
                       playedCard.config.center == G.P_CENTERS.m_fm_suppress then
                        special_count = special_count + 1
                    end
                end
               
                if special_count > 0 then
                    return {
                        x_mult = 1.5 * special_count,
                        message = "Transcended!",
                        sound = "fm_transcendent",
                        colour = G.C.DARK_EDITION
                    }
                end
            end
        end
    end
}
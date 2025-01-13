SMODS.Joker{
    key = "balance",
    loc_txt = {
        name = "Facet of Balance",
        text = {
            "If the total Chip or Mult amount",
            "is lower than the other, {C:attention}sacrifice",
            "half of the higher amount{} to be added",
            "to the lower amount"
        }
    },
    atlas = 'Jokers',
    rarity = 2,
    cost = 4,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    pos = {x=0, y=0},
    calculate = function(self, card, context)
        if context.joker_main then
            if hand_chips > mult then
                local halved_chips = hand_chips / 2
                hand_chips = hand_chips - halved_chips
                mult = mult + halved_chips
                update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
                return {
                    message = "+" .. halved_chips .. " Mult",
                    colour = G.C.MULT,
                    card = card
                }
            elseif hand_chips < mult then
                local halved_mult = mult / 2
                mult = mult - halved_mult
                hand_chips = hand_chips + halved_mult
                update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
                return {
                    message = "+" .. halved_mult,
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
    end
}
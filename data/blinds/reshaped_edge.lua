SMODS.Sticker {
    key = "pyramidal_resonance",
    loc_txt = {
        name = "Pyramidal Resonance",
        text = { 
            "The Witness notices",
            "your actions." 
        }
    },
    atlas = "Stickers",
    pos = {x = 0, y = 1},
    default_compat = true,
    draw = function(self, card, layer)
        local t = G.TIMERS.REAL
        local cycle = math.sin(0.5 * t) -- Smoother cycle
        local pulse = 0.5 + 0.3 * cycle
        local pulse2 = 0.1 + 0.3 * cycle
        local pulse2 = 0.05 + 0.3 * cycle
        local alpha = 0.7 * (1 - math.abs(cycle)) -- Fade with cycle
        
        G.shared_stickers[self.key].role.draw_major = card
        
        -- Outer glow
        G.shared_stickers[self.key]:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse, 0, alpha * 0.4)
        G.shared_stickers[self.key]:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse2, 0, alpha * 0.5)
        G.shared_stickers[self.key]:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse3, 0, alpha * 0.6)
        
        -- -- Main triangle
        -- G.shared_stickers[self.key]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse * 0.9, 0, alpha)
        
        -- Inner shine effect
        G.shared_stickers[self.key]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse * 0.8, 0, alpha * 0.6)
    end
}

SMODS.Sticker {
    key = "spherical_resonance",
    loc_txt = {
        name = "Spherical Resonance",
        text = { 
            "The Witness notices",
            "your actions." 
        }
    },
    atlas = "Stickers",
    pos = {x = 1, y = 1},
    default_compat = true,
    draw = function(self, card, layer)
        local t = G.TIMERS.REAL
        local cycle = math.sin(0.5 * t) -- Smoother cycle
        local pulse = 0.5 + 0.3 * cycle
        local pulse2 = 0.1 + 0.3 * cycle
        local pulse2 = 0.05 + 0.3 * cycle
        local alpha = 0.7 * (1 - math.abs(cycle)) -- Fade with cycle
        
        G.shared_stickers[self.key].role.draw_major = card
        
        -- Outer glow
        G.shared_stickers[self.key]:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse, 0, alpha * 0.4)
        G.shared_stickers[self.key]:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse2, 0, alpha * 0.5)
        G.shared_stickers[self.key]:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse3, 0, alpha * 0.6)
        
        -- -- Main triangle
        -- G.shared_stickers[self.key]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse * 0.9, 0, alpha)
        
        -- Inner shine effect
        G.shared_stickers[self.key]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse * 0.8, 0, alpha * 0.6)
    end
}

SMODS.Sticker {
    key = "hexahedral_resonance",
    loc_txt = {
        name = "Hexahedral Resonance",
        text = { 
            "The Witness notices",
            "your actions." 
        }
    },
    atlas = "Stickers",
    pos = {x = 2, y = 1},
    default_compat = true,
    draw = function(self, card, layer)
        local t = G.TIMERS.REAL
        local cycle = math.sin(0.5 * t) -- Smoother cycle
        local pulse = 0.5 + 0.3 * cycle
        local pulse2 = 0.1 + 0.3 * cycle
        local pulse2 = 0.05 + 0.3 * cycle
        local alpha = 0.7 * (1 - math.abs(cycle)) -- Fade with cycle
        
        G.shared_stickers[self.key].role.draw_major = card
        
        -- Outer glow
        G.shared_stickers[self.key]:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse, 0, alpha * 0.4)
        G.shared_stickers[self.key]:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse2, 0, alpha * 0.5)
        G.shared_stickers[self.key]:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse3, 0, alpha * 0.6)
        
        -- -- Main triangle
        -- G.shared_stickers[self.key]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse * 0.9, 0, alpha)
        
        -- Inner shine effect
        G.shared_stickers[self.key]:draw_shader('voucher', nil, card.ARGS.send_to_shader, nil, card.children.center, pulse * 0.8, 0, alpha * 0.6)
    end
}
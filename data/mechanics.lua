Fatemaker.open_mechanics_area = function(forced, open, delay_close)
    if open and not Fatemaker.mechanics_area_open then
        Fatemaker.mechanics_area_open = true
        Fatemaker.mechanics_area_forced = Fatemaker.mechanics_area_forced or forced and true
        G.E_MANAGER:add_event(Event({
            blockable = false,
            func = function()
                G.jokers.states.visible = false
                G.consumeables.states.visible = false
                G.fatemaker_mechanics_area.states.visible = true
                G.fatemaker_mechanics_area.alignment.offset.y = 0
                return true
            end
        }))
    elseif not open and (not Fatemaker.mechanics_area_forced or forced) and Fatemaker.mechanics_area_open then
        Fatemaker.mechanics_area_open = false
        Fatemaker.mechanics_area_forced = false
        G.E_MANAGER:add_event(Event({
            blockable = false,
            trigger = "after",
            delay = 0.15 + (delay_close or 0),
            func = function()
                G.E_MANAGER:add_event(Event({
                    trigger = "ease",
                    delay = 0.5,
                    ref_table = G.fatemaker_mechanics_area.alignment.offset,
                    ref_value = "y",
                    ease_to = -5,
                }))
                G.E_MANAGER:add_event(Event({
                    blockable = false,
                    trigger = "after",
                    delay = 0.5,
                    func = function()
                        G.consumeables.states.visible = true
                        G.jokers.states.visible = true
                        G.fatemaker_mechanics_area.alignment.offset.y = -5
                        G.fatemaker_mechanics_area.states.visible = false
                        G.mechanic_sprites:unhighlight_all()
                        return true
                    end
                }))
                return true
            end
        }))
    end
end

G.FUNCS.fatemaker_open_mechanics_area = function(e)
    Fatemaker.open_mechanics_area(true, not G.fatemaker_mechanics_area.states.visible)
end

G.FUNCS.fatemaker_show_mechanics_area = function(e)
    if Fatemaker.mechanic_sprites and #Fatemaker.mechanic_sprites.cards > 0 then
        G.GAME.fatemaker_show_mechanics_area = true
    end
    if G.GAME.fatemaker_show_mechanics_area then
        e.states.visible = true
    else
        e.states.visible = false
    end
end

-- local start_run_ref = Game.start_run
-- function Game:start_run(args)
--     self.GAME.starting_params.mechanic_slots = 5
--     self.mechanic_sprites = CardArea(0, 0, G.CARD_W * 7, 0.95 * G.CARD_H, {
--         card_limit = self.GAME.starting_params.mechanic_slots,
--         type = "mechanic_sprites",
--         highlight_limit = 1
--     })
--     G.mechanic_sprites = self.mechanic_sprites

--     start_run_ref(self, args)

--     set_screen_positions()

--     self.fatemaker_mechanics_area = UIBox {
--         definition = Fatemaker.create_UIBox_mechanics(),
--         config = { align = 'cmi', offset = { x = 2.4, y = -5 }, major = self.jokers, bond = 'Weak' }
--     }
--     self.fatemaker_mechanics_area.states.visible = false
--     G.GAME.fatemaker_show_mechanics_area = G.GAME.fatemaker_show_mechanics_area or false

--     Fatemaker.mechanics_area_open = false
--     Fatemaker.mechanics_area_forced = false
-- end

local start_run_ref = Game.start_run
function Game:start_run(args)
    self.fm_mechanic_sprites = CardArea(
        0, 0,
        self.CARD_W * 7,
        self.CARD_H * 0.95,
        {
            card_limit = 5,
            type = 'mechanic_sprites',
            highlight_limit = 1,
        }
    )
    Fatemaker.mechanic_sprites = self.fm_mechanic_sprites
    G.mechanic_sprites = self.fm_mechanic_sprites

    start_run_ref(self, args)

    Fatemaker.mechanic_sprites.config.card_limit = self.GAME.modifiers["fm_mechanic_slots"] or
        Fatemaker.mechanic_sprites.config.card_limit or 5

    self.fatemaker_mechanics_area = UIBox {
        definition = Fatemaker.create_UIBox_mechanics(),
        config = { align = 'cmi', offset = { x = 2.4, y = -5 }, major = self.jokers, bond = 'Weak' }
    }
    self.fatemaker_mechanics_area.states.visible = false
    G.GAME.fatemaker_show_mechanics_area = G.GAME.fatemaker_show_mechanics_area or false

    Fatemaker.mechanics_area_open = false
    Fatemaker.mechanics_area_forced = false

    Fatemaker.mechanic_sprites.T.x = G.consumeables.T.x + 2.3
    Fatemaker.mechanic_sprites.T.y = G.consumeables.T.y + 3
end


local set_screen_positions_ref = set_screen_positions
function set_screen_positions()
    set_screen_positions_ref()

    if G.mechanic_sprites then -- setting the position of the area
        G.mechanic_sprites.T.x = G.TILE_W - G.mechanic_sprites.T.w - 5
        G.mechanic_sprites.T.y = 3
        G.mechanic_sprites:hard_set_VT()
    end
end

local card_highlight_ref = Card.highlight
function Card:highlight(is_higlighted)
    card_highlight_ref(self, is_higlighted)

    if (self.ability.set == "Mechanic Sprites" and self.ability.progress) or (self.area and self.area == G.pack_cards) then
        if self.highlighted and self.area and self.area.config.type ~= 'shop' then
            local x_off = (self.ability.consumeable and -0.1 or 0)
            self.children.use_button = UIBox{
                definition = G.UIDEF.use_and_sell_buttons(self), 
                config = {align=
                        ((self.area == G.jokers) or (self.area == G.consumeables) or (self.area == G.mechanic_sprites)) and "cr" or
                        "bmi" -- need to check if the area is yours too, to show use/sell buttons in the right place
                    , offset = 
                        ((self.area == G.jokers) or (self.area == G.consumeables) or (self.area == G.mechanic_sprites)) and {x=x_off - 0.4,y=0} or
                        {x=0,y=0.65}, -- same here
                    parent =self}
            }
        elseif self.children.use_button then
            self.children.use_button:remove()
            self.children.use_button = nil
        end
    end
end

Fatemaker.create_UIBox_mechanics = function()
    local t = {
        n = G.UIT.ROOT,
        config = { align = 'cm', r = 0.1, colour = G.C.CLEAR, padding = 0.2 },
        nodes = {
            {
                n = G.UIT.O,
                config = {
                    object = G.mechanic_sprites,
                    draw_layer = 1
                }
            },
        }
    }
    return t
end

local cardarea_draw_ref = CardArea.draw
function CardArea:draw()
    cardarea_draw_ref(self)
    if self.config.type == 'mechanic_sprites' then
        for k, v in ipairs(self.ARGS.draw_layers) do
            for i = 1, #self.cards do
                if self.cards[i] ~= G.CONTROLLER.focused.target then
                    if not self.cards[i].highlighted then
                        if G.CONTROLLER.dragging.target ~= self.cards[i] then self.cards[i]:draw(v) end
                    end
                end
            end
            for i = 1, #self.cards do
                if self.cards[i] ~= G.CONTROLLER.focused.target then
                    if self.cards[i].highlighted then
                        if G.CONTROLLER.dragging.target ~= self.cards[i] then self.cards[i]:draw(v) end
                    end
                end
            end
        end
    end
end

local cardarea_align_cards_ref = CardArea.align_cards
function CardArea:align_cards()
    if self.config.type == 'mechanic_sprites' then
        for k, card in ipairs(self.cards) do
            if not card.states.drag.is then
                card.T.r = 0.1 * (- #self.cards / 2 - 0.5 + k) / (#self.cards) +
                    (G.SETTINGS.reduced_motion and 0 or 1) * 0.02 * math.sin(2 * G.TIMERS.REAL + card.T.x)
                local max_cards = math.max(#self.cards, self.config.temp_limit)
                card.T.x = self.T.x +
                    (self.T.w - self.card_w) *
                    ((k - 1) / math.max(max_cards - 1, 1) - 0.5 * (#self.cards - max_cards) / math.max(max_cards - 1, 1)) +
                    0.5 * (self.card_w - card.T.w)
                if #self.cards > 2 or (#self.cards > 1 and self.config.spread) then
                    card.T.x = self.T.x + (self.T.w - self.card_w) * ((k - 1) / (#self.cards - 1)) +
                        0.5 * (self.card_w - card.T.w)
                elseif #self.cards > 1 then
                    card.T.x = self.T.x + (self.T.w - self.card_w) * ((k - 0.5) / (#self.cards)) +
                        0.5 * (self.card_w - card.T.w)
                else
                    card.T.x = self.T.x + self.T.w / 2 - self.card_w / 2 + 0.5 * (self.card_w - card.T.w)
                end
                local highlight_height = G.HIGHLIGHT_H / 2
                if not card.highlighted then highlight_height = 0 end
                card.T.y = self.T.y + self.T.h / 2 - card.T.h / 2 - highlight_height +
                    (G.SETTINGS.reduced_motion and 0 or 1) * 0.03 * math.sin(0.666 * G.TIMERS.REAL + card.T.x)
                card.T.x = card.T.x + card.shadow_parrallax.x / 30
            end
        end
        table.sort(self.cards,
            function(a, b)
                return a.T.x + a.T.w / 2 - 100 * ((a.pinned and not a.ignore_pinned) and a.sort_id or 0) <
                    b.T.x + b.T.w / 2 - 100 * ((b.pinned and not b.ignore_pinned) and b.sort_id or 0)
            end)
    end
    cardarea_align_cards_ref(self)
end

-- 4. (Optional) Hook Card:highlight and CardArea:can_highlight if you want highlight/select support
local card_highlight_ref = Card.highlight
function Card:highlight(is_highlighted)
    if self.area and self.area.config.type == "mechanic_sprites" then
        self.highlighted = is_highlighted
        -- Add custom UIBox buttons here if needed
    else
        card_highlight_ref(self, is_highlighted)
    end
end

local cardarea_can_highlight_ref = CardArea.can_highlight
function CardArea:can_highlight(card)
    return self.config.type == 'mechanic_sprites' or cardarea_can_highlight_ref(self, card)
end


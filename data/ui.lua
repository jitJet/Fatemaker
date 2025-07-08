-- Mechanics button UI definition
function create_mechanics_button()
    local text_scale = 0.45
    local button_height = 1.3
    return {
        n = G.UIT.C,
        config = {
            id = 'mechanics_button',
            align = "tm",
            padding = 0.3,
            r = 0.1,
            minw = 2.5,
            minh = button_height,
            hover = true,
            colour = G.C.DARK_EDITION,
            button = "fatemaker_open_mechanics_area",
            shadow = true
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0},
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = "Mechanics",
                            scale = text_scale,
                            colour = G.C.UI.TEXT_LIGHT
                        }
                    }
                }
            }
        }
    }
end

-- Loadout button UI definition
function create_loadout_button()
    local text_scale = 0.45
    local button_height = 1.3
    return {
        n = G.UIT.C,
        config = {
            id = 'loadout_button',
            align = "tm",
            padding = 0.3,
            r = 0.1,
            minw = 2.5,
            minh = button_height,
            hover = true,
            colour = G.C.ORANGE,
            button = "loadout",
            shadow = true
        },
        nodes = {
            {
                n = G.UIT.R,
                config = {align = "cm", padding = 0},
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = "Loadout",
                            scale = text_scale,
                            colour = G.C.UI.TEXT_LIGHT
                        }
                    }
                }
            }
        }
    }
end

-- Main button row (excluding Mechanics)
local alias_create_UIBox_buttons = create_UIBox_buttons
function create_UIBox_buttons()
    local ui_box = alias_create_UIBox_buttons()
    -- Insert only the loadout button and spacing
    table.insert(ui_box.nodes, 1, create_loadout_button())
    if G.GAME and G.GAME.blind and G.GAME.blind.config.blind.key == "bl_fm_fallen_crypt" then
        -- Add the mechanics button only if the Fallen Crypt blind is active
        table.insert(ui_box.nodes, 2, create_mechanics_button())
    else
        -- Otherwise, just add a spacer
        table.insert(ui_box.nodes, 2, {
            n = G.UIT.C,
            config = {minw = 0.3},
            nodes = {}
        })
    end
    return ui_box
end

-- Main loadout UI definition
function G.UIDEF.loadout()
    return create_UIBox_generic_options({contents ={create_tabs(
        {tabs = {
            {
                label = "Subclass",
                chosen = true,
                tab_definition_function = create_UIBox_subclass,
            }
        },
        tab_h = 8,
        snap_to_nav = true})}})
end

-- Function to open the loadout menu
G.FUNCS.loadout = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
        definition = G.UIDEF.loadout(),
    }
end

-- Subclass tab creation
function create_UIBox_subclass()
    -- Create row for each subclass
    local subclass_rows = {}
    local subclasses = {"Strand", "Void", "Solar", "Arc", "Stasis", "Resonance"}
    local colors = {
        Strand = G.C.GREEN,
        Void = G.C.PURPLE, 
        Solar = G.C.ORANGE,
        Arc = G.C.BLUE,
        Stasis = G.C.SUITS.Spades,
        Resonance = G.C.BLACK
    }
 
    for _, subclass in ipairs(subclasses) do
        table.insert(subclass_rows, {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.05,
                r = 0.1,
                colour = G.GAME.selected_subclass == subclass and lighten(colors[subclass], 0.2) or darken(G.C.JOKER_GREY, 0.1),
                emboss = 0.05,
                hover = true,
                button = "select_subclass",
                button_args = {subclass = subclass}
            },
            nodes = {
                {n = G.UIT.C, config = {align = "cl", padding = 0.1, minw = 3}, nodes = {
                    {n = G.UIT.T, config = {text = subclass, scale = 0.5, colour = colors[subclass], shadow = true}}
                }}
            }
        })
    end
 
    return {
        n = G.UIT.ROOT,
        config = {align = "cm", padding = 0.1},
        nodes = {
            {n = G.UIT.C, config = {align = "cm"}, nodes = subclass_rows}
        }
    }
end

-- Main subclass row creation
function create_UIBox_subclass_row(subclass_name)
    local subclass_colors = {
        Strand = G.C.GREEN,
        Void = G.C.PURPLE,
        Solar = G.C.ORANGE,
        Arc = G.C.BLUE,
        Stasis = G.C.SUITS.Spades,
        Resonance = G.C.BLACK
    }
    
    return {
        n = G.UIT.R,
        config = {
            align = "cm",
            padding = 0.05,
            r = 0.1,
            colour = G.GAME.selected_subclass == subclass_name and lighten(G.C.JOKER_GREY, 0.2) or darken(G.C.JOKER_GREY, 0.1),
            emboss = 0.05,
            hover = true,
            force_focus = true,
            button = "select_subclass",
            button_args = subclass_name
        },
        nodes = {
            -- Subclass name and color bar
            {
                n = G.UIT.C,
                config = {
                    align = "cl",
                    padding = 0,
                    minw = 5
                },
                nodes = {
                    -- Color indicator
                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm",
                            padding = 0.01,
                            r = 0.1,
                            colour = subclass_colors[subclass_name],
                            minw = 1.5,
                            outline = 0.8,
                            outline_colour = G.C.WHITE
                        },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = subclass_name,
                                    scale = 0.5,
                                    colour = G.C.UI.TEXT_LIGHT,
                                    shadow = true
                                }
                            }
                        }
                    },
                    -- Description area
                    {
                        n = G.UIT.C,
                        config = {
                            align = "cm",
                            minw = 4.5,
                            maxw = 4.5
                        },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = " " .. get_subclass_description(subclass_name),
                                    scale = 0.45,
                                    colour = G.C.UI.TEXT_LIGHT,
                                    shadow = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
end

-- Doesn't work yet
G.FUNCS.select_subclass = function(e)
    -- Implement subclass button pressing logic later
    -- Maybe triggers some buffs or other shit idk
    G.FUNCS.overlay_menu{
        definition = G.UIDEF.loadout()
    }
end
 
-- Subclass descriptions
function get_subclass_description(subclass_name)
    local descriptions = {
        Strand = "test",
        Void = "test2",
        Solar = "test3",
        Arc = "test4",
        Stasis = "test5",
        Resonance = "test6"
    }
    return descriptions[subclass_name] or ""
end
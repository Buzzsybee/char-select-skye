-- name: [CS] Skye
-- description:

local TEXT_MOD_NAME = "[CS] Skye"

if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

local E_MODEL_SKYE = smlua_model_util_get_id("skye_geo")
local ICON_SKYE= get_texture_info("skye_icon")
local SKYE_GRAFFITI = get_texture_info("skye_graffiti")

local PALETTE_SKYE = {
    [PANTS]  = "212124",
    [SHIRT]  = "196467",
    [GLOVES] = "2C2C32",
    [SHOES]  = "25252C",
    [HAIR]   = "FFFFFF",
    [SKIN]   = "7A808F",
    [CAP]    = "FFFFFF",
	[EMBLEM] = "393C4A"
}

--[[
anims = {
    [charSelect.CS_ANIM_MENU] = 'SKYE_MENU_ANIM'
}
]]
_G.charSelect.character_add_palette_preset(E_MODEL_SKYE, PALETTE_SKYE)


CHAR_SKYE = _G.charSelect.character_add(
    "Skye", -- Character Name
    "", -- Description
    "Honi", -- Credits
    "393C4A",           -- Menu Color
    E_MODEL_SKYE,       -- Character Model
    CT_MARIO,           -- Override Character
    ICON_SKYE, -- Life Icon
    1.2
)

--if anims then charSelect.character_add_animations(E_MODEL_SKYE, anims) end
charSelect.character_add_graffiti(CHAR_SKYE, SKYE_GRAFFITI)

-- switch States

function rightSwitchC(node, maxStackIndex) 
    local asSwitchNode = cast_graph_node(node)
    local m = geo_get_mario_state()
    local toNode = 0

    if m.action == ACT_SKYE_ATTACK_RIGHT and m.actionTimer < 8 then
        toNode = 1
    else
        toNode = 0
    end
    asSwitchNode.selectedCase = toNode
end

function leftSwitchC(node, maxStackIndex) 
    local asSwitchNode = cast_graph_node(node)
    local m = geo_get_mario_state()
    local toNode = 0

    if m.action == ACT_SKYE_ATTACK_LEFT and m.actionTimer < 8 then
        toNode = 1
    else
        toNode = 0
    end
    asSwitchNode.selectedCase = toNode
end
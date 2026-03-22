-- just general utility functions that are handy when i make me codees
-- usually just changing the state table name is enough to use this as a template for other movesets,, is this good practice X3?
--stuff will go unused as i use this ro moveset to moveset, will be there still just in case.

gSkyeStates = {}
function reset_skye_states(index)
    if index == nil then index = 0 end
    gSkyeStates[index] = {
        index = network_global_index_from_local(0),
        actionTick = 0,
        prevFrameAction = 0,
        northTimer = 0,
        southTimer = 0,
        eastTimer = 0,
        westTimer = 0,
        spinTimer = 0,

        lastSpeed = 0,

        gfxAngleX = 0,
        gfxAngleY = 0,
        gfxAngleZ = 0,

        canDoubleJumpAir = true,
        canDash = true
    }
end

for i = 0, (MAX_PLAYERS - 1) do
    reset_skye_states(i)
end
charSelect.character_hook_moveset(CHAR_SKYE, HOOK_ON_LEVEL_INIT, reset_skye_states)

c = gMarioStates[0] -- just in case m doesnt exist,,

-- using this to normalize air actions to only be doable in this acts
jumpActs = {
    ACT_JUMP,
    ACT_DOUBLE_JUMP,
    ACT_TRIPLE_JUMP,
    ACT_BACKFLIP,
    ACT_SIDE_FLIP,
    ACT_LONG_JUMP,
    ACT_WALL_KICK_AIR,
    ACT_JUMP_KICK,
    ACT_FREEFALL,
    ACT_WATER_JUMP,
    ACT_STEEP_JUMP,
    ACT_TOP_OF_POLE_JUMP,
    ACT_GROUND_POUND,
    ACT_DIVE,
    ACT_SKYE_DOUBLE_JUMP,
    ACT_SKYE_DASH_AIR,
}
jumpAct = {}
for _, v in ipairs(jumpActs) do
    jumpAct[v] = true
end

-- prevents sequence breaks,,
excludeGroundAttackActs = {
    ACT_GROUND_BONK,
    ACT_BACKWARD_GROUND_KB,
    ACT_FORWARD_GROUND_KB,
    ACT_SOFT_BACKWARD_GROUND_KB,
    ACT_SOFT_FORWARD_GROUND_KB,
    ACT_STAR_DANCE_EXIT,
    ACT_STAR_DANCE_NO_EXIT,
    ACT_CREDITS_CUTSCENE,
    ACT_BUTT_STUCK_IN_GROUND,
    ACT_HOLD_BEGIN_SLIDING,
    ACT_HOLD_HEAVY_IDLE,
    ACT_UNLOCKING_STAR_DOOR,
    ACT_READING_SIGN,
    ACT_READING_NPC_DIALOG,
    ACT_PULLING_DOOR,
    ACT_PUTTING_ON_CAP,
    ACT_PUSHING_DOOR,
    ACT_HOLDING_BOWSER,
    ACT_HOLD_HEAVY_WALKING,
    ACT_HOLD_IDLE,
    ACT_HOLD_STOMACH_SLIDE,
    ACT_HOLD_WALKING,
    ACT_DIVE_SLIDE,
    ACT_DIVE_PICKING_UP,
    ACT_BUTT_SLIDE,
    ACT_STOMACH_SLIDE,
    ACT_UNLOCKING_KEY_DOOR,
    ACT_RIDING_SHELL_GROUND,
    ACT_READING_AUTOMATIC_DIALOG,
    ACT_EXIT_LAND_SAVE_DIALOG,
    ACT_DEATH_EXIT,
    ACT_DEATH_EXIT_LAND,
    ACT_DISAPPEARED,
    ACT_TELEPORT_FADE_IN,
    ACT_TELEPORT_FADE_OUT,
    ACT_ENTERING_STAR_DOOR,
    ACT_HARD_BACKWARD_GROUND_KB,
    ACT_HARD_FORWARD_GROUND_KB,
    ACT_SPECIAL_DEATH_EXIT,
    ACT_WARP_DOOR_SPAWN,
}

excludeGroundAttackAct = {}
for _, v in ipairs(excludeGroundAttackActs) do
    excludeGroundAttackAct[v] = true
end

damagedActs = {
    ACT_SOFT_BACKWARD_GROUND_KB,
    ACT_SOFT_FORWARD_GROUND_KB,
    ACT_BACKWARD_AIR_KB,
    ACT_BACKWARD_GROUND_KB,
    ACT_BACKWARD_WATER_KB,
    ACT_FORWARD_WATER_KB,
    ACT_HARD_BACKWARD_AIR_KB,
    ACT_HARD_FORWARD_AIR_KB,
    ACT_DEATH_ON_BACK,
    ACT_THROWN_BACKWARD,
    ACT_THROWN_FORWARD,
}

damagedAct = {}
for _, v in ipairs(damagedActs) do
    damagedAct[v] = true
end

starActs = {
    ACT_STAR_DANCE_EXIT,
    ACT_STAR_DANCE_NO_EXIT,
    ACT_STAR_DANCE_WATER,
    ACT_JUMBO_STAR_CUTSCENE
}
starAct = {}
for _, v in ipairs(starActs) do
    starAct[v] = true
end

function convert_s16(num)
    local min = -32768
    local max = 32767
    while (num < min) do
        num = max + (num - min)
    end
    while (num > max) do
        num = min + (num - max)
    end
    return num
end

-- iunno if this is the same as convert_s16... :<
function s16(x)
    x = (math.floor(x) & 0xFFFF)
    if x >= 32768 then return x - 65536 end
    return x
end

function deg_to_hex(x)
    return x * 0x10000 / 360
end

function spawn_particle(m, particle)
    m.particleFlags = m.particleFlags | particle
end

-- controller button variables for simplicity :3
function init_buttons()
    buttonP = c.controller.buttonPressed
    buttonD = c.controller.buttonDown

    buttonApress = c.controller.buttonPressed & A_BUTTON ~= 0
    buttonBpress = c.controller.buttonPressed & B_BUTTON ~= 0
    buttonXpress = c.controller.buttonPressed & X_BUTTON ~= 0
    buttonYpress = c.controller.buttonPressed & Y_BUTTON ~= 0
    buttonZpress = c.controller.buttonPressed & Z_TRIG ~= 0
    buttonAdown = c.controller.buttonDown & A_BUTTON ~= 0
    buttonBdown = c.controller.buttonDown & B_BUTTON ~= 0
    buttonXdown = c.controller.buttonDown & X_BUTTON ~= 0
    buttonYdown = c.controller.buttonDown & Y_BUTTON ~= 0
    buttonZdown = c.controller.buttonDown & Z_TRIG ~= 0
end

-- using this to simplify an action midair that should let you ground pound or any other stuff
function make_actionable_air(m)
    if e.actionTick > 0 then
        if buttonZpress then
            set_mario_action(m, ACT_GROUND_POUND, 0)
        end
    end
end

function is_grounded(m)
    if m.floorHeight == m.pos.y then
        return true
    end
    return false
end

function get_current_speed(m)
    return math.sqrt((m.vel.x * m.vel.x) + (m.vel.z * m.vel.z))
end

function set_turn_speed(speed)
    c.faceAngle.y = c.intendedYaw - approach_s32(intendedYawbutcoolig, 0, speed, speed)
end

function init_locals(m)
    init_buttons()
    e = gSkyeStates[m.playerIndex]
    mag = m.controller.stickMag / 64
    intendedYawbutcoolig = s16(m.intendedYaw - m.faceAngle.y)
    action = c.action 
end

---@param c MarioState
function determine_stick_spin(c)
    init_locals(c)
    local NorthorSouth = false

    if (c.intendedYaw >= deg_to_hex(-180) and c.intendedYaw <= deg_to_hex(-135)) or (c.intendedYaw >= deg_to_hex(135) and c.intendedYaw <= deg_to_hex(180)) then
        NorthorSouth = true
        e.northTimer = 9
    end
    if (c.intendedYaw >= deg_to_hex(-45) and c.intendedYaw <= deg_to_hex(45)) then
        e.southTimer = 9
        NorthorSouth = true
    end
    if (c.intendedYaw >= deg_to_hex(-135) and c.intendedYaw <= deg_to_hex(-45) and not NorthorSouth) then
        e.westTimer = 9
    end
    if (c.intendedYaw >= deg_to_hex(45) and c.intendedYaw <= deg_to_hex(135) and not NorthorSouth) then
        e.eastTimer = 9
    end

    if e.northTimer > 0 then
        e.northTimer = e.northTimer - 1
    end
    if e.southTimer > 0 then
        e.southTimer = e.southTimer - 1
    end
    if e.eastTimer > 0 then
        e.eastTimer = e.eastTimer - 1
    end
    if e.westTimer > 0 then
        e.westTimer = e.westTimer - 1
    end

    if e.northTimer > 0 and e.southTimer > 0 and e.eastTimer > 0 and e.westTimer > 0 then
        e.spinTimer = 5
    elseif e.spinTimer > 0 then
        e.spinTimer = e.spinTimer - 1
    end
end

function check_spin(c)
    local e = gSkyeStates[c.playerIndex]
    if e.spinTimer > 0 then
        return true
    end
    return false
end
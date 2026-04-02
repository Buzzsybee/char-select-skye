if not charSelectExists then return end

ACT_SKYE_DOUBLE_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_AIR | ACT_FLAG_CONTROL_JUMP_HEIGHT)
ACT_SKYE_DASH_GROUND = allocate_mario_action(ACT_FLAG_MOVING | ACT_GROUP_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_SKYE_DASH_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_MOVING | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_WALL_SLIDE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_SKYE_ATTACK_RIGHT = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
ACT_SKYE_ATTACK_LEFT = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING)

---comment
---@param m MarioState
function act_skye_double_jump(m)
    init_locals(m)
    if m.actionTimer == 0 then
        m.vel.y = 40
        play_character_sound(m, CHAR_SOUND_YAHOO)
        set_character_animation(m, CHAR_ANIM_FORWARD_SPINNING)
        spawn_particle(m, PARTICLE_MIST_CIRCLE)
        m.faceAngle.y = m.intendedYaw
    end

    local airstep = perform_air_step(m, 0)
    if airstep == AIR_STEP_LANDED then set_mario_action(m, ACT_IDLE, 0) end
    if airstep == AIR_STEP_HIT_WALL then set_mario_action(m, ACT_SOFT_BONK, 0) end

    check_kick_or_dive_in_air(m)

    e.canDoubleJumpAir = false
    m.actionTimer = m.actionTimer + 1
    return false
end
hook_mario_action(ACT_SKYE_DOUBLE_JUMP, {every_frame = act_skye_double_jump})

---comment
---@param m MarioState
function act_skye_dash_air(m)
    init_locals(m)
    if m.actionTimer == 0 then
        m.vel.y = 0
        spawn_particle(m, PARTICLE_VERTICAL_STAR)
        play_character_sound(m, CHAR_SOUND_HOOHOO)
        smlua_anim_util_set_animation(m.marioObj, DASH_ANIM_SKYE)
        m.faceAngle.y = m.intendedYaw
    end

    airstep = perform_air_step(m, 0)
    if airstep == AIR_STEP_LANDED then set_mario_action(m, ACT_IDLE, 0) end
    if airstep == AIR_STEP_HIT_WALL then set_mario_action(m, ACT_BACKWARD_AIR_KB, 0) end

    mario_set_forward_vel(m, 60)
    make_actionable_air(m)

    e.canDash = false

    m.actionTimer = m.actionTimer + 1
    return false
end
hook_mario_action(ACT_SKYE_DASH_AIR, {every_frame = act_skye_dash_air})

local function act_skye_dash_ground(m)
    init_locals(m)
    if m.actionTimer == 0 then
        play_character_sound(m, CHAR_SOUND_HOOHOO)
    end
    set_character_animation(m, CHAR_ANIM_SLIDE_KICK)
    smlua_anim_util_set_animation(m.marioObj, DASH_ANIM_SKYE)

    local step = perform_ground_step(m)
    if step == GROUND_STEP_LEFT_GROUND then set_mario_action(m, ACT_FREEFALL, 0) end
    mario_set_forward_vel(m, 60)
    spawn_particle(m, PARTICLE_DUST)

    if buttonApress then set_jump_from_landing(m) end

    if m.actionTimer > 10 then set_mario_action(m, ACT_WALKING, 0) end
    m.actionTimer = m.actionTimer + 1
    e.canDash = false
    return false
end
hook_mario_action(ACT_SKYE_DASH_GROUND, {every_frame = act_skye_dash_ground})

local function act_wall_slide(m)
    init_locals(m)

    mario_set_forward_vel(m, -2.0)

    common_air_action_step(m, ACT_FREEFALL, CHAR_ANIM_START_WALLKICK, STEP_TYPE_AIR)

    if m.wall == nil and e.actionTick > 5 then
        mario_set_forward_vel(m, 0.0)
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if buttonD & Z_TRIG ~= 0 then
        set_mario_action(m, ACT_FREEFALL, 0)
        return
    end

    if e.actionTick > 2 then
        m.vel.y = m.vel.y * 0.9
        spawn_particle(m, PARTICLE_DUST)
        play_sound(SOUND_MOVING_TERRAIN_SLIDE + m.terrainSoundAddend, m.marioObj.header.gfx.cameraToObject)
    else
        m.vel.y = -2
    end

    if m.wall == nil and m.actionTimer > 5 then
        mario_set_forward_vel(m, 0.0)
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if buttonP & A_BUTTON ~= 0 then
        set_mario_action(m, ACT_WALL_KICK_AIR, 0)
    end
    m.wallKickTimer = 0
end
hook_mario_action(ACT_WALL_SLIDE, {every_frame=act_wall_slide})

local function act_skye_attack_right(m)
    init_locals(m)

    if m.actionTimer == 0 then
        play_character_sound(m, CHAR_SOUND_HRMM)
        m.faceAngle.y = m.intendedYaw
        set_mario_animation(m, CHAR_ANIM_FIRST_PUNCH)
        smlua_anim_util_set_animation(m.marioObj, 'SLASH_RIGHT')
    end

    mario_set_forward_vel(m, 20)
    step = perform_ground_step(m)

    if m.actionTimer == 5 then
        play_character_sound(m, CHAR_SOUND_GROUND_POUND_WAH)
        m.flags = m.flags | MARIO_KICKING
    end

    if buttonBpress and m.actionTimer > 4 then return set_mario_action(m, ACT_SKYE_ATTACK_LEFT, 0) end
    if m.actionTimer > 14 then set_mario_action(m, ACT_IDLE, 0) end

    m.actionTimer = m.actionTimer + 1

    return false
end
hook_mario_action(ACT_SKYE_ATTACK_RIGHT, {every_frame=act_skye_attack_right}, INT_KICK)

local function act_skye_attack_left(m)
    init_locals(m)

    if m.actionTimer == 0 then
        play_character_sound(m, CHAR_SOUND_HRMM)
        m.faceAngle.y = m.intendedYaw
        set_mario_animation(m, CHAR_ANIM_SECOND_PUNCH)
        smlua_anim_util_set_animation(m.marioObj, 'SLASH_LEFT')
    end

    mario_set_forward_vel(m, 20)
    step = perform_ground_step(m)
    
    if m.actionTimer == 2 then
        play_character_sound(m, CHAR_SOUND_GROUND_POUND_WAH)
        m.flags = m.flags | MARIO_KICKING
    end

    if buttonBpress and m.actionTimer > 4 then return set_mario_action(m, ACT_SKYE_ATTACK_RIGHT, 0) end
    if m.actionTimer > 14 then set_mario_action(m, ACT_IDLE, 0) end

    m.actionTimer = m.actionTimer + 1
    return false
end
hook_mario_action(ACT_SKYE_ATTACK_LEFT, {every_frame=act_skye_attack_left}, INT_KICK)

function check_double_jump_s(m)
    init_locals(m)

    if jumpAct[action] and e.canDoubleJumpAir and action ~= ACT_SKYE_DOUBLE_JUMP and e.actionTick > 0 then
        if buttonApress then set_mario_action(m, ACT_SKYE_DOUBLE_JUMP, 0) end
    end
end
function check_dash(m)
    init_locals(m)

    if m.pos.y > m.waterLevel then
        if is_grounded(m) and e.canDash and action ~= ACT_SKYE_DASH_GROUND and e.actionTick > 0 then
            if buttonXpress then set_mario_action(m, ACT_SKYE_DASH_GROUND, 0) end
        end

        if jumpAct[action] and e.canDash and action ~= ACT_SKYE_DASH_AIR and e.actionTick > 0 then
            if buttonXpress then set_mario_action(m, ACT_SKYE_DASH_AIR, 0) end
        end
    end
end

local function before_set_action(m, inc)
    init_locals(m)

    if inc == ACT_SOFT_BONK or (inc == ACT_BACKWARD_AIR_KB and (m.prevAction ~= ACT_DIVE and m.prevAction ~= ACT_LONG_JUMP)) then
        m.faceAngle.y = m.faceAngle.y + 0x8000
        m.marioObj.header.gfx.angle.y = m.faceAngle.y
        m.vel.y = 0
        m.vel.x = 0
        m.vel.z = 0

        return ACT_WALL_SLIDE
    end
end

local function on_set_action_skye(m)
    --attack starts on right always
    
end

local function before_update(m)
    init_locals(m)
    
    if (action == ACT_PUNCHING or action == ACT_MOVE_PUNCHING) then
        set_mario_action(m, ACT_SKYE_ATTACK_RIGHT, 0)
    end
end

---comment
---@param m MarioState
local function update_skye(m)
    init_locals(m)
    lastspeed = get_current_speed(m)

    -- Global Action Timer
    e.actionTick = e.actionTick + 1
    if e.prevFrameAction ~= m.action then
        e.prevFrameAction = m.action
        e.actionTick = 0
    end

    if is_grounded(m) then 
        e.canDoubleJumpAir = true 
        e.canDash = true
    end

    if action == ACT_WALL_KICK_AIR then
        if e.actionTick > 5 then 
            m.faceAngle.y = m.intendedYaw
            mario_set_forward_vel(m,lastspeed)
        end
    end

    if action == ACT_SKYE_DASH_AIR then m.marioBodyState.capState = 2 end

    check_double_jump_s(m)
    check_dash(m)

    if jumpAct[action] and action ~= ACT_BACKFLIP and action ~= ACT_WALL_KICK_AIR then mario_set_forward_vel(m, lastspeed or 0) end
end

charSelect.character_hook_moveset(CHAR_SKYE, HOOK_BEFORE_SET_MARIO_ACTION, before_set_action)
charSelect.character_hook_moveset(CHAR_SKYE, HOOK_ON_SET_MARIO_ACTION, on_set_action_skye)
charSelect.character_hook_moveset(CHAR_SKYE, HOOK_BEFORE_MARIO_UPDATE, before_update)
charSelect.character_hook_moveset(CHAR_SKYE, HOOK_MARIO_UPDATE, update_skye)
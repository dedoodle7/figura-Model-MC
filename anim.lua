-- =========================================
-- ANIMATION + SOUND SYSTEM
-- =========================================

local isSleeping = false
local isIdleEx = false
local isAction = false

local runCooldown = 0
local walkCooldown = 0
local hitCooldown = 0

local lastHealth = nil
local wasUsingItem = false
local wasSwinging = false
local wasOnGround = true

-- =========================================
-- LOCAL FUNCTIONS
-- =========================================

local function stopAllSpecialAnimations()

    animations.igni.sleep:stop()

    if animations.igni.sleepmeme then
        animations.igni.sleepmeme:stop()
    end

    if animations.igni.idleex then
        animations.igni.idleex:stop()
    end

    if animations.igni.action then
        animations.igni.action:stop()
    end
end

local function setSleep(state)

    isSleeping = state

    if state then
        isIdleEx = false
        isAction = false
    end

    stopAllSpecialAnimations()

    if isSleeping then
        animations.igni.sleep:play()
    end
end

local function setIdleEx(state)

    isIdleEx = state

    if state then
        isSleeping = false
        isAction = false
    end

    stopAllSpecialAnimations()

    if isIdleEx and animations.igni.idleex then
        animations.igni.idleex:play()
    end
end

local function setAction(state)

    isAction = state

    if state then
        isSleeping = false
        isIdleEx = false
    end

    stopAllSpecialAnimations()

    if isAction and animations.igni.action then
        animations.igni.action:play()
    end
end

-- =========================================
-- PINGS
-- =========================================

function pings.setSleep(state)
    setSleep(state)
end

function pings.setIdleEx(state)
    setIdleEx(state)
end

function pings.setAction(state)
    setAction(state)
end

function pings.playGlobalSound(sound, volume, pitch)

    if not player:isLoaded() then
        return
    end

    sounds:playSound(
        sound,
        player:getPos(),
        volume or 1,
        pitch or 1
    )
end

-- =========================================
-- ACTION WHEEL
-- =========================================

if host:isHost() then

    local page =
        action_wheel:newPage()

    action_wheel:setPage(page)

    -- =====================================
    -- TINKATON
    -- =====================================

    page:newAction()
        :title("Tinkaton")
        :item("minecraft:mace")
        :onLeftClick(function()

            pings.playGlobalSound(
                "tinkaton",
                1,
                1
            )

        end)

    -- =====================================
    -- SLEEP
    -- =====================================

    local sleepAction =
        page:newAction()
            :title("Sleep")
            :item("minecraft:red_bed")
            :onLeftClick(function(action)

                isSleeping =
                    not isSleeping

                setSleep(isSleeping)

                pings.setSleep(
                    isSleeping
                )

                action:setToggled(
                    isSleeping
                )

                idleExAction:setToggled(false)
                actionAnimAction:setToggled(false)

            end)

    -- =====================================
    -- IDLEEX
    -- =====================================

    idleExAction =
        page:newAction()
            :title("IdleEx")
            :item("minecraft:clock")
            :onLeftClick(function(action)

                isIdleEx =
                    not isIdleEx

                setIdleEx(isIdleEx)

                pings.setIdleEx(
                    isIdleEx
                )

                action:setToggled(
                    isIdleEx
                )

                sleepAction:setToggled(false)
                actionAnimAction:setToggled(false)

            end)

    -- =====================================
    -- ACTION
    -- =====================================

    actionAnimAction =
        page:newAction()
            :title("Action")
            :item("minecraft:blaze_powder")
            :onLeftClick(function(action)

                isAction =
                    not isAction

                setAction(isAction)

                pings.setAction(
                    isAction
                )

                action:setToggled(
                    isAction
                )

                sleepAction:setToggled(false)
                idleExAction:setToggled(false)

            end)

    -- =====================================
    -- POWER
    -- =====================================

    page:newAction()
        :title("Power")
        :item("minecraft:redstone_torch")
        :onLeftClick(function()

            pings.playGlobalSound(
                "snd_power",
                1,
                1
            )

        end)
end

-- =========================================
-- MAIN TICK
-- =========================================

function events.tick()

    if not player:isLoaded() then
        return
    end

    -- =====================================
    -- MOVEMENT
    -- =====================================

    local vel =
        player:getVelocity()

    local speed =
        vel.xz:length()

    local onGround =
        player:isOnGround()

    local crouching =
        player:getPose() == "CROUCHING"

    local elytra =
        player:getPose() == "FALL_FLYING"

    local moving =
        speed > 0.01

    local isSprinting =
        (player:isSprinting() or elytra)
        and moving

    local isWalking =
        moving
        and not isSprinting
        and not crouching

    local isIdle =
        not moving
        and not crouching

    local specialAnimation =
        isSleeping
        or isIdleEx
        or isAction

    -- =====================================
    -- ANIMATIONS
    -- =====================================

    if animations.igni then

        if not specialAnimation then

            animations.igni.idle:setPlaying(
                isIdle
            )

            animations.igni.walk:setPlaying(
                isWalking
            )

            animations.igni.sprint:setPlaying(
                isSprinting
            )

            animations.igni.crouch:setPlaying(
                crouching
            )

        else

            animations.igni.idle:stop()
            animations.igni.walk:stop()
            animations.igni.sprint:stop()
            animations.igni.crouch:stop()
        end
    end

    -- =====================================
    -- ATTACK SOUNDS
    -- =====================================

    if hitCooldown > 0 then
        hitCooldown =
            hitCooldown - 1
    end

    local swinging =
        player:getSwingTime() > 0

    if swinging
    and not wasSwinging
    and hitCooldown <= 0 then

        if not onGround
        and vel.y < 0 then

            pings.playGlobalSound(
                "snd_damage",
                1,
                1
            )

        else

            pings.playGlobalSound(
                "minecraft:block.amethyst_block.break",
                0.8,
                1.3
            )
        end

        hitCooldown = 8
    end

    wasSwinging = swinging

    -- =====================================
    -- EATING
    -- =====================================

    local isUsing =
        player:isUsingItem()

    if isUsing
    and not wasUsingItem then

        local activeItem =
            player:getActiveItem()

        if activeItem
        and (
            activeItem:getUseAction() == "EAT"
            or
            activeItem:getUseAction() == "DRINK"
        ) then

            pings.playGlobalSound(
                "snd_select",
                1,
                1
            )
        end

    elseif not isUsing
    and wasUsingItem then

        pings.playGlobalSound(
            "snd_power",
            1,
            1
        )
    end

    wasUsingItem = isUsing

    -- =====================================
    -- FOOTSTEPS
    -- =====================================

    if onGround
    and not crouching
    and not specialAnimation then

        -- sprint

        if isSprinting then

            runCooldown =
                runCooldown - 1

            if runCooldown <= 0 then

                pings.playGlobalSound(
                    "minecraft:block.amethyst_block.chime",
                    0.6,
                    1.2
                )

                runCooldown = 6
            end

        else
            runCooldown = 0
        end

        -- walk

        if isWalking then

            walkCooldown =
                walkCooldown - 1

            if walkCooldown <= 0 then

                pings.playGlobalSound(
                    "walk",
                    0.5,
                    1
                )

                walkCooldown = 11
            end

        else
            walkCooldown = 0
        end
    end

    -- =====================================
    -- HURT
    -- =====================================

    if lastHealth == nil then
        lastHealth =
            player:getHealth()
    end

    if player:getHealth()
    < lastHealth then

        pings.playGlobalSound(
            "snd_hurt1",
            1,
            1
        )
    end

    lastHealth =
        player:getHealth()

    -- =====================================
    -- JUMP
    -- =====================================

    if wasOnGround
    and not onGround
    and vel.y > 0 then

        pings.playGlobalSound(
            "jump",
            0.8,
            1
        )
    end

    wasOnGround = onGround
end
-- =========================================
-- FIGURA TEXTBOX SCRIPT
-- =========================================

-- =========================================
-- STATES
-- =========================================

local currentVoice = "snd_txtral"
local voicePitch = 1.0

-- =========================================
-- TEXTBOX VARIABLES
-- =========================================

local textTimer = 0
local hideTimer = 0
local fullMessage = ""
local currentDisplay = ""
local charIndex = 0
local typeTimer = 0
local typing = false
-- =========================================
-- NAMEPLATE
-- =========================================

local gradientName =
'{"text":"",'..
'"extra":['..
'{"text":"I","color":"#ff2b2b"},'..
'{"text":"g","color":"#ff4545"},'..
'{"text":"n","color":"#ff5f5f"},'..
'{"text":"i","color":"#ff7979"},'..
'{"text":"s","color":"#ff9393"},'..
'{"text":"i","color":"#ffadad"},'..
'{"text":"u","color":"#ffc7c7"},'..
'{"text":"m","color":"#ffe1e1"},'..
'{"text":"z","color":"#ffffff"}'..
']}'

-- =========================================
-- MODEL PART
-- =========================================

local chatPart = nil

function events.entity_init()

   chatPart = models.nameplate.root.ChatAnchor

if not chatPart then
    print("ChatAnchor model part not found!")
    return
end

    if chatPart.setBillboard then
        chatPart:setBillboard("CENTER")
    elseif chatPart.setBillboarding then
        chatPart:setBillboarding("CENTER")
    end

    -- =====================================
    -- BACKGROUND
    -- =====================================

    bg = chatPart:newSprite("BG")

    bg:texture(textures["ignitextbox"], 578, 152)

    bg:scale(0.12, 0.12, 0.12)

    bg:pos(0, -0.5, 0)

    if bg.light then
        bg:light(15,15)
    end

    bg:visible(false)

    -- =====================================
    -- BACK BACKGROUND
    -- =====================================

    bgBack = chatPart:newSprite("BG_BACK")

    bgBack:texture(textures["ignitextbox"], 578, 152)

    bgBack:scale(-0.12, 0.12, 0.12)

    bgBack:pos(-70, -0.5, 0.01)

    if bgBack.light then
        bgBack:light(15,15)
    end

    bgBack:visible(false)

    -- =====================================
    -- TEXT
    -- =====================================

    txt = chatPart:newText("TXT")

    txt:pos(-8, -3.5, -0.01)

    txt:scale(0.35, 0.35, 0.35)

    txt:width(170)

    txt:alignment("LEFT")

    txt:outline(true)

    if txt.font then
        txt:font("undertale.ttf")
    end

    if txt.light then
        txt:light(15,15)
    end

    txt:visible(false)

    -- =====================================
    -- BACK TEXT
    -- =====================================

    txtBack = chatPart:newText("TXT_BACK")

    txtBack:pos(-62, -3.5, 0.016)

    txtBack:scale(-0.35, 0.35, 0.35)

    txtBack:width(170)

    txtBack:alignment("LEFT")

    txtBack:outline(true)

    if txtBack.font then
        txtBack:font("undertale.ttf")
    end

    if txtBack.light then
        txtBack:light(15,15)
    end

    txtBack:visible(false)

    -- =====================================
    -- NAMEPLATE GRADIENT
    -- =====================================

    nameplate.ALL:setText(gradientName)


end




-- =========================================
-- FUNCTIONS
-- =========================================

local function setVoice(voice)

    currentVoice = voice

    if voice == "snd_txtral" then
        voicePitch = 1.3
    else
        voicePitch = 1.0
    end

    sounds:playSound(
        "snd_select",
        player:getPos(),
        1,
        1
    )
end

local function showTextbox(message)

    fullMessage = tostring(message)

    currentDisplay = ""

    charIndex = 0

    typeTimer = 0

    typing = true

    textTimer = 140
hideTimer = 170

    if txt then
    txt:text("")
end

if bg then bg:visible(true) end
if txt then txt:visible(true) end

if bgBack then bgBack:visible(true) end
if txtBack then txtBack:visible(true) end
end

-- =========================================
-- PINGS
-- =========================================

pings.setVoice = setVoice
pings.showTextbox = showTextbox
pings.setVoice = setVoice
-- =========================================
-- ACTION WHEEL
-- =========================================

if host:isHost() then
    -- =====================================
    -- ACTION WHEEL
    -- =====================================

    local textPage =  action_wheel:getCurrentPage()

    action_wheel:setPage(textPage)

    -- =====================================
    -- VOICE: SANS
    -- =====================================

    textPage:newAction()
        :title("Voice: Sans")
        :item("minecraft:blue_wool")
        :onLeftClick(function()

            setVoice(
                "snd_txtsans"
            )

            pings.setVoice(
                "snd_txtsans"
            )

        end)

    -- =====================================
    -- VOICE: RALSEI
    -- =====================================

    textPage:newAction()
        :title("Voice: Ralsei")
        :item("minecraft:green_wool")
        :onLeftClick(function()

            setVoice(
                "snd_txtral"
            )

            pings.setVoice(
                "snd_txtral"
            )

        end)

    -- =====================================
    -- VOICE: FLOWEY
    -- =====================================

    textPage:newAction()
        :title("Voice: Flowey")
        :item("minecraft:yellow_wool")
        :onLeftClick(function()

            setVoice(
                "snd_flowey"
            )

            pings.setVoice(
                "snd_flowey"
            )

        end)
end

-- =========================================
-- CHAT SEND
-- =========================================

function events.chat_send_message(message)

    showTextbox(message)

    pings.showTextbox(message)

    return message
end

-- =========================================
-- TICK
-- =========================================

function events.tick()

    -- =====================================
-- TYPE TIMER
-- =====================================

if textTimer > 0 then

    textTimer =
        textTimer - 1

    if typing then

        typeTimer =
            typeTimer + 1

        if typeTimer >= 2 then

            typeTimer = 0

            charIndex =
                charIndex + 1

            currentDisplay =
                fullMessage:sub(
                    1,
                    charIndex
                )

if txt then
    txt:text(currentDisplay)
end

if txtBack then
    txtBack:text(currentDisplay)
end

            local pitch = voicePitch

            sounds:playSound(
                currentVoice,
                player:getPos(),
                0.5,
                pitch
            )

            if charIndex >= #fullMessage then
                typing = false
            end
        end
    end
end

-- =====================================
-- HIDE TIMER
-- =====================================

if hideTimer > 0 then

    hideTimer =
        hideTimer - 1

    if hideTimer <= 0 then

        bg:visible(false)
        txt:visible(false)

        bgBack:visible(false)
        txtBack:visible(false)
    end
end
end
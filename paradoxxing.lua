-- Paradoxxing.lua -> script principal.
-- espero que essa porra offset autoupdater tenha funcionado

if not _G.OFFSETS_DATA then
    error("[Paradoxxing]: Use the main loader!")
end

local OFF_Lighting   = _G.OFFSETS_DATA.Lighting
local OFF_Atmosphere = _G.OFFSETS_DATA.Atmosphere
local OFF_Humanoid   = _G.OFFSETS_DATA.Humanoid


_G.ESP_COLOR_CRAWLER   = Color3.fromRGB(255, 50,  50)
_G.ESP_COLOR_FISHBONE  = Color3.fromRGB(50,  130, 255)
_G.ESP_COLOR_SOUL      = Color3.fromRGB(200, 50,  255)
_G.ESP_COLOR_PLAYER    = Color3.fromRGB(50,  255, 100)
_G.ESP_COLOR_SHINIGAMI = Color3.fromRGB(255, 200, 50)

UI.AddTab("Paradoxxing", function(tab)

    local sec = tab:Section("Enemies Visuals", "Left")
    sec:Toggle("crawler_esp", "Crawler", false)
    sec:ColorPicker("crawler_col", 1, 0.19, 0.19, 1, function(color)
        _G.ESP_COLOR_CRAWLER = color
    end)
    sec:SliderInt("crawler_dist", "Crawler Distance", 10, 10000, 500)

    sec:Toggle("fishbone_esp", "Fishbone", false)
    sec:ColorPicker("fishbone_col", 0.19, 0.51, 1, 1, function(color)
        _G.ESP_COLOR_FISHBONE = color
    end)
    sec:SliderInt("fishbone_dist", "Fishbone Distance", 10, 10000, 500)

    sec:Toggle("soul_esp", "Soul", false)
    sec:ColorPicker("soul_col", 0.78, 0.19, 1, 1, function(color)
        _G.ESP_COLOR_SOUL = color
    end)
    sec:SliderInt("soul_dist", "Soul Distance", 10, 10000, 500)

    sec:Toggle("shinigami_esp", "Shinigami", false)
    sec:ColorPicker("shinigami_col", 1, 0.78, 0.19, 1, function(color)
        _G.ESP_COLOR_SHINIGAMI = color
    end)
    sec:SliderInt("shinigami_dist", "Shinigami Distance", 10, 10000, 500)

    local race = tab:Section("Race Teller", "Left")
    race:Toggle("race_esp", "Enabled", false)
    race:ColorPicker("race_col", 0.19, 1, 0.39, 1, function(color)
        _G.ESP_COLOR_PLAYER = color
    end)
    race:SliderInt("race_dist", "Distance", 10, 10000, 500)
    race:Combo("race_type", "Race", {"Adjuchas", "Menos", "Arrancar", "Fishbone"}, 0)

    local vis = tab:Section("Visuals", "Right")
    vis:Toggle("no_fog", "No Fog", false)

    local combat = tab:Section("Combat", "Right")
    combat:Toggle("better_flashstep", "Better Flashstep", false)
    combat:SliderFloat("flashstep_speed",    "Boost Speed",    50,  500, 150, "%.0f")
    combat:SliderFloat("flashstep_duration", "Boost Duration", 0.05, 1.0, 0.3, "%.2f")
end)

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local Lighting   = game:GetService("Lighting")

local function memReadFloat(base, offset)
    local ok, v = pcall(memory_read, "float", base + offset)
    return ok and v or 0
end

local function memWriteFloat(base, offset, value)
    pcall(function()
        memory_write("float", base + offset, value)
    end)
end

local orig = {}

local function saveOriginals()
    pcall(function()
        local base = Lighting.Address
        orig.FogEnd   = memReadFloat(base, OFF_Lighting.FogEnd)
        orig.FogStart = memReadFloat(base, OFF_Lighting.FogStart)
    end)
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmo then
        pcall(function()
            local base = atmo.Address
            orig.AtmoDensity = memReadFloat(base, OFF_Atmosphere.Density)
            orig.AtmoHaze    = memReadFloat(base, OFF_Atmosphere.Haze)
            orig.AtmoGlare   = memReadFloat(base, OFF_Atmosphere.Glare)
        end)
    end
end
saveOriginals()

local fogActive = false

local function applyNoFog(enabled)
    pcall(function()
        local base = Lighting.Address
        memWriteFloat(base, OFF_Lighting.FogEnd,   enabled and 1e8 or (orig.FogEnd   or 100000))
        memWriteFloat(base, OFF_Lighting.FogStart, enabled and 1e8 or (orig.FogStart or 0))
    end)
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmo then
        pcall(function()
            local base = atmo.Address
            memWriteFloat(base, OFF_Atmosphere.Density, enabled and 0 or (orig.AtmoDensity or 0.395))
            memWriteFloat(base, OFF_Atmosphere.Haze,    enabled and 0 or (orig.AtmoHaze    or 0))
            memWriteFloat(base, OFF_Atmosphere.Glare,   enabled and 0 or (orig.AtmoGlare   or 0))
        end)
    end
end

-- FlashStep que deu um trampo do caralho
local fsActive = false
local fsUntil  = 0

RunService.Heartbeat:Connect(function()
    local enabled = UI.GetValue("better_flashstep") or false
    if not enabled then
        fsActive = false
        return
    end

    local lp   = Players.LocalPlayer
    local char = lp and lp.Character
    if not char then return end

    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp or not head then return end

    local ok, trans       = pcall(function() return head.Transparency end)
    local isFlashstepping = ok and trans and trans >= 1

    local boostSpeed    = UI.GetValue("flashstep_speed")    or 150
    local boostDuration = UI.GetValue("flashstep_duration") or 0.3

    if isFlashstepping and not fsActive then
        fsActive = true
        fsUntil  = tick() + boostDuration
    end

    if not isFlashstepping and fsActive and tick() >= fsUntil then
        fsActive = false
    end

    if fsActive then
        local vel     = hrp.AssemblyLinearVelocity
        local look    = hrp.CFrame.LookVector
        local dir     = Vector3.new(look.X, 0, look.Z).Unit
        local boosted = dir * boostSpeed
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.new(boosted.X, vel.Y, boosted.Z)
        end)
    end
end)

-- Esse esp é de que, lucas?
-- race teller
local RACE_VALUES = {"Adjuchas", "Menos", "Arrancar", "Fishbone"}
local labels      = {}
local rootCache   = {}
local aliveCache  = {}

local function getRootPart(model, key)
    if rootCache[key] and rootCache[key].Parent then return rootCache[key] end
    local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildOfClass("BasePart")
    if root then rootCache[key] = root end
    return root
end

local function getLabel(key, suffix)
    local k = suffix and (key .. "_" .. suffix) or key
    if not labels[k] then
        local l   = Drawing.new("Text")
        l.Visible = false
        l.Size    = 14
        l.Center  = true
        l.Outline = true
        labels[k] = l
    end
    return labels[k]
end

local function safeDist(a, b)
    if not a or not b then return nil end
    local ok, result = pcall(function()
        return (Vector3.new(a.X, a.Y, a.Z) - Vector3.new(b.X, b.Y, b.Z)).Magnitude
    end)
    return ok and result or nil
end

local function safeWorldToScreen(pos3d)
    if not pos3d then return nil end
    local ok, pos, onScreen = pcall(function()
        return WorldToScreen(Vector3.new(pos3d.X, pos3d.Y, pos3d.Z))
    end)
    if not ok or not onScreen or not pos then return nil end
    return pos
end

local function isDead(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return (hum.Health or 0) <= 0
end

local function getHealth(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return 0, 100 end
    return hum.Health or 0, hum.MaxHealth or 100
end

local function getPlayerRoot()
    local lp = Players.LocalPlayer
    if not lp then return nil end
    local char = lp.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or nil
end

local function safePos(root)
    if not root then return nil end
    local ok, pos = pcall(function() return root.Position end)
    if not ok or not pos then return nil end
    local ok2, v = pcall(function() return Vector3.new(pos.X, pos.Y, pos.Z) end)
    return ok2 and v or nil
end

local playerNamesCache = {}
local function refreshPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p and p.Name then names[p.Name] = true end
    end
    playerNamesCache = names
end
refreshPlayerNames()
--lembrar de adicionar esp por aqui, mais facil
local PREFIXES = {
    { prefix = "Crawler",   label = "Crawler",   uiKey = "crawler_esp",   distKey = "crawler_dist",   colorKey = "ESP_COLOR_CRAWLER"   },
    { prefix = "Fishbone",  label = "Fishbone",  uiKey = "fishbone_esp",  distKey = "fishbone_dist",  colorKey = "ESP_COLOR_FISHBONE"  },
    { prefix = "Soul",      label = "Soul",      uiKey = "soul_esp",      distKey = "soul_dist",      colorKey = "ESP_COLOR_SOUL"      },
    { prefix = "Shinigami", label = "Shinigami", uiKey = "shinigami_esp", distKey = "shinigami_dist", colorKey = "ESP_COLOR_SHINIGAMI" },
}

local cleanupTick    = 0
local aliveCacheTick = 0

local function cleanup(existing)
    for key, lbl in pairs(labels) do
        local baseKey = key:gsub("_name$", ""):gsub("_hp$", "")
        if not existing[baseKey] then
            lbl:Remove()
            labels[key] = nil
        end
    end
    for key in pairs(rootCache) do
        if not existing[key] then rootCache[key] = nil end
    end
end

RunService.RenderStepped:Connect(function()
    cleanupTick = cleanupTick + 1

    local noFogNow = UI.GetValue("no_fog") or false
    if noFogNow ~= fogActive then
        fogActive = noFogNow
        applyNoFog(fogActive)
    end

    local alive = workspace:FindFirstChild("Alive")
    if not alive then return end

    if cleanupTick - aliveCacheTick >= 10 then
        aliveCache     = alive:GetChildren()
        aliveCacheTick = cleanupTick
    end

    local playerRoot = getPlayerRoot()
    local playerPos  = safePos(playerRoot)

    if cleanupTick % 60 == 0 then
        local existing = {}
        for _, model in ipairs(aliveCache) do existing[tostring(model)] = true end
        pcall(cleanup, existing)
        pcall(refreshPlayerNames)
    end

    for _, cfg in ipairs(PREFIXES) do
        local espEnabled = UI.GetValue(cfg.uiKey)
        local maxDist = UI.GetValue(cfg.distKey)
        local color   = _G[cfg.colorKey] or Color3.fromRGB(255, 255, 255)

        for _, model in ipairs(aliveCache) do
            pcall(function()
                if not model:IsA("Model") or not model.Name:find(cfg.prefix) then return end

                local key = tostring(model)
                local lbl = getLabel(key)

                if not espEnabled then lbl.Visible = false return end

                if isDead(model) then lbl.Visible = false return end

                local root = getRootPart(model, key)
                local rPos = safePos(root)
                if not rPos then lbl.Visible = false return end

                if playerPos then
                    local dist = safeDist(rPos, playerPos)
                    if not dist or dist > maxDist then lbl.Visible = false return end
                end

                local pos = safeWorldToScreen(rPos)
                if not pos then lbl.Visible = false return end

                lbl.Visible  = true
                lbl.Text     = cfg.label
                lbl.Position = Vector2.new(pos.X, pos.Y - 10)
                lbl.Color    = color
            end)
        end
    end

    local raceEnabled  = UI.GetValue("race_esp")
    if not raceEnabled then return end

    local raceIdx      = UI.GetValue("race_type")
    local raceDist     = UI.GetValue("race_dist")
    local raceColor    = _G.ESP_COLOR_PLAYER or Color3.fromRGB(50, 255, 100)
    local selectedRace = RACE_VALUES[(raceIdx or 0) + 1]

    for _, model in ipairs(aliveCache) do
        pcall(function()
            if not model:IsA("Model") then return end
            if not playerNamesCache[model.Name] then return end

            local key     = tostring(model)
            local lblName = getLabel(key, "name")
            local lblHp   = getLabel(key, "hp")
            local entityType = model:GetAttribute("EntityType")

            if entityType ~= selectedRace then
                lblName.Visible = false
                lblHp.Visible   = false
                return
            end

            local root = getRootPart(model, key)
            local rPos = safePos(root)
            if not rPos then
                lblName.Visible = false
                lblHp.Visible   = false
                return
            end

            if playerPos then
                local dist = safeDist(rPos, playerPos)
                if not dist or dist > raceDist then
                    lblName.Visible = false
                    lblHp.Visible   = false
                    return
                end
            end

            local pos = safeWorldToScreen(rPos)
            if not pos then
                lblName.Visible = false
                lblHp.Visible   = false
                return
            end

            local hp, maxHp = getHealth(model)

            lblName.Visible  = true
            lblName.Text     = model.Name
            lblName.Position = Vector2.new(pos.X, pos.Y - 24)
            lblName.Color    = raceColor

            lblHp.Visible  = true
            lblHp.Text     = string.format("%.0f/%.0f HP", hp, maxHp)
            lblHp.Position = Vector2.new(pos.X, pos.Y - 10)
            lblHp.Color    = Color3.fromRGB(100, 255, 100)
        end)
    end
end)

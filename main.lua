--para fins de discernimento, esse script ta na versão 1
local MAPA_HUECO_MUNDO = 10705063265
local MAPA_MISSION = 137886107419750
local KARAKURA_TOWN = 15998522552

local OFFSETS_URL = "https://raw.githubusercontent.com/10-thousand-bees/paradoxxing/refs/heads/main/offsets.lua"

local function loadOffsets()
    print("[Paradoxxing]: Loading...")
    
    local success, err = pcall(function()
        loadstring(game:HttpGet(OFFSETS_URL))()
    end)

    if not success then
        warn("[Paradoxxing]: Couldnt retrieve data from file." .. tostring(err))
        notify("Error", "Something went wrong!", 5)
		warn("If you can see this, contact the Dev immediately.")
        return false
    end

    if not _G.OFFSETS_DATA then
        warn("[Paradoxxing]: Error - OFFSETS_DATA wasn't found")
        return false
    end

    return true
end

if loadOffsets() then
    local offsets = _G.OFFSETS_DATA
    
    local currentPlaceId = game.PlaceId

    if currentPlaceId == MAPA_HUECO_MUNDO then
    
        print("[Paradoxxing]: Hueco Mundo - Loaded!")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/10-thousand-bees/paradoxxing/refs/heads/main/paradoxxing.lua"))()

    elseif currentPlaceId == MAPA_MISSION then
        print("[Paradoxxing]: Mission Place - Loaded!")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/10-thousand-bees/paradoxxing/refs/heads/main/HMission.lua"))()

    elseif currentPlaceId == KARAKURA_TOWN then
        print("[Paradoxxing]: Karakura Town! - Loaded!")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/10-thousand-bees/paradoxxing/refs/heads/main/paradoxxing.lua"))()
        warn("This map isnt supported. Main script was loaded.")
    else
         warn("[Paradoxxing]: Unknown Game/World" .. tostring(currentPlaceId))
    end
else
    warn("[Paradoxxing]: Something related to the offsets went wrong. Contact the dev.")
end

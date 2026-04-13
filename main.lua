
local MAPA_A = 10705063265 -- Hueco Mundo
local MAPA_B = 137886107419750 -- Mission place
local MAPA_C = 5998522552 -- Karakura


local currentPlaceId = game.PlaceId

if currentPlaceId == MAPA_A then
    print("[Paradoxxing]: Hueco Mundo - Loaded!")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/10-thousand-bees/paradoxxing/refs/heads/main/paradoxxing.lua"))()

elseif currentPlaceId == MAPA_B then
    print("[Paradoxxing]: Mission Place - Loaded!")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/10-thousand-bees/paradoxxing/refs/heads/main/HMission.lua"))()
elseif currentPlaceId == MAPA_C then
    print("[Paradoxxing]: Karakura - Loaded!")
        
    loadstring(game:HttpGet("https://raw.githubusercontent.com/10-thousand-bees/paradoxxing/refs/heads/main/paradoxxing.lua"))()
    warn("i dont even know what this map is about, so im loading the main script")
        
else
    warn("Unknown Game/World ")
end

--pls dont make fun of my loader :(

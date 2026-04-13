
local MAPA_A = 10705063265 --Hueco Mundo
local MAPA_B = 137886107419750 --Mission place


local currentPlaceId = game.PlaceId

if currentPlaceId == MAPA_A then
    print("[Paradoxxing]: Hueco Mundo - Loaded!")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/10-thousand-bees/Para-beta-/refs/heads/main/paradoxxing.lua"))()

elseif currentPlaceId == MAPA_B then
    print("[Paradoxxing]: Mission Place - Loaded!")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/10-thousand-bees/Para-beta-/refs/heads/main/HMission.lua"))()
else
  
    warn("Unknown Game/World ")
    

end

--pls dont make fun of my loader :(
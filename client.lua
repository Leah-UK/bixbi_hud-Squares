AddEventHandler('onResourceStart', function(resourceName)
	if (resourceName == GetCurrentResourceName()) then
    while (ESX == nil) do Citizen.Wait(100) end
    ESX.PlayerLoaded = true
    LoopFunc()
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  while (ESX == nil) do Citizen.Wait(100) end
  ESX.PlayerData = xPlayer
 	ESX.PlayerLoaded = true
  LoopFunc()
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
  SendNUIMessage({action = "show_ui", type = "ui", enable = false})
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

function getMapPosition()
  --source: https://github.com/Dalrae1/MinimapPositionFiveM/blob/main/client.lua
	local minimapRawX, minimapRawY
	SetScriptGfxAlign(string.byte('L'), string.byte('B'))
	if IsBigmapActive() then
		minimapRawX, minimapRawY = GetScriptGfxPosition(-0.003975, 0.022 + (-0.460416666))
	else
		minimapRawX, minimapRawY = GetScriptGfxPosition(-0.0045, 0.002 + (-0.188888))
	end
	ResetScriptGfxAlign()
	return math.floor(minimapRawX * 100) + 0.3
end

local playerPed = PlayerPedId()
function LoopFunc()
  -- Map Graphics: https://forum.cfx.re/t/release-server-sided-dlk-pause-maps-working-minimap-radar/2269552
  SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0) -- Level 0
  SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
  SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
  SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
  SetMapZoomDataLevel(4, 24.3, 0.9, 0.08, 0.0, 0.0) -- Level 4
  SetMapZoomDataLevel(5, 55.0, 0.0, 0.1, 2.0, 1.0) -- ZOOM_LEVEL_GOLF_COURSE
  SetMapZoomDataLevel(6, 450.0, 0.0, 0.1, 1.0, 1.0) -- ZOOM_LEVEL_INTERIOR
  SetMapZoomDataLevel(7, 4.5, 0.0, 0.0, 0.0, 0.0) -- ZOOM_LEVEL_GALLERY
  SetMapZoomDataLevel(8, 11.0, 0.0, 0.0, 2.0, 3.0) -- ZOOM_LEVEL_GALLERY_MAXIMIZE
  
  -- local x = -0.035
  -- local y = -0.0025 
  -- local w = 0.28
  -- local h = 0.28

  -- local minimap = RequestScaleformMovie("minimap")
  -- SetMinimapComponentPosition('minimap', 'L', 'B', x + 0.02, y - 0.02, w - 0.115, h - 0.04)
  -- SetMinimapComponentPosition('minimap_mask', 'L', 'B', x, y, w, h)
  -- SetMinimapComponentPosition('minimap_blur', 'L', 'B', x, y, w, h)
  -- Citizen.Wait(1000)
  -- SetRadarBigmapEnabled(true, false)
  -- Citizen.Wait(0)
  -- SetRadarBigmapEnabled(false, false)
  
  local hunger = 0
  local thirst = 0
  SendNUIMessage({action = "show_ui", type = "ui", enable = true})
  SendNUIMessage({action = "show_ui", type = "voice", enable = Config.EnableVoiceBox})

  Citizen.CreateThread(function()
    while (ESX.PlayerLoaded) do
      Citizen.Wait(2000)
      playerPed = PlayerPedId()
      -- BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
      -- ScaleformMovieMethodAddParamInt(3)
      -- EndScaleformMovieMethod()
      
      if (IsPedOnFoot(playerPed)) then 
        SetRadarZoom(1200)
        if (not Config.ShowMapOnFoot) then DisplayRadar(false) end
      else
        SetRadarZoom(1100)
        DisplayRadar(true)
      end

      TriggerEvent('esx_status:getStatus', 'hunger', function(status) hunger = status.val / 10000 end)
      TriggerEvent('esx_status:getStatus', 'thirst', function(status) thirst = status.val / 10000 end)

      if (GetIsWidescreen() or GetIsWidescreen() == 1) then
        local mapPosition = getMapPosition()
        SendNUIMessage({
          action = "hud_pos",
          pos = tostring(mapPosition) .. '%'
        })
      end
    end
  end)

  local maxHealthIssue = false
  if (GetEntityMaxHealth(playerPed) ~= 200) then maxHealthIssue = true end

  Citizen.CreateThread(function()
    local playerID = PlayerId()
    while ESX.PlayerLoaded do      
      Citizen.Wait(500)

      local hpValue = GetEntityHealth(playerPed) - 100
      if (maxHealthIssue and hpValue == 75) then hpValue = 100 end
      local oxygenValue = 100
      if (Config.EnableOxygen) then oxygenValue = ((GetPlayerUnderwaterTimeRemaining(playerID) * 10) or 100) end

      SendNUIMessage({
          action = "update_hud",
          hp = hpValue,
          armour = GetPedArmour(playerPed),
          hunger = hunger or 0,
          thirst = thirst or 0,
          stamina = (100 - GetPlayerSprintStaminaRemaining(playerID)) or 100,
          oxygen = oxygenValue,
          talking = NetworkIsPlayerTalking(playerID)
      })
    end
  end)

  if (Config.UseBixbiCore) then
    Citizen.CreateThread(function()
      while ESX.PlayerLoaded do      
        if (hunger < 25 and hunger ~= 0) then exports['bixbi_core']:Notify('error', 'You\'re quite hungry') end
        Citizen.Wait(60000)    
      end
    end)
  end
end

function VoiceLevel(val)
  if (val == 1) then val = 33 elseif (val == 2) then val = 66 else val = 100 end
  SendNUIMessage({action = "voice_level", voicelevel = val})
end
exports('VoiceLevel', VoiceLevel)

RegisterCommand("hud", function()  SendNUIMessage({action = "toggle_hud"}) end, false)
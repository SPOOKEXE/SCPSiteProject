local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local RemoteService = ReplicatedModules.Services.RemoteService
local AlarmToggleEvent = RemoteService:GetRemote('AlarmToggleEvent', 'RemoteEvent', false)

local SystemsContainer = {}

local EnabledCache = {}

-- // Module // --
local Module = {}

-- sectorID CAN be nil/false
function Module:ToggleAlarmOfID(alarmID, sectorID, enabled)
	-- print(alarmID, sectorID, enabled)
	local index = tostring(alarmID)..'_'..tostring(sectorID or false)
	EnabledCache[index] = enabled or nil
	AlarmToggleEvent:FireAllClients(alarmID, sectorID, enabled)
end

function Module:OnPlayerAdded(LocalPlayer)
	-- wait for the character
	if not LocalPlayer.Character then
		LocalPlayer.CharacterAdded:Wait()
	end
	-- set their enabled state
	for alarmSectorID, _ in pairs( EnabledCache ) do
		local alarmID, sectorID = string.split(alarmSectorID, '_')
		AlarmToggleEvent:FireClient(LocalPlayer, alarmID, sectorID, true)
	end
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	-- set the enabled state
	for _, LocalPlayer in ipairs( Players:GetPlayers() ) do
		Module:OnPlayerAdded(LocalPlayer)
	end

	-- set the enabled state
	Players.PlayerAdded:Connect(function(LocalPlayer)
		Module:OnPlayerAdded(LocalPlayer)
	end)
end

return Module

local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local RemoteService = ReplicatedModules.Services.RemoteService
local AlarmToggleEvent = RemoteService:GetRemote('AlarmToggleEvent', 'RemoteEvent', false)

local SystemsContainer = {}

local EnabledCache = {}

-- // Module // --
local Module = {}

-- get index from alarmID and sectorID
function Module:GetIndexFromIDs(alarmID, sectorID)
	if alarmID and (not sectorID) then
		return alarmID
	elseif (not alarmID) and sectorID then
		return sectorID
	end
	return alarmID..'_'..sectorID
end

-- alarmID OR sectorID can be nil/false
function Module:ToggleAlarmOfID(alarmID, sectorID, enabled)
	-- print(alarmID, sectorID, enabled)
	local index = Module:GetIndexFromIDs(alarmID, sectorID)
	EnabledCache[index] = enabled or nil
	AlarmToggleEvent:FireAllClients(index, enabled)
end

function Module:OnPlayerAdded(LocalPlayer)
	-- wait for the character
	if not LocalPlayer.Character then
		LocalPlayer.CharacterAdded:Wait()
	end
	-- set their enabled state
	for alarmSectorID, _ in pairs( EnabledCache ) do
		local alarmID, sectorID = string.split(alarmSectorID, '_')
		local index = Module:GetIndexFromIDs(alarmID, sectorID)
		AlarmToggleEvent:FireClient(LocalPlayer, index, true)
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

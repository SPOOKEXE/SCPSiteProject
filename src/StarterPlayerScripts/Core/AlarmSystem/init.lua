local CollectionService = game:GetService('CollectionService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local RemoteService = ReplicatedModules.Services.RemoteService
local AlarmToggleEvent = RemoteService:GetRemote('AlarmToggleEvent', 'RemoteEvent', false)

local SystemsContainer = {}

local AlarmTypeClasses = require(script.AlarmTypes)
local AlarmInstanceToClass = {}

-- // Module // --
local Module = {}

function Module:ToggleAlarmOfID(alarmID, sectorID, enabled)
	for _, alarmClass in pairs( AlarmInstanceToClass ) do
		if alarmClass.AlarmID ~= alarmID then
			continue
		end
		if sectorID and alarmClass.SectorID ~= sectorID then
			continue
		end
		alarmClass:Toggle(enabled)
	end
end

function Module:SetupAlarmModel(alarmInstance)
	if AlarmInstanceToClass[alarmInstance] then
		return
	end
	local alarmID = alarmInstance:GetAttribute('AlarmID') or 'Orbit'
	local sectorID = alarmInstance:GetAttribute('SectorID') or false
	local alarmClass = AlarmTypeClasses.OrbitAlarmClass.New(alarmInstance, alarmID, sectorID)
	AlarmInstanceToClass[alarmInstance] = alarmClass
end

function Module:RemoveAlarmModel(alarmInstance)
	AlarmInstanceToClass[alarmInstance] = nil
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	for _, alarmInstance in ipairs( CollectionService:GetTagged('AlarmObjects') ) do
		task.defer(function()
			Module:SetupAlarmModel(alarmInstance)
		end)
	end

	CollectionService:GetInstanceAddedSignal('AlarmObjects'):Connect(function(alarmInstance)
		Module:SetupAlarmModel(alarmInstance)
	end)

	CollectionService:GetInstanceRemovedSignal('AlarmObjects'):Connect(function(alarmInstance)
		Module:RemoveAlarmModel(alarmInstance)
	end)

	AlarmToggleEvent.OnClientEvent:Connect(function(alarmID, sectorID, enabled)
		-- print(alarmID, sectorID, enabled)
		Module:ToggleAlarmOfID(alarmID, sectorID, enabled)
	end)

	RunService.Heartbeat:Connect(function(deltaTime)
		for _, alarmClass in pairs( AlarmInstanceToClass ) do
			if alarmClass.Enabled then
				alarmClass:Update(deltaTime)
			end
		end
	end)
end

return Module

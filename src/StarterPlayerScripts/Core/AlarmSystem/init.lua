local CollectionService = game:GetService('CollectionService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local RemoteService = ReplicatedModules.Services.RemoteService
local AlarmToggleEvent = RemoteService:GetRemote('AlarmToggleEvent', 'RemoteEvent', false)

local SystemsContainer = {}

local AlarmTypeClasses = require(script.AlarmTypes)
local AlarmIDToClass = { Orbit = AlarmTypeClasses.OrbitAlarmClass }

local AlarmInstanceToClass = {}
local ActiveIDsCache = {}

-- // Module // --
local Module = {}

function Module:ToggleAlarmOfID(index, enabled)
	ActiveIDsCache[index] = enabled
	if string.find(index, '_') then
		-- alarmID & sectorID specific
		local alarmID, sectorID = unpack(string.split( index, '_' ))
		for _, AlarmClass in pairs( AlarmInstanceToClass ) do
			if AlarmClass.AlarmID == alarmID and AlarmClass.SectorID == sectorID then
				local isAlarmIDEnabled = ActiveIDsCache[AlarmClass.AlarmID]
				local isSectorEnabled = (AlarmClass.SectorID and ActiveIDsCache[AlarmClass.SectorID])
				AlarmClass:Toggle( ActiveIDsCache[index] or isAlarmIDEnabled or isSectorEnabled )
			end
		end
	else
		-- singular
		for _, AlarmClass in pairs( AlarmInstanceToClass ) do
			local isAlarmIDEnabled = ActiveIDsCache[AlarmClass.AlarmID]
			local isSectorEnabled = (AlarmClass.SectorID and ActiveIDsCache[AlarmClass.SectorID])
			local mixedIndex = AlarmClass.SectorID and AlarmClass.AlarmID..'_'..AlarmClass.SectorID
			if AlarmClass.AlarmID == index or AlarmClass.SectorID == index then
				AlarmClass:Toggle( ActiveIDsCache[mixedIndex] or isAlarmIDEnabled or isSectorEnabled )
			end
		end
	end
end

function Module:SetupAlarmModel(alarmInstance)
	if AlarmInstanceToClass[alarmInstance] then
		return
	end
	local alarmID = alarmInstance:GetAttribute('AlarmID') or 'Orbit'
	if not AlarmIDToClass[alarmID] then
		warn('Unsupported Alarm of ID: ' .. alarmID .. ' - No Class')
		return
	end
	local sectorID = alarmInstance:GetAttribute('SectorID') or false
	local alarmClass = AlarmIDToClass[alarmID].New(alarmInstance, alarmID, sectorID)
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

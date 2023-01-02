local CollectionService = game:GetService("CollectionService")

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local DoorConfigModule = ReplicatedModules.Data.DoorConfig

local DoorControllersFolder = script:WaitForChild('DoorControllers')

local SystemsContainer = {}

local CachedDoorControllerClasses = {}
local ActiveDoorControllers = {}

local function RemoveDoorByCondition(conditionCallback)
	local index = 1
	while index <= #ActiveDoorControllers do
		local Class = ActiveDoorControllers[index]
		if conditionCallback( Class ) then
			Class:Destroy()
			table.remove(ActiveDoorControllers, index)
		else
			index += 1
		end
	end
end

-- // Module // --
local Module = {}

function Module:RegisterDoor( DoorModel )
	-- Is the door an instance?
	if typeof(DoorModel) ~= 'Instance' then
		warn('DoorModel is not an instance. ' .. typeof(DoorModel) .. "\n" .. debug.traceback())
		return false
	end

	-- Does the door have a doorId attribute?
	local doorID = DoorModel.Name --DoorModel:GetAttribute('DoorID')
	-- if not doorID then
	-- 	warn('Door does not have a DoorID attribute. ' .. DoorModel:GetFullName())
	-- 	return
	-- end

	-- does this doorId have a configuration setup?
	local ConfigData = DoorConfigModule:GetDoorConfig( doorID )
	if not ConfigData then
		warn('DoorID does not have a configuration setup: ' .. tostring(doorID))
		return
	end

	-- Get the controller class
	local ControllerClass = false
	if ConfigData.ClientDoorClassID == 'BaseDoor' or ConfigData.DoorClassID == 'BaseDoor' then
		ControllerClass = CachedDoorControllerClasses.BaseDoor
	else
		ControllerClass = CachedDoorControllerClasses[ConfigData.DoorClassID or ConfigData.ClientDoorClassID]
	end

	if not ControllerClass then
		warn('[DOOR CONTROLLER - CLIENT] No Door Controller Found: '..tostring(ConfigData.ClientDoorClassID or ConfigData.DoorClassID))
		return
	end

	-- print(DoorModel.Name, ControllerClass)
	local Class = ControllerClass.New(DoorModel, false)
	table.insert(ActiveDoorControllers, Class)
	return true, Class
end

function Module:RemoveDoorByUUID(DoorUUID)
	RemoveDoorByCondition(function(Class)
		return Class.DoorUUID == DoorUUID
	end)
end

function Module:RemoveDoorByModel(Model)
	RemoveDoorByCondition(function(Class)
		return Class.Model == Model
	end)
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	-- require all the controller classes
	CachedDoorControllerClasses.BaseDoor = require(script.BaseDoor)
	for _, ControllerModule in ipairs( script:WaitForChild('DoorControllers'):GetChildren() ) do
		CachedDoorControllerClasses[ControllerModule.Name ] = require(ControllerModule)
	end

	-- Set the SystemsContainer for all cached modules
	for _, Cached in pairs( CachedDoorControllerClasses ) do
		Cached.SystemsContainer = SystemsContainer
	end

	for _, Model in ipairs( CollectionService:GetTagged("DoorInstance") ) do
		Module:RegisterDoor(Model)
	end

	CollectionService:GetInstanceAddedSignal("DoorInstance"):Connect(function(Model)
		Module:RegisterDoor(Model)
	end)
end

return Module


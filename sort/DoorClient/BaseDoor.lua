local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local DoorConfigModule = ReplicatedModules.Data.DoorConfig

local MaidInstanceClass = ReplicatedModules.Classes.Maid

type ClearanceConfigTable = {
	KeyLevel : number,
	Clearance : {
		AD 	: boolean,
		EC 	: boolean,
		ET 	: boolean,
		IA 	: boolean,
		ISD : boolean,
		LD 	: boolean,
		MD 	: boolean,
		MTF : boolean,
		MaD : boolean,
		SD 	: boolean,
		ScD : boolean,
		O5 	: boolean,
	},
}

type DoorConfigTable = {
	ID : string,
	DoorClassID : string,
	ClearanceConfig : ClearanceConfigTable | { ClearanceConfigTable }, -- can be one ClearanceConfigTable or an array of them
	CooldownPeriod : number,
	AutoClosePeriod : number,
}

-- // Class // --
local Class = { SystemsContainer = {} }
Class.__index = Class
Class.super = false

function Class.New(Model, forceState)
	local ConfigTable = DoorConfigModule:GetDoorConfig( Model.Name ) :: DoorConfigTable

	--Model:SetAttribute('StateValue', (forceState == true))
	--Model:SetAttribute('DoorDestroyed', false)
	--Model:SetAttribute('PowerEnabledOverride', false)
	--Model:SetAttribute('ControlPanelOverride', false)
	--Model:SetAttribute('SCP079Override', false)
	--Model:SetAttribute('IsDoorBroken', false)
	--Model:SetAttribute('DoorSector', false)
	local DoorID = ConfigTable.DoorClassID --Model:GetAttribute("DoorID")
	local DoorUUID = Model:GetAttribute('DoorUUID')

	local self = setmetatable({
		UUID = DoorUUID,

		Model = Model,
		BackupModel = Model:Clone(),

		DoorMaid = MaidInstanceClass.New(),
		DoorControlNodes = {},
		Config = ConfigTable,

		_LastState = nil, -- last state of the door
	}, Class)

	local DoorModel = Model:FindFirstChild('Door')
	if typeof(DoorModel) ~= 'Instance' or (not DoorModel:IsA('Model')) then
		DoorModel = Model
	end

	--local boundCF, boundSize = DoorModel:GetBoundingBox()
	--local bPart = Model:FindFirstChildWhichIsA('Detector')

	self:Setup()

	return self
end

function Class:GetAttribute(attribute)
	self.Model:GetAttribute(attribute)
end

function Class:SetAttribute(attribute, value)
	self.Model:SetAttribute(attribute, value)
end

function Class:GetAttributeChangedSignal(attribute)
	return self.Model:GetAttributeChangedSignal(attribute)
end

function Class:Toggle()
	if self:GetAttribute('DoorDestroyedValue') then
		return false
	end
	-- move model
	warn('Door Toggled: ', self:GetAttribute('DoorID'), self:GetAttribute('StateValue'))
	return true
end

function Class:Destroy()
	self.DoorMaid:Cleanup()
end

function Class:AdjustSounds(tweenDuration)
	for _, soundInstance in ipairs(self.Model.PromptNode:GetChildren()) do
		if not soundInstance:IsA('Sound') then
			continue
		end
		task.defer(function()
			if soundInstance.IsLoaded then
				soundInstance.PlaybackSpeed = (soundInstance.TimeLength / tweenDuration)
			else
				local event; event = soundInstance.Loaded:Connect(function()
					event:Disconnect()
					soundInstance.PlaybackSpeed = (soundInstance.TimeLength / tweenDuration)
				end)
			end
		end)
	end
end

function Class:Setup()
	self:Toggle()

	self:GetAttributeChangedSignal('StateValue'):Connect(function()
		self:Toggle()
	end)
end

-- Reset the door back from its destroyed state
-- TODO: find a way to update the Model variable to match the cloned one on the server
function Class:RefreshDoor()

end

-- Demolish the door from its 'working' state
function Class:Demolish()

end

return Class

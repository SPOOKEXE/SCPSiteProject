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

	local self = setmetatable({
		UUID = Model:GetAttribute('DoorUUID'),
		DoorID = Model:GetAttribute('DoorID'),

		Model = Model,

		DoorMaid = MaidInstanceClass.New(),
		DoorControlNodes = {},
		Config = ConfigTable,

		_LastState = Model:GetAttribute('StateValue'), -- last state of the door
	}, Class)

	local DoorModel = Model:FindFirstChild('Door')
	if typeof(DoorModel) ~= 'Instance' or (not DoorModel:IsA('Model')) then
		DoorModel = Model
	end

	--local boundCF, boundSize = DoorModel:GetBoundingBox()
	--local bPart = Model:FindFirstChildWhichIsA('Detector')

	self:Setup()
	self:Toggle(false, forceState)

	return self
end

function Class:GetAttribute(attribute)
	return self.Model:GetAttribute(attribute) or false
end

function Class:SetAttribute(attribute, value)
	self.Model:SetAttribute(attribute, value)
end

function Class:GetAttributeChangedSignal(attribute)
	return self.Model:GetAttributeChangedSignal(attribute)
end

function Class:Toggle( noSound, forceState )
	if self:GetAttribute('DoorDestroyedValue') then
		return false
	end

	if typeof(forceState) == 'boolean' then
		self._LastState = forceState
	end

	local isOpen = self:GetAttribute('StateValue')
	if self._LastState == isOpen then
		return false
	end
	self._LastState = isOpen

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

function Class:PlaySound( isDoorOpening, stopAll )
	local baseString = isDoorOpening and 'Open' or 'Close'

	for _, soundInstance in ipairs( self.Model.PromptNode:GetChildren() ) do
		if not soundInstance:IsA('Sound') then
			continue
		end

		if stopAll then
			soundInstance:Stop()
			continue
		end

		if string.find(soundInstance.Name, baseString) then
			soundInstance:Play()
		else
			soundInstance:Stop()
		end
	end
end

function Class:Setup()
	self:Toggle( true )

	self:GetAttributeChangedSignal('StateValue'):Connect(function()
		self:Toggle( )
	end)

	self:GetAttributeChangedSignal('DoorDestroyed'):Connect(function()
		self:Demolish()
	end)
end

-- Demolish the door from its 'working' state
function Class:Demolish()
	if not self.Destroyed then
		self.Destroyed = true
		print('door destroyed - ', self.Model:GetFullName())
		return true
	end
	return false
end

return Class

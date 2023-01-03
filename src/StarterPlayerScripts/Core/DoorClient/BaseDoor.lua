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

function Class.New( Model )
	local ConfigTable = DoorConfigModule:GetDoorConfig( Model.Name ) :: DoorConfigTable

	local self = setmetatable({
		UUID = Model:GetAttribute('DoorUUID'),
		DoorID = Model:GetAttribute('DoorID'),

		Model = Model,

		DoorMaid = MaidInstanceClass.New(),
		DoorControlNodes = {},
		Config = ConfigTable,

		_LastState = nil,
	}, Class)

	self:Setup()
	self:Update( true )

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

function Class:Update( noSound )
	if self:GetAttribute('DoorDestroyedValue') then
		return false
	end
	self._LastState = self:GetAttribute('StateValue')
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
	self:Update(true)

	self:GetAttributeChangedSignal('StateValue'):Connect(function()
		self:Update( )
	end)

	self:GetAttributeChangedSignal('DoorDestroyed'):Connect(function()
		self:Demolish()
	end)
end

-- Demolish the door from its 'working' state
function Class:Demolish()
	if not self.Destroyed then
		self.Destroyed = true
		warn('door destroyed - ', self.Model:GetFullName())
		return true
	end
	return false
end

return Class

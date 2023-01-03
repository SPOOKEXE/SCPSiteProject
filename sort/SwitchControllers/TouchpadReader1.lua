
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UtilEffects = require(ReplicatedStorage:WaitForChild('DoorSystem'):WaitForChild('UtilEffects'))

-- // Class // --
local Class = {}
Class.__index = Class

function Class.New( Model )
	local self = { Model = Model, Debounce = false }
	local stateValueObject = Instance.new('BoolValue')
	stateValueObject.Name = 'StateValue'
	stateValueObject.Value = true
	stateValueObject.Parent = Model
	self.StateValue = stateValueObject
	setmetatable(self, Class)
	return self
end

function Class:Toggle( state )
	--print(state)
	self.StateValue.Value = state
end

function Class:Interact(_, TargetModel)
	if TargetModel ~= self.Model or self.Debounce then
		return false
	end
	--print('----', LocalPlayer, TargetModel, self.Model, self.Debounce)
	self.Debounce = true
	-- scan effect & open door
	UtilEffects:RunScanBeamEffect( self.Model.Part.RedScanBeam)
	self:Toggle(true)
	task.defer(function()
		-- wait 4
		task.wait(4)
		-- close door
		self:Toggle(false)
		-- reset debounce
		task.wait(1)
		self.Debounce = false
	end)
	return true
end

function Class:Setup()
	self:Toggle(false)

	-- reset the beam
	local Beam = self.Model.Part.RedScanBeam
	Beam.Color = ColorSequence.new(Color3.new())

	-- scan triggered
	--[[
		self.Model.Part.Touched:Connect(function( TouchPart )
			if TouchPart.Name ~= 'Handle' or (not TouchPart.Parent:IsA('Tool')) then
				return
			end
			if self.Debounce then
				return
			end
			self.Debounce = true
			-- scan effect & open door
			self:RunScanEffect()
			self:Toggle(true)
			-- wait 4
			task.wait(4)
			-- close door
			self:Toggle(false)
			-- reset debounce
			task.wait(1)
			self.Debounce = false
		end)
	]]

end

return Class
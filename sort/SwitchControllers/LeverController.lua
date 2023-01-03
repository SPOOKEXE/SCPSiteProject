
local Class = {}
Class.__index = Class

function Class.New( Model )
	local self = { Model = Model }
	local stateValueObject = Instance.new('BoolValue')
	stateValueObject.Name = 'StateValue'
	stateValueObject.Value = true
	stateValueObject.Parent = Model
	self.StateValue = stateValueObject
	setmetatable(self, Class)
	return self
end

function Class:Toggle( forceState )
	if typeof(forceState) == 'nil' then
		self.StateValue.Value = not self.StateValue.Value
	else
		self.StateValue.Value = forceState
	end
	self.Model.LeverOpen.Transparency = self.StateValue.Value and 0 or 1
	self.Model.LeverClosed.Transparency = self.StateValue.Value and 1 or 0
	-- anything extra, although not needed for levers
end

function Class:Interact(_, TargetModel)
	if TargetModel ~= self.Model or self.Debounce then
		return false
	end
	--print('----', TargetModel, self.Model, self.Debounce)
	self.Debounce = true
	self:Toggle()
	task.delay(2, function()
		self.Debounce = false
	end)
	return true
end

function Class:Setup()
	self:Toggle(false)
	--[[self.Model.Detector.ClickDetector.MouseClick:Connect(function( _ )
		self:Toggle()
	end)]]
end

return Class
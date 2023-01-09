local HttpService = game:GetService('HttpService')

-- // Class // --
local Class = { ClassName = 'BaseController', SystemsContainer = {} }
Class.__index = Class

function Class.New( Model, forceState )
	local self = setmetatable({
		UUID = HttpService:GenerateGUID(false),
		Model = Model,

		_LastState = nil, -- last state of the door
	}, Class)

	self:_SetupAttributes()
	self:_Setup()

	return self
end

function Class:IsA(className)
	return self.ClassName == className or (self.super and self.super.IsA(self, className))
end

function Class:GetAttribute(attribute)
	return self.Model:GetAttribute(attribute)
end

function Class:SetAttribute(attribute, value)
	self.Model:SetAttribute(attribute, value)
end

function Class:GetAttributeChangedSignal(attribute)
	return self.Model:GetAttributeChangedSignal(attribute)
end

function Class:_SetupAttributes()
	self:SetAttribute('StateValue', false) -- true = closed
	self:SetAttribute('ControllerUUID', self.UUID)
end

function Class:_Setup()

	-- // TESTING PURPOSES // --
	local proximityPrompt = Instance.new('ProximityPrompt')
	proximityPrompt.Name = 'ToggleControllerPrompt'
	proximityPrompt.Enabled = true
	proximityPrompt.ActionText = 'Toggle Controller'
	proximityPrompt.ObjectText = 'Controller'
	proximityPrompt.ClickablePrompt = true
	proximityPrompt.KeyboardKeyCode = Enum.KeyCode.F
	proximityPrompt.HoldDuration = 0.25
	proximityPrompt.MaxActivationDistance = 12
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
	proximityPrompt.Triggered:Connect(function(LocalPlayer)
		self:Toggle()
	end)
	proximityPrompt.Parent = self.Model:FindFirstChild('Detector') or self.Model
	-- // ---------------- // --

	self:Toggle( true ) -- true = power on = closed
end

function Class:Toggle( forceState )
	if typeof(forceState) == 'boolean' then
		self:SetAttribute('StateValue', forceState)
	else
		self:SetAttribute('StateValue', not self:GetAttribute('StateValue'))
	end
	return true
end

return Class

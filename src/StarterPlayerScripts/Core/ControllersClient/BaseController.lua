
-- // Class // --
local Class = { SystemsContainer = {} }
Class.__index = Class

function Class.New( Model )
	local self = setmetatable({
		UUID = Model:GetAttribute('ControllerUUID'),
		Model = Model,

		_LastState = Model:GetAttribute('StateValue'), -- last state of the door
	}, Class)

	self:_Setup()

	return self
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

function Class:_Setup()
	self:Update( )
	self:GetAttributeChangedSignal('StateValue'):Connect(function()
		self:Update( )
	end)
end

function Class:Update()
	self._LastState = self:GetAttribute('StateValue')
	return true
end

return Class

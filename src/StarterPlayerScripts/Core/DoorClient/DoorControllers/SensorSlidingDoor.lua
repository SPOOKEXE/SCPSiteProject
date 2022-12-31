-- SPOOK_EXE
local BaseDoor = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({}, BaseDoor)
Class.__index = Class

function Class.New( ... )
	local self = setmetatable(BaseDoor.New( ... ), Class)
	self:Setup()
	return self
end

function Class:Interact(_, _)
	return false
end

function Class:Setup()
	--print('Setup', script.Name, ' - Create Interaction Methods')

	local RunService = game:GetService('RunService')
	local WithinSensor = false
	RunService.Heartbeat:Connect(function()
		WithinSensor = self:IsHumanoidInSensors()
		if self:GetAttribute('StateValue') ~= WithinSensor then
			self:Toggle(WithinSensor)
		end
	end)

	self:SetAttribute('IgnoreDoor', true)
end

function Class:Toggle()
   -- TODO: change model
end

return Class

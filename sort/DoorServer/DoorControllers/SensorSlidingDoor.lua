-- SPOOK_EXE
local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({}, BaseDoorClassModule)
Class.__index = Class

function Class.New( ... )
	local self = setmetatable(BaseDoorClassModule.New( ... ), Class)
	self:Setup()
	return self
end

function Class:Interact(_, _)
	return false
end

function Class:IsHumanoidInSensors()
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Blacklist
	for _, sensorPart in ipairs( self.Model.Sensors:GetChildren() ) do
		local touchingParts = workspace:GetPartBoundsInBox(sensorPart.CFrame, sensorPart.Size, overlapParams)
		for _, basePart in ipairs( touchingParts ) do
			local humanoid = basePart.Parent:FindFirstChildOfClass('Humanoid')
			if humanoid and humanoid.Health > 0 then
				return true
			end
		end
	end
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

return Class

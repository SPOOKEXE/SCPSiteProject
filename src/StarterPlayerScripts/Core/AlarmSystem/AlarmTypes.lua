
local ORBIT_DEGREES_PER_SECOND = 80

local function ToggleObject(object, enabled)
	if object:IsA('Light') then
		object.Enabled = enabled
	elseif object:IsA('Sound') then
		if enabled then
			object:Play()
		else
			object:Stop()
		end
	end
end

-- // BASE ALARM CLASS // --
local BaseAlarmClass = { ClassName = 'BaseAlarmClass' }
BaseAlarmClass.__index = BaseAlarmClass

function BaseAlarmClass.New(Model, AlarmID, SectorID)
	return setmetatable({
		AlarmID=AlarmID,
		SectorID=SectorID,
		Model=Model,
		Enabled=false
	}, BaseAlarmClass)
end

function BaseAlarmClass:Toggle(enabled)
	self.Enabled = enabled
	for _, object in ipairs( self.Model:GetDescendants() ) do
		ToggleObject(object, enabled)
	end
end

function BaseAlarmClass:Update(deltaTime)
end

-- // ORBIT ALARM CLASS // --
local OrbitAlarmClass = setmetatable({ ClassName = 'OrbitAlarmClass' }, BaseAlarmClass)
OrbitAlarmClass.__index = OrbitAlarmClass

function OrbitAlarmClass.New(...)
	return setmetatable(BaseAlarmClass.New(...), OrbitAlarmClass)
end

function OrbitAlarmClass:Update(deltaTime)
	self.Model.LightEmitter.CFrame *= CFrame.Angles( deltaTime * math.rad(ORBIT_DEGREES_PER_SECOND), 0, 0 )
end

return {BaseAlarmClass=BaseAlarmClass, OrbitAlarmClass=OrbitAlarmClass}

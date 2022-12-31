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

function Class:Setup()
	--print('Setup', script.Name, ' - Create Interaction Methods')
end

function Class:Toggle()
   -- TODO: change model
end

return Class

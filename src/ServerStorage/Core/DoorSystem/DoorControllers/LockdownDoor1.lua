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
	-- Controlled by Lever
end

return Class

local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoorClassModule)
Class.__index = Class

function Class.New(...)
	local self = setmetatable( BaseDoorClassModule.New(...), Class )
	self:Setup()
	return self
end

function Class:Interact(_, _)
	return false
end

function Class:Setup()
	-- Controlled by lever
end

return Class

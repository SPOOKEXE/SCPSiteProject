local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = { SystemsContainer = {} }
Class.__index = Class
Class.super = BaseDoorClassModule

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

function Class:Toggle()
   -- TODO: change model
end

return Class

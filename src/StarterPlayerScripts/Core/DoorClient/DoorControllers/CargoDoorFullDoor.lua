-- SPOOK_EXE
local BaseDoor = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoor)
Class.__index = Class
Class.super = BaseDoorClassModule

function Class.New( ... )
	local self = setmetatable(BaseDoor.New( ... ), Class)
	self:Setup()
	return self
end

function Class:Setup()

end

function Class:Toggle()
   -- TODO: change model
end

return Class

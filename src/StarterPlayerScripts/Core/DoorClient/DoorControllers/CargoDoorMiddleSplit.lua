-- SPOOK_EXE
local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoorClassModule)
Class.__index = Class
--Class.super = BaseDoorClassModule

function Class.New( ... )
	local self = setmetatable(BaseDoorClassModule.New( ... ), Class)
	self:Setup()
	return self
end

function Class:Setup()

end

function Class:Toggle()
	-- TODO: change model
end

return Class

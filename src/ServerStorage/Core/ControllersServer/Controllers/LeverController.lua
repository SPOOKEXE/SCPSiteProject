local BaseControllerClassModule = require(script.Parent.Parent.BaseController)

-- // Class // --
local Class = setmetatable({SystemsContainer = {}}, BaseControllerClassModule)
Class.__index = Class
Class.super = BaseControllerClassModule

function Class.New( ... )
	return setmetatable(BaseControllerClassModule.New(...), Class)
end

function Class:Update()
	if not Class.super.Update(self) then
		return false
	end
	return true
end

return Class

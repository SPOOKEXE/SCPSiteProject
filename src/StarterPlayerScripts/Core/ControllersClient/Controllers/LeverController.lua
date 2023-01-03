local BaseControllerClassModule = require(script.Parent.Parent.BaseController)

-- // Class // --
local Class = setmetatable({SystemsContainer = {}}, BaseControllerClassModule)
Class.__index = Class
Class.super = BaseControllerClassModule

function Class.New( ... )
	local self = setmetatable(BaseControllerClassModule.New(...), Class)
	self:Update()
	return self
end

function Class:Update()
	if not Class.super.Update(self) then
		return false
	end

	local powerEnabled = self:GetAttribute('StateValue') or false
	self.Model.LeverOpen.Transparency = powerEnabled and 1 or 0
	self.Model.LeverClosed.Transparency = powerEnabled and 0 or 1

	return true
end

return Class

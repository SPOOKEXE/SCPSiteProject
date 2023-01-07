
local BaseSCPClassModule = require(script.Parent.Parent.BaseSCP)

-- // Class // -- 
local Class = {}
Class.__index = setmetatable({ SystemsContainer = {} }, BaseSCPClassModule)
Class.super = BaseSCPClassModule

function Class.New(...)
	return setmetatable( BaseSCPClassModule.New(...) , Class)
end

function Class:Destroy()
	if not Class.super.Destroy(self) then
		return false
	end



	return true
end

function Class:Respawn()
	if not Class.super.Respawn(self) then
		return false
	end



	return true
end

return Class
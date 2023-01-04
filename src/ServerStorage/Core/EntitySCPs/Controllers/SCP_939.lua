
local BaseSCPClassModule = require(script.Parent.Parent.BaseSCP)

-- // Class // -- 
local Class = {}
Class.__index = setmetatable({ SystemsContainer = {} }, BaseSCPClassModule)
Class.super = BaseSCPClassModule

function Class.New()
	return setmetatable({}, Class)
end

return Class
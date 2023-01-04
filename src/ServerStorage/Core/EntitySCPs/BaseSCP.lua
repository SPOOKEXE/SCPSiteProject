
-- // Class // -- 
local Class = { SystemsContainer = {} }
Class.__index = Class
Class.super = false

function Class.New()
	return setmetatable({}, Class)
end

return Class
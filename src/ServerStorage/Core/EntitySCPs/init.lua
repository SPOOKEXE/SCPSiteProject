local CollectionService = game:GetService('CollectionService')

local SystemsContainer = {}

local CachedSCPModules = {}
local ControllersFolder = script:WaitForChild('Controllers')

-- // Module // --
local Module = {}

function Module:SetupEntity( Model )

end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	for _, ModuleScript in ipairs( ControllersFolder:GetChildren() ) do
		if ModuleScript:IsA('ModuleScript') then
			CachedSCPModules[ModuleScript.Name] = require(ModuleScript)
		end
	end

	for _, CachedModule in pairs( CachedSCPModules ) do
		CachedModule.SystemsContainer = SystemsContainer
	end
end

return Module

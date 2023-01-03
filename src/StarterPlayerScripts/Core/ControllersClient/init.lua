local CollectionService = game:GetService('CollectionService')

local SystemsContainer = {}

local ControllerClassCache = {}
local ActiveControllerClasses = {}

local ControllerClassFolder = script:WaitForChild('Controllers')

-- // Module // --
local Module = {}

function Module:RegisterController( Model )
	local ControllerID = Model:GetAttribute('ControllerID')
	if not ControllerID then
		--warn('ControllerID is not set on model: ' .. Model:GetFullName())
		return
	end

	local ControllerClass = ControllerClassCache[ ControllerID ]
	if not ControllerClass then
		--warn('ControllerID is not a valid controller: ' .. ControllerID .. ' using default.')
	end

	ControllerClass = ControllerClassCache.BaseController

	local Controller = ControllerClass.New( Model )
	ActiveControllerClasses[ Controller ] = ControllerClass
	return Controller
end

function Module:GetControllerClassByUUID(UUID)
	for _, Class in pairs( ActiveControllerClasses ) do
		if Class.UUID == UUID then
			return Class
		end
	end
	return false
end

function Module:GetControllerClassByModel(Model)
	for _, Class in pairs( ActiveControllerClasses ) do
		if Class.Model == Model then
			return Class
		end
	end
	return false
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	-- require all the controller classes
	ControllerClassCache.BaseController = require(script.BaseController)
	for _, ControllerModule in ipairs( ControllerClassFolder:GetChildren() ) do
		ControllerClassCache[ControllerModule.Name ] = require(ControllerModule)
	end

	-- Set the SystemsContainer for all cached modules
	for _, Cached in pairs( ControllerClassCache ) do
		Cached.SystemsContainer = SystemsContainer
	end

	for _, Model in ipairs( CollectionService:GetTagged('Controllers') ) do
		Module:RegisterController( Model )
	end

	CollectionService:GetInstanceAddedSignal('Controllers'):Connect(function(Model)
		Module:RegisterController( Model )
	end)
end

return Module

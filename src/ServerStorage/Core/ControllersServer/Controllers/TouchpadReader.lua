local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local InteractionService = ReplicatedModules.Services.InteractionService
local RemoteService = ReplicatedModules.Services.RemoteService
local ControllerEffectsRemote = RemoteService:GetRemote('ControllerEffectsRemote', 'RemoteEvent', false)

local BaseControllerClassModule = require(script.Parent.Parent.BaseController)

-- // Class // --
local Class = setmetatable({SystemsContainer = {}}, BaseControllerClassModule)
Class.__index = Class
Class.super = BaseControllerClassModule

function Class.New( ... )
	local self = setmetatable(BaseControllerClassModule.New(...), Class)

	local Busy = false
	InteractionService:OnInteracted( self.Model.Part, function()

		self:Toggle()

	end, function()
		if Busy then
			return false, 'Door is currently busy.'
		end
		Busy = true
		-- scan effect
		ControllerEffectsRemote:FireAllClients('TouchpadScanEffect', self.Model.Part.RedScanBeam)
		task.wait(0.5)
		task.delay(1, function()
			Busy = false
		end)
		-- check if they can use the touchpad
		return true, 'Successfully scanned for ID.'
	end)

	return self
end

function Class:Update()
	if not Class.super.Update(self) then
		return false
	end
	return true
end

return Class

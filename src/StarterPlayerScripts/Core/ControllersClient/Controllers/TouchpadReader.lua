local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local RemoteService = ReplicatedModules.Services.RemoteService
local ControllerEffectsRemote = RemoteService:GetRemote('ControllerEffectsRemote', 'RemoteEvent', false)

local DoorUtilityModule = ReplicatedModules.Utility.DoorUtility

local BaseControllerClassModule = require(script.Parent.Parent.BaseController)

-- // Class // --
local Class = setmetatable({ClassName = 'TouchpadReader', SystemsContainer = {}}, BaseControllerClassModule)
Class.__index = Class
Class.super = BaseControllerClassModule

function Class.New( ... )
	local self = setmetatable(BaseControllerClassModule.New(...), Class)

	local Beam = self.Model.Part.RedScanBeam
	Beam.Color = ColorSequence.new(Color3.new())

	return self
end

ControllerEffectsRemote.OnClientEvent:Connect(function(...)
	local Args = {...}
	local Job = table.remove(Args, 1)
	if Job == 'TouchpadScanEffect' then
		DoorUtilityModule:RunScanBeamEffect( Args[1] , 2)
	end
end)

return Class

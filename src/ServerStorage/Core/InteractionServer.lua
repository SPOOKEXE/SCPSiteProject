
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local InteractionService = ReplicatedModules.Services.InteractionService

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	local EnabledAll = false
	InteractionService:OnInteracted(workspace.TestButtonAll, function(LocalPlayer, Args)
		EnabledAll = not EnabledAll
		SystemsContainer.AlarmService:ToggleAlarmOfID('Orbit', false, EnabledAll)
	end, function()
		return true
	end)

	local EnabledS1 = false
	InteractionService:OnInteracted(workspace.TestButtonS1, function(LocalPlayer, Args)
		EnabledS1 = not EnabledS1
		SystemsContainer.AlarmService:ToggleAlarmOfID('Orbit', 'Sector1', EnabledS1)
	end, function()
		return true
	end)

	local EnabledS2 = false
	InteractionService:OnInteracted(workspace.TestButtonS2, function(LocalPlayer, Args)
		EnabledS2 = not EnabledS2
		SystemsContainer.AlarmService:ToggleAlarmOfID('Orbit', 'Sector2', EnabledS2)
	end, function()
		return true
	end)
end

return Module


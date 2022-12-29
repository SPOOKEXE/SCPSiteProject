
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local InteractionService = ReplicatedModules.Services.InteractionService

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	local Enabled = false
	InteractionService:OnInteracted(workspace.TestButton, function(LocalPlayer, Args)
		-- print(LocalPlayer.Name, Args)

		Enabled = not Enabled
		SystemsContainer.AlarmService:ToggleAlarmOfID('Orbit', false, Enabled)

	end, function()
		return true
	end)
end

return Module



local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local InteractionService = ReplicatedModules.Services.InteractionService

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	InteractionService:OnInteracted(workspace.TestButton, function(Args)
		-- print(Args)
	end, function()
		return true
	end):SetFireArgs({Works = true})
end

return Module


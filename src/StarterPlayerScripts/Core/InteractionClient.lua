
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local InteractionService = ReplicatedModules.Services.InteractionService

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	InteractionService:OnInteracted(workspace.TestButtonAll, function(Args)
		-- print(Args)
	end, function()
		return true
	end)

	InteractionService:OnInteracted(workspace.TestButtonS1, function(Args)
		-- print(Args)
	end, function()
		return true
	end)

	InteractionService:OnInteracted(workspace.TestButtonS2, function(Args)
		-- print(Args)
	end, function()
		return true
	end)
end

return Module


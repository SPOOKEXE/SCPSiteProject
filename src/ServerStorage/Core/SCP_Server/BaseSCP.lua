
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local SCPConfigModule = ReplicatedModules.Data.SCPConfig
local MaidClassModule = ReplicatedModules.Classes.Maid

-- // Class // --
local Class = { SystemsContainer = {} }
Class.__index = Class
Class.super = false

function Class.New(SCP_ID)
	local ConfigTable = SCPConfigModule:GetConfigFromID( SCP_ID )

	local self = setmetatable({
		SCP_ID = SCP_ID,
		ConfigTable = ConfigTable,

		Maid = MaidClassModule.New(),
	}, Class)

	return self
end

function Class:IsAvailableToPlayer(LocalPlayer)
	return false
end

function Class:IsPlayerThisSCP(LocalPlayer)
	return false
end

function Class:SetPlayerAsSCP(LocalPlayer)
	return false
end

function Class:RemovePlayerFromSCP(LocalPlayer)
	return false
end

function Class:OnPlayerAction(LocalPlayer, ActionName, ...)
	return false, 'BaseClasss has no action setup for action of id ' .. tostring(ActionName)
end

function Class:Destroy()
	self.Maid:Cleanup()
	return true
end

function Class:Respawn()
	return true
end

return Class
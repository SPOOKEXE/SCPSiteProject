local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local MaidInstanceClass = ReplicatedModules.Classes.Maid

-- // Module // --
local Module = { SystemsContainer = {} }

Module.ActivePlayer = false
Module.ActorMaid = MaidInstanceClass.New()

function Module:IsAvailableToPlayer(LocalPlayer) -- can use local player for gamepass checks
	return (Module.ActivePlayer == nil)
end

function Module:IsPlayerThisSCP(LocalPlayer)
	return Module.ActivePlayer == LocalPlayer
end

function Module:SetPlayerAsSCP(LocalPlayer)
	if LocalPlayer == Module.ActivePlayer then
		return false
	end

	Module.ActorMaid:Cleanup()

	Module.ActivePlayer = LocalPlayer
	if LocalPlayer then
		print(LocalPlayer.Name, 'setup 079 stuff')
		-- Setup player character + camera + ui through remotes
	end
end

function Module:RemovePlayerSCP(LocalPlayer)
	Module:SetPlayerAsSCP(nil)
end

function Module:OnPlayerAction(LocalPlayer, ActionName, ...)
	local Args = {...}
	print('SCP-079 Actions - ', LocalPlayer.Name, ActionName, Args)
end

return Module

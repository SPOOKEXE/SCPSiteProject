local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local MaidInstanceClass = ReplicatedModules.Classes.Maid

-- // Module // --
local Module = { SystemsContainer = {} }

Module.ActivePlayers = {}
Module.ActorPlayerMaids = {}

function Module:IsSCPAvailableTo(LocalPlayer) -- can use local player for gamepass checks
	return #Module.ActivePlayers < 2 and (not table.find(Module.ActivePlayers, LocalPlayer))
end

function Module:IsPlayerSCP(LocalPlayer)
	return table.find(Module.ActivePlayers, LocalPlayer)
end

function Module:RemovePlayerFromSCP(LocalPlayer)
	if Module:IsPlayerSCP(LocalPlayer) then

		local index = table.find(Module.ActivePlayers)
		if index then
			table.remove(Module.ActivePlayers, index)
		end

		if Module.ActorPlayerMaids[ LocalPlayer ] then
			Module.ActorPlayerMaids[ LocalPlayer ]:Cleanup()
		end
		Module.ActorPlayerMaids[ LocalPlayer ] = nil

		-- tell client to reset
		-- reset player
	end
end

function Module:SetPlayerAsSCP(LocalPlayer)
	if not Module.ActorPlayerMaids[ LocalPlayer ] then
		Module.ActorPlayerMaids[ LocalPlayer ] = MaidInstanceClass.New()
	end
	Module.ActorPlayerMaids[ LocalPlayer ]:Cleanup()

	table.insert(Module.ActorPlayerMaids, LocalPlayer)

	print(LocalPlayer.Name, 'setup 939 stuff')
	-- Setup player character + ui through remotes
end

function Module:OnPlayerAction(LocalPlayer, ActionName, ...)
	local Args = {...}
	print('SCP-939 Actions - ', LocalPlayer.Name, ActionName, Args)
end

return Module

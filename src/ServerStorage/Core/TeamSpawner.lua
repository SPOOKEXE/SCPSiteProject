local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Teams = game:GetService('Teams')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local GroupDataModule = ReplicatedModules.Data.GroupData
local MaidInstanceClass = ReplicatedModules.Classes.Maid

local RemoteService = ReplicatedModules.Services.RemoteService
local MainMenuFunction = RemoteService:GetRemote('MainMenuFunction', 'RemoteFunction', false)

local SystemsContainer = {}

local PlayerMaidCache = {}

-- // Module // --
local Module = {}

function Module:SetupPlayerSpawner(LocalPlayer)
	if PlayerMaidCache[LocalPlayer] then
		return
	end
	PlayerMaidCache[LocalPlayer] = MaidInstanceClass.New()

	PlayerMaidCache[LocalPlayer]:Give(LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
		NewCharacter:WaitForChild('Humanoid').Died:Connect(function()
			task.wait(3)
			if PlayerMaidCache[LocalPlayer] then
				LocalPlayer:LoadCharacter()
			end
		end)
	end))

	task.defer(function()
		LocalPlayer:LoadCharacter()
	end)
end

function Module:RemovePlayerSpawner(LocalPlayer)
	if PlayerMaidCache[LocalPlayer] then
		PlayerMaidCache[LocalPlayer]:Cleanup()
		PlayerMaidCache[LocalPlayer] = nil
	end
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	MainMenuFunction.OnServerInvoke = function(LocalPlayer, Job, ...)
		local Args = {...}
		print(LocalPlayer.Name, Job, Args)
		if Job == 'Spawn' and GroupDataModule:CanJoinTeam(LocalPlayer, Args[1]) then
			LocalPlayer.Team = Teams[ Args[1] ]
			Module:SetupPlayerSpawner(LocalPlayer)
			return true
		elseif Job == 'Menu' then
			Module:RemovePlayerSpawner(LocalPlayer)
			return true
		end
		return false
	end
end

return Module

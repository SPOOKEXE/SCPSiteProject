local Players = game:GetService("Players")

local SystemsContainer = {}

local CachedSCPModules = {}
local PlayerToSCPName = {}
local ControllersFolder = script:WaitForChild('Controllers')

-- // Module // --
local Module = {}

function Module:SetPlayerAsSCP(LocalPlayer, SCP_Name)
	print(LocalPlayer.Name, SCP_Name)

	local CacheSCP = CachedSCPModules[ SCP_Name ]
	if not CacheSCP then
		return false
	end

	if not CacheSCP:IsSCPAvailableTo(LocalPlayer) then
		return false
	end

	local DidSetPlayerAsSCP = CacheSCP:SetPlayerAsSCP( LocalPlayer )
	if not DidSetPlayerAsSCP then
		return false
	end

	PlayerToSCPName[LocalPlayer] = SCP_Name

	return true
end

function Module:RemovePlayerFromSCP(LocalPlayer)
	local SCP_Name = PlayerToSCPName[LocalPlayer]
	if not SCP_Name then
		return false
	end
	CachedSCPModules[ SCP_Name ]:RemovePlayerFromSCP( LocalPlayer )
	return true
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	for _, ModuleScript in ipairs( ControllersFolder:GetChildren() ) do
		if ModuleScript:IsA('ModuleScript') then
			CachedSCPModules[ModuleScript.Name] = require(ModuleScript)
		end
	end

	for _, CachedModule in pairs( CachedSCPModules ) do
		CachedModule.SystemsContainer = SystemsContainer
	end

	Players.PlayerRemoving:Connect(function(LocalPlayer)
		Module:RemovePlayerFromSCP(LocalPlayer)
	end)
end

return Module

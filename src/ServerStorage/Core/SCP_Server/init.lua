local Players = game:GetService('Players')
local CollectionService = game:GetService('CollectionService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local SCPConfigModule = ReplicatedModules.Data.SCPConfig

local RemoteService = ReplicatedModules.Services.RemoteService
local SCPEntityEvent = RemoteService:GetRemote('SCPEntityEvent', 'RemoteEvent', false)
local SCPEntityFunction = RemoteService:GetRemote('SCPEntityFunction', 'RemoteFunction', false)

local SystemsContainer = {}

local CachedSCPEntityClasses = {}
local CachedSCPPlayerClasses = {}

local PlayerToSCPClass = {}
local SCPModelToSCPClass = {}

local EntitiesFolder = script:WaitForChild('Entities')
local PlayerControlsFolder = script:WaitForChild('Player')

-- // Module // --
local Module = {}

function Module:IsPlayerAnSCP(LocalPlayer)
	return PlayerToSCPClass[LocalPlayer]
end

function Module:GetSCPIDFromPlayer(LocalPlayer)
	local SCP_ID = LocalPlayer:GetAttribute('SCP_ID')
	if not SCP_ID then
		warn(LocalPlayer.Name .. ' has no set SCP_ID.')
	end
	return SCP_ID or false
end

function Module:GetSCPClassFromSCPModel(SCPModel)
	return SCPModelToSCPClass[SCPModel]
end

function Module:SetPlayerAsSCP(LocalPlayer, SCP_ID)
	local ActiveClass = PlayerToSCPClass[ LocalPlayer ]
	if ActiveClass then
		return ActiveClass
	end

	local CachedClass = CachedSCPPlayerClasses[ SCP_ID ]
	if not CachedClass then
		warn('Cannot find SCP class given id ' .. tostring(SCP_ID))
		return false
	end

	ActiveClass = CachedClass.New( LocalPlayer )
	PlayerToSCPClass[ LocalPlayer ] = ActiveClass
	return ActiveClass
end

function Module:AttemptToSetPlayerSCPFromID(LocalPlayer)
	local SCP_ID = Module:GetSCPIDFromPlayer(LocalPlayer)
	if not SCP_ID then
		return false
	end
	return Module:SetPlayerAsSCP(LocalPlayer, SCP_ID)
end

function Module:RemovePlayerFromSCP(LocalPlayer)
	local ActiveSCPClass = PlayerToSCPClass[LocalPlayer]
	if not ActiveSCPClass then
		return
	end
	ActiveSCPClass:Destroy()
	PlayerToSCPClass[LocalPlayer] = nil
end

function Module:SetupSCPEntity( Model )
	local Active = Module:GetSCPClassFromSCPModel(Model) -- is a table or nil
	if Active then
		return Active
	end

	local SCP_ID = Model.Name

	local SCPClassModule = CachedSCPEntityClasses[SCP_ID]
	if not SCPClassModule then
		warn('Cannot find SCP class given id ' .. tostring(SCP_ID) .. ' for ' .. Model:GetFullName())
		return false
	end

	Active = SCPClassModule.New( Model )
	SCPModelToSCPClass[Model] = Active
	return Active
end

function Module:CacheModulesIntoTable(Parent, CacheTable)
	for _, ModuleScript in ipairs( Parent:GetChildren() ) do
		if ModuleScript:IsA('ModuleScript') then
			local Cached = require(ModuleScript)
			Cached.SystemsContainer = SystemsContainer
			CacheTable[ModuleScript.Name] = Cached
		end
	end
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	Module:CacheModulesIntoTable(EntitiesFolder, CachedSCPEntityClasses)
	Module:CacheModulesIntoTable(PlayerControlsFolder, CachedSCPPlayerClasses)

	for _, Model in ipairs( CollectionService:GetTagged('SCPEntity') ) do
		Module:SetupEntity( Model )
	end

	for _, LocalPlayer in ipairs( CollectionService:GetTagged('SCPPlayer') ) do
		Module:CheckPlayerForSCPID(LocalPlayer)
	end

	CollectionService:GetInstanceAddedSignal('SCPPlayer'):Connect(function(LocalPlayer)
		Module:CheckPlayerForSCPID(LocalPlayer)
	end)

	CollectionService:GetInstanceAddedSignal('SCPEntity'):Connect(function(Model)
		Module:SetupEntity( Model )
	end)

	Players.PlayerRemoving:Connect(function(LocalPlayer)
		Module:RemovePlayerFromSCP(LocalPlayer)
	end)
end

return Module

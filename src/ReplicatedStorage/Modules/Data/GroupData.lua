local RunService = game:GetService('RunService')
local Teams = game:GetService('Teams')

-- // Module // --
local Module = {}

Module.GroupIds = {
	Main = 16573733,

	AdministrativeDepartment = 16608442,
	InternalSecurityDepartment = -1,
	IntelligenceAgency = -1,
	ExternalAffairs = -1,
	EthicsCommittee = -1,
	LogisticsDepartment = -1,
	ManufacturingDepartment = 16608495,
	MedicalDepartment = 16608482,
	MobileTaskForce = -1,
	ScientificDepartment = 16608450,
	SecurityDepartment = 16608473,
	EngineeringAndTechnical = 16608446,
	TribunalDepartment = -1,
	ChaosInsurgency = -1,
}

Module.Teams = {
	['Administrative Department'] = {
		GroupId = Module.GroupIds.AdministrativeDepartment,
		Rank = 1,
		Icon = 'rbxassetid://11939980149',
	},
	['Internal Security Department'] = {
		GroupId = Module.GroupIds.InternalSecurityDepartment,
		Rank = 1,
		Icon = 'rbxassetid://11939979996',
	},
	['Intelligence Agency'] = {
		GroupId = Module.GroupIds.IntelligenceAgency,
		Rank = 1,
		Icon = 'rbxassetid://11938750246',
	},
	['External Affairs'] = {
		GroupId = Module.GroupIds.ExternalAffairs,
		Rank = 1,
		Icon = 'rbxassetid://11938754158',
	},
	['Ethics Committee'] = {
		GroupId = Module.GroupIds.EthicsCommittee,
		Rank = 1,
		Icon = 'rbxassetid://11939980239',
	},
	['Logistics Department'] = {
		GroupId = Module.GroupIds.LogisticsDepartment,
		Rank = 1,
		Icon = 'rbxassetid://11939980204',
	},
	['Manufacturing Department'] = {
		GroupId = Module.GroupIds.ManufacturingDepartment,
		Rank = 1,
		Icon = 'rbxassetid://11939980287',
	},
	['Medical Department'] = {
		GroupId = Module.GroupIds.MedicalDepartment,
		Rank = 1,
		Icon = 'rbxassetid://11939980339',
	},
	['Mobile Task Force'] = {
		GroupId = Module.GroupIds.MobileTaskForce,
		Rank = 1,
		Icon = 'rbxassetid://11938750867',
	},
	['Scientific Department'] = {
		GroupId = Module.GroupIds.ScientificDepartment,
		Rank = 1,
		Icon = 'rbxassetid://11938759720',
	},
	['Security Department'] = {
		GroupId = Module.GroupIds.SecurityDepartment,
		Rank = 1,
		Icon = 'rbxassetid://11939980310',
	},
	['Engineering and Technical'] = {
		GroupId = Module.GroupIds.EngineeringAndTechnical,
		Rank = 1,
		Icon = 'rbxassetid://11938760875',
	},
	['Tribunal Department'] = {
		GroupId = Module.GroupIds.TribunalDepartment,
		Rank = 1,
		Icon = 'rbxassetid://11938749669',
	},
	['Foundation Personnel'] = {
		GroupId = Module.GroupIds.Main,
		Rank = 2, -- Level-0
		Icon = 'rbxassetid://11938738548',
	},
	['Class-D'] = {
		GroupId = false,
		Rank = -1,
		Icon = 'rbxassetid://11938738548',
	},
	['Chaos-Insurgency'] = {
		GroupId = Module.GroupIds.ChaosInsurgency,
		Rank = 1,
		Icon = 'rbxassetid://11939980091',
	},

	-- magnify glass 11939980155 https://www.roblox.com/library/11939980155/SCP-LOGO-4
}

function Module:GetClearance(LocalPlayer)
	-- studio testing
	if RunService:IsStudio() then
		return 7
	end
	-- get rank in group <2 = Guest & Class-D
	local rank = LocalPlayer:GetRankInGroup(Module.GroupIds.Main)
	if rank < 2 then
		return -1
	elseif rank > 253 then
		return 6 -- OMNI
	end
	return math.clamp(rank - 2, 0, 5) -- 5 = Level 5, 0 = Level 0
end

function Module:CanJoinTeam(LocalPlayer, teamName)
	-- If they have omni clearance
	local clearance = Module:GetClearance(LocalPlayer)
	if clearance == 6 then
		return true
	end

	-- If the team does not exist
	local teamObject = teamName and Teams:FindFirstChild(teamName)
	if not teamObject then
		return false
	end

	-- if they want class-d, available to all
	if teamName == "Class-D" then--and clearance == -1 then
		return true
	elseif teamName == "Foundation Personnel" and clearance >= 0 then -- foundation personnel for L0+
		return true
	end

	-- if there is group configuration for that team, otherwise always deny
	if Module.Teams[teamName] == nil then
		return false
	end

	-- if they have the required rank in the group
	local teamData = Module.Teams[teamName]
	return LocalPlayer:GetRankInGroup(teamData.GroupId) >= teamData.rank
end

return Module

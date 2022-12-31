
local HttpService = game:GetService('HttpService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local DoorConfigModule = ReplicatedModules.Data.DoorConfig

local MaidInstanceClass = ReplicatedModules.Classes.Maid

type ClearanceConfigTable = {
	KeyLevel : number,
	Clearance : {
		AD 	: boolean,
		EC 	: boolean,
		ET 	: boolean,
		IA 	: boolean,
		ISD : boolean,
		LD 	: boolean,
		MD 	: boolean,
		MTF : boolean,
		MaD : boolean,
		SD 	: boolean,
		ScD : boolean,
		O5 	: boolean,
	},
}

type DoorConfigTable = {
	ID : string,
	DoorClassID : string,
	ClearanceConfig : ClearanceConfigTable | { ClearanceConfigTable }, -- can be one ClearanceConfigTable or an array of them
	CooldownPeriod : number,
	AutoClosePeriod : number,
}

local function GetToolData( Tool )
	if typeof(Tool) ~= 'Instance' then
		return false
	end
	return Tool:GetAttribute('Level'), Tool:GetAttribute('Department')
end

-- // Class // --
local Class = { SystemsContainer = {} }
Class.__index = Class

function Class.New(Model, forceState)
	local ConfigTable = DoorConfigModule:GetDoorConfig( Model.Name ) :: DoorConfigTable
	local DoorUUID = HttpService:GenerateGUID(false)

	Model:SetAttribute('StateEnabled', (forceState == true))
	Model:SetAttribute('DoorID', ConfigTable.DoorClassID)
	Model:SetAttribute('DoorDestroyed', false)
	Model:SetAttribute('PowerEnabledOverride', false)
	Model:SetAttribute('ControlPanelOverride', false)
	Model:SetAttribute('SCP079Override', false)
	Model:SetAttribute('IsDoorBroken', false)
	Model:SetAttribute('DoorSector', false)
	Model:SetAttribute('DoorUUID', DoorUUID)

	local self = setmetatable({
		UUID = DoorUUID,

		Model = Model,
		BackupModel = Model:Clone(),

		DoorMaid = MaidInstanceClass.New(),
		DoorControlNodes = {},
		Config = ConfigTable,

		_LastState = nil, -- last state of the door
	}, Class)

	local DoorModel = Model:FindFirstChild('Door')
	if typeof(DoorModel) ~= 'Instance' or (not DoorModel:IsA('Model')) then
		DoorModel = Model
	end

	local boundCF, boundSize = DoorModel:GetBoundingBox()
	local bPart = Instance.new('Part')
	bPart.Name = 'Detector'
	bPart.CFrame = boundCF
	bPart.Size = boundSize
	bPart.Anchored = true
	bPart.CastShadow = false
	bPart.Transparency = 1
	bPart.CanCollide = false
	bPart.CanTouch = false
	bPart.Parent = Model

	self:Setup()

	return self
end

function Class:GetAttribute(attribute)
	self.Model:GetAttribute(attribute)
end

function Class:SetAttribute(attribute, value)
	self.Model:SetAttribute(attribute, value)
end

function Class:GetAttributeChangedSignal(attribute)
	return self.Model:GetAttributeChangedSignal(attribute)
end

function Class:SetupControllerNode( ObjectVal )
	local ControllerNodeState = (ObjectVal and ObjectVal.Value) and ObjectVal.Value
	if not ControllerNodeState then
		warn('Could not find door controller: ' .. self.Model:GetFullName())
		return
	end

	task.spawn(function()
		self:Toggle( ObjectVal.Value:GetAttribute('StateValue') )
	end)

	self.DoorMaid:Give(ObjectVal.Value:GetAttributeChangedSignal('StateValue'):Connect(function()
		self:Toggle( ObjectVal.Value:GetAttribute('StateValue') )
	end))
end

function Class:SetPowerDisabledOverride( isPowerDisabled )
	self:SetAttribute('PowerEnabledOverride', isPowerDisabled)
end

function Class:SetCommandControlOverride( isControlled )
	self:SetAttribute('ControlPanelOverride', isControlled)
end

function Class:Set079ControlOverride( isControlled )
	self:SetAttribute('SCP079Override', isControlled)
end

function Class:IsPlayer079( LocalPlayer )
	return LocalPlayer:GetAttribute('IsSCP079')
end

function Class:HasClearance( ClearanceConfigTable, HighestLevel, Departments )
	if #ClearanceConfigTable == 0 then
		ClearanceConfigTable = { ClearanceConfigTable }
	end
	for _, ClearanceConfig in ipairs( ClearanceConfigTable ) do
		-- If they have any high enough level OR the correct department cards then allow access
		local enoughKeyLevel = (HighestLevel >= ClearanceConfig.KeyLevel)
		local hasAllowedDepartment = false
		-- Check if they have a allowed department
		for _, departmentIndex in ipairs( Departments ) do
			hasAllowedDepartment = ClearanceConfig.Clearance[departmentIndex]
			if hasAllowedDepartment then
				break
			end
		end
		if enoughKeyLevel or hasAllowedDepartment then
			-- warn( HighestLevel and 'Level' or 'No Level', hasAllowedDepartment and 'Department' or 'No Department' )
			return true
		end
	end
	return false
end

function Class:CanOpen( LocalPlayer )
	if self:GetAttribute('SCP079Override') and (not self:IsPlayer079( LocalPlayer )) then
		return false
	elseif self:GetAttribute('ControlPanelOverride') then
		return false
	end

	local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
	local ClearanceConfig : ClearanceConfigTable = self.Config.ClearanceConfig

	if Humanoid.Health > 0 and ClearanceConfig and (not self:GetAttribute('ControlPanelOverride')) then
		local HighestLevel = -1
		local Departments = { }

		local function CheckToolData(Tool)
			local LevelValue, DepartmentValue = GetToolData(Tool)
			if LevelValue and LevelValue >= HighestLevel then
				HighestLevel = LevelValue
			end
			if DepartmentValue and not table.find(Departments, DepartmentValue) then
				table.insert(Departments, DepartmentValue)
			end
		end

		-- Check all tools for their level/department values
		local ActiveTool = LocalPlayer.Backpack:FindFirstChildOfClass('Tool')
		if ActiveTool then
			CheckToolData(ActiveTool)
		end
		for _, Tool in ipairs( LocalPlayer.Backpack:GetChildren() ) do
			CheckToolData(Tool)
		end

		return Class:HasClearance( ClearanceConfig, HighestLevel, Departments )
	end

	return (ClearanceConfig == nil) -- no config = open for all
end

function Class:Toggle( forcedState )
	if self:GetAttribute('DoorDestroyedValue') then
		return
	end
	if typeof(forcedState) == 'boolean' then
		self:SetAttribute('StateValue', forcedState or false)
	else
		self:SetAttribute('StateValue', self:GetAttribute('StateValue'))
	end
	--warn('Door Toggled: ', self.Config.ID, self.Config.DoorClassID, self.StateValue.Value)
end

function Class:Interact(_, TargetModel)
	if #self.DoorControlNodes > 0 then
		return false
	end
	if TargetModel ~= self.Model or self.Debounce then
		return false
	end
	--print('----', LocalPlayer, TargetModel, self.Model, self.Debounce)
	self.Debounce = true
	self:Toggle()
	task.delay(2, function()
		self.Debounce = false
	end)
	return true
end

function Class:Destroy()
	self.DoorMaid:Cleanup()
end

function Class:Setup()
	for _, ObjectVal in ipairs(self.Model:GetChildren()) do
		if ObjectVal:IsA('ObjectValue') and ObjectVal.Name == 'ControlNode' then
			self:SetupControllerNode( ObjectVal )
		end
	end

	if #self.DoorControlNodes > 0 then
		self:SetAttribute('IgnoreDoor', true)
	end

	self:GetAttributeChangedSignal('IsBrokenOverride'):Connect(function()
		if self:GetAttribute('IsBrokenOverride') then
			if Random.new():NextInteger(1, 2) == 1 then
				while self:GetAttribute('IsBrokenOverride') do
					self:Toggle()
					task.wait( 4 * Random.new():NextNumber() ) -- Random makes it much more Random ;)
				end
			else
				self:Toggle(false)
			end
		end
	end)
end

-- Reset the door back from its destroyed state
function Class:RefreshDoor()
	if self.Model then
		self.Model:Destroy()
		self.Model = nil
	end
	self.Model = self.BackupModel:Clone()
end

-- Demolish the door from its 'working' state
function Class:Demolish()
	if not self.Model then
		return
	end
	self:SetAttribute('DoorDestroyedValue', true)
	for _, BasePart in ipairs( self.Model:GetDescendants() ) do
		if BasePart:IsA('BasePart') then
			BasePart.CanCollide = true
			BasePart.Anchored = false
			BasePart.CanTouch = false
			BasePart.CanQuery = false
		end
	end
end

return Class

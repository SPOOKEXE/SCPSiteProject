-- SPOOK_EXE
local HttpService = game:GetService('HttpService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local DoorUtility = ReplicatedModules.Utility.DoorUtility

local BaseDoor = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({}, BaseDoor)
Class.__index = Class

function Class.New( ... )
	local self = setmetatable(BaseDoor.New( ... ), Class)
	self:SetAttribute('IsOpeningLeft', false)
	self:Setup()
	return self
end

function Class:ToggleDoor(LocalPlayer, scannerModel, isOpeningLeft)
	if not self.IsActivelyToggling then
		if not self:CanOpen( LocalPlayer ) then
			return false
		end
		local newUUID = HttpService:GenerateGUID(false)
		self.ToggleUUID = newUUID
		self.IsActivelyToggling = true
		DoorUtility:RunScanBeamEffect( scannerModel.Part.RedScanBeam )
		task.spawn(function()
			self:SetAttribute('IsLeftBoolean', isOpeningLeft)
			self:Toggle(true)
			task.wait(self.Config.AutoClosePeriod + 1)
			self.IsActivelyToggling = false
			self:Toggle(false)
		end)
		return true
	end
end

function Class:ScannerTrigger( LocalPlayer, ScannerHitboxPart )
	if not ScannerHitboxPart:IsDescendantOf(self.Model) then
		return false
	end
	local Model = ScannerHitboxPart
	while not Model:IsA('Model') do
		Model = Model.Parent
	end
	local readerNumber = string.sub(Model.Name, #Model.Name, #Model.Name)
	-- print(LocalPlayer, ScannerHitboxPart)
	return self:ToggleDoor(LocalPlayer, Model, readerNumber==1)
end

function Class:Setup()
	--print('Setup', script.Name, ' - Create Interaction Methods - ', self.Model:GetFullName())
	for _, Model : Model in ipairs( self.Model.Readers:GetChildren() ) do
		local boundCFrame, boundSize = Model:GetBoundingBox()
		local keyHitbox = Instance.new('Part')
		keyHitbox.Name = 'DoorCustomScanners'
		keyHitbox.Anchored = true
		keyHitbox.Transparency = 1
		keyHitbox.CanCollide = false
		keyHitbox.CanTouch = true
		keyHitbox.CFrame = boundCFrame
		keyHitbox.Size = boundSize * 1.1
		keyHitbox.Parent = Model
	end
end

return Class

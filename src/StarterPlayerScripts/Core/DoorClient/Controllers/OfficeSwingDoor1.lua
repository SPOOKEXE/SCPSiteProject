local TweenService = game:GetService('TweenService')

local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

local defaultTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoorClassModule)
Class.__index = Class
Class.super = BaseDoorClassModule

function Class.New(...)
	local self = BaseDoorClassModule.New(...)

	self.CloseCFrame = self.Model.Door:GetPivot()
	self.OpenCFrame = self.CloseCFrame * CFrame.Angles( 0, math.rad(-70), 0 )

	local CFValue = Instance.new('CFrameValue')
	CFValue.Name = 'CFrameV'
	CFValue.Changed:Connect(function()
		self.Model.Door:PivotTo( CFValue.Value )
	end)
	CFValue.Value = self.CloseCFrame
	CFValue.Parent = self.Model
	self.CFrameValue = CFValue

	return setmetatable(self, Class)
end

function Class:Demolish()
	if Class.super.Demolish(self) then
		self.CloseCFrame = nil
		self.OpenCFrame = nil
		if self.CFrameValue then
			self.CFrameValue:Destroy()
		end
		self.CFrameValue = nil
		return true
	end
	return false
end

function Class:Toggle( noSound )
	if not Class.super.Toggle(self) then
		return false
	end

	local isOpen = self:GetAttribute('StateValue')
	local nextCFrame = isOpen and self.OpenCFrame or self.CloseCFrame

	local Tween = TweenService:Create(self.CFrameValue, defaultTweenInfo, { Value = nextCFrame })
	--[[Tween.Completed:Connect(function()
		self:PlaySound( false, nil )
	end)]]
	Tween:Play()

	if not noSound then
		task.delay(0.025, function()
			self:PlaySound( isOpen, nil )
		end)
	end

	return true
end

return Class

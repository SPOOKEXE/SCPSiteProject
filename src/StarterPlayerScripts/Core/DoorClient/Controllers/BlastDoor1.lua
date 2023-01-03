local TweenService = game:GetService('TweenService')

local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

local defaultTweenInfo = TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoorClassModule)
Class.__index = Class
Class.super = BaseDoorClassModule

function Class.New(...)
	local self = setmetatable( BaseDoorClassModule.New(...), Class )

	self.CloseCFrame = self.Model.Door:GetPivot()
	self.OpenCFrame = self.CloseCFrame + Vector3.new(0, 17, 0)

	local CFValue = Instance.new('CFrameValue')
	CFValue.Name = 'CFrameV'
	CFValue.Changed:Connect(function()
		self.Model.Door:PivotTo( CFValue.Value )
	end)
	CFValue.Value = self:GetAttribute('StateValue') and self.OpenCFrame or self.CloseCFrame
	CFValue.Parent = self.Model
	self.CFrameValue = CFValue

	self:Update(true)

	return self
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

function Class:Update( noSound )
	if not Class.super.Update(self, noSound) then
		return false
	end

	local isClosed = self:GetAttribute('StateValue')
	local nextCFrame = isClosed and self.CloseCFrame or self.OpenCFrame

	local maxDeltaY = (self.OpenCFrame.Position - self.CloseCFrame.Position).Y

	local activeCFrame = self.Model.Door:GetPivot()
	local activeDeltaY = math.abs( activeCFrame.Y - nextCFrame.Y )
	local deltaDecimal = math.clamp(activeDeltaY / maxDeltaY, 0, 1)

	local activeTweenInfo = TweenInfo.new(deltaDecimal * defaultTweenInfo.Time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	local Tween = TweenService:Create(self.CFrameValue, activeTweenInfo, { Value = nextCFrame })
	Tween.Completed:Connect(function()
		self:PlaySound( false, nil )
	end)
	Tween:Play()

	if (not noSound) and (deltaDecimal > 0.1) then
		task.delay(0.025, function()
			self:PlaySound( not isClosed, nil )
		end)
	end

	return true
end

return Class

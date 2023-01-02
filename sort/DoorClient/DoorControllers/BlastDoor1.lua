local TweenService = game:GetService('TweenService')
local defaultTweenInfo = TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoorClassModule)
Class.__index = Class
Class.super = BaseDoorClassModule

function Class.New(...)
	local self = setmetatable( BaseDoorClassModule.New(...), Class )
	self:Setup()
	return self
end

function Class:Interact(_, _)
	return false
end

function Class:Setup()
	-- Controlled by lever
	self.ClosePosition = self.Model.PrimaryPart.Position
	self.OpenPosition = self.ClosePosition + Vector3.new(0, 16.5, 0)

	Class.super.Setup(self)

	--self:AdjustSounds(defaultTweenInfo.Time)
end

function Class:Toggle( noSound )
	if self._LastState == self:GetAttribute('StateValue') then
		return
	end
	self._LastState = self:GetAttribute('StateValue')

	local ClosePosition = self.ClosePosition
	local OpenPosition = self.OpenPosition
	local maxDeltaY = (OpenPosition - ClosePosition).Y

	local activePosition = self.Model:GetPivot().Position
	local targetPosition = self:GetAttribute('StateValue') and OpenPosition or ClosePosition
	local activeDeltaY = math.abs( (activePosition - targetPosition).Y )
	local deltaDecimal = activeDeltaY / maxDeltaY

	local activeTweenInfo = TweenInfo.new(deltaDecimal * defaultTweenInfo.Time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	local Tween = nil
	if self.StateValue.Value then
		Tween = TweenService:Create(self.Model.PrimaryPart, activeTweenInfo, { Position = self.OpenPosition })
	else
		Tween = TweenService:Create(self.Model.PrimaryPart, activeTweenInfo, { Position = self.ClosePosition })
	end

	Tween.Completed:Connect(function()
		self:PlaySound( false, true )
	end)
	Tween:Play()

	if not noSound then
		self:PlaySound( self.StateValue.Value, false )
	end
end

return Class

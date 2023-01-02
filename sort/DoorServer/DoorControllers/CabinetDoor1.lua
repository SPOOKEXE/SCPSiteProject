local TweenService = game:GetService('TweenService')
local defaultTweenInfo = TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoorClassModule)
Class.__index = Class

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
	--self.ClosePosition = self.Model:GetPivot().Position
	--self.OpenPosition = self.ClosePosition + Vector3.new(0, 16.5, 0)

	local nodeCFrame = self.Model.Door:GetPivot()
	self.CloseCFrame = nodeCFrame
	self.OpenCFrame = nodeCFrame * CFrame.Angles( 0, math.rad(-70), 0 )

	local CFrameValue = Instance.new('CFrameValue')
	CFrameValue.Name = 'DoorCFrameValue'
	CFrameValue.Changed:Connect(function()
		self.Model:PivotTo( CFrameValue.Value )
	end)
	CFrameValue.Value = self.CloseCFrame
	CFrameValue.Parent = self.Model
	self.CFrameValue = CFrameValue

	local HttpService = game:GetService('HttpService')
	local proximityPrompt = Instance.new('ProximityPrompt')
	proximityPrompt.Name = 'ToggleDoorPrompt'
	proximityPrompt.Enabled = true
	proximityPrompt.ActionText = 'Toggle Door'
	proximityPrompt.ObjectText = 'Cabinet Door'
	proximityPrompt.ClickablePrompt = true
	proximityPrompt.KeyboardKeyCode = Enum.KeyCode.F
	proximityPrompt.HoldDuration = 2
	proximityPrompt.MaxActivationDistance = 10
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally

	local ToggleUUID = HttpService:GenerateGUID(false)
	proximityPrompt.Triggered:Connect(function(LocalPlayer)
		if self:CanOpen( LocalPlayer ) then
			local newUUID = HttpService:GenerateGUID(false)
			ToggleUUID = newUUID
			proximityPrompt.Enabled = false
			self:Toggle( )
			task.wait(self.Config.CooldownPeriod)
			proximityPrompt.Enabled = true
			if self:GetAttribute('StateValue') and self.Config.AutoClosePeriod then
				task.delay( self.Config.AutoClosePeriod, function()
					if ToggleUUID == newUUID then
						proximityPrompt.Enabled = false
						self:Toggle()
						task.wait(self.Config.CooldownPeriod)
						proximityPrompt.Enabled = true
					end
				end)
			end
		end
	end)
	proximityPrompt.Parent = self.Model.PromptNode

	--self:AdjustSounds(defaultTweenInfo.Time)
end

function Class:Toggle(noSound)
	if self._LastState == self:GetAttribute('StateValue') then
		return
	end
	self._LastState = self:GetAttribute('StateValue')

	local Tween = nil
	if self:GetAttribute('StateValue') then
		Tween = TweenService:Create(self.CFrameValue, defaultTweenInfo, { Value = self.OpenCFrame })
	else
		Tween = TweenService:Create(self.CFrameValue, defaultTweenInfo, { Value = self.CloseCFrame })
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

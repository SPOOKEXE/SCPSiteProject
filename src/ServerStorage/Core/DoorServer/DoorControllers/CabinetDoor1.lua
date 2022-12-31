local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = { SystemsContainer = {} }
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

	--[[
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
	]]
end

return Class

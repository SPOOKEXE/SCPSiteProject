-- SPOOK_EXE
local BaseDoor = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({ SystemsContainer = {} }, BaseDoor)
Class.__index = Class

function Class.New( ... )
	local self = setmetatable(BaseDoor.New( ... ), Class)
	self:Setup()
	return self
end

function Class:Setup()
	local HttpService = game:GetService('HttpService')

	local CD1 = self.Model.Buttons.Button1.Button.ClickDetector
	local CD2 = self.Model.Buttons.Button2.Button.ClickDetector

	local ToggleUUID = HttpService:GenerateGUID(false)
	local Debounce = true

	local function OnClick( LocalPlayer )
		if self:CanOpen( LocalPlayer ) and Debounce then
			local newUUID = HttpService:GenerateGUID(false)
			ToggleUUID = newUUID
			Debounce = false
			CD1.MaxActivationDistance = 0
			CD2.MaxActivationDistance = 0
			self:Toggle( )
			task.wait(self.Config.CooldownPeriod)
			Debounce = true
			CD1.MaxActivationDistance = 32
			CD2.MaxActivationDistance = 32
			if self:GetAttribute('StateValue') and self.Config.AutoClosePeriod then
				task.delay( self.Config.AutoClosePeriod, function()
					if ToggleUUID == newUUID then
						Debounce = false
						CD1.MaxActivationDistance = 0
						CD2.MaxActivationDistance = 0
						self:Toggle()
						task.wait(self.Config.CooldownPeriod)
						Debounce = true
						CD1.MaxActivationDistance = 32
						CD2.MaxActivationDistance = 32
					end
				end)
			end
		end
	end

	CD1.MouseClick:Connect(OnClick)
	CD2.MouseClick:Connect(OnClick)
end

return Class

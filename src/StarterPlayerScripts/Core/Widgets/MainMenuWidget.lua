local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')
local LocalModules = require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Modules'))

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')
local MainMenuFrame = Interface:WaitForChild('MainMenuFrame')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local SystemsContainer = {}

-- // Module // --
local Module = { Open = false }
Module.WidgetMaid = ReplicatedModules.Classes.Maid.New()

function Module:ToggleMenuFrame(ButtonTargetFrame)
	for _, Frame in ipairs( MainMenuFrame.ActiveFrame:GetChildren() ) do
		if Frame:IsA('Frame') then
			Frame.Visible = (ButtonTargetFrame == Frame)
		end
	end
end

function Module:UpdateWidget()
	if not Module.Open then
		return
	end

end

function Module:OpenWidget()
	if Module.Open then
		return
	end
	Module.Open = true

	for _, Frame in ipairs( MainMenuFrame.MenuButtons:GetChildren() ) do
		if Frame:IsA('Frame') then
			local TargetFrame = MainMenuFrame.ActiveFrame:FindFirstChild(Frame.Name..'Frame')
			if not TargetFrame then
				warn('Cannot find frame for button: '..Frame.Name)
				continue
			end
			Module.WidgetMaid:Give(Frame.Button.Activated:Connect(function()
				print('button sound')
				Module:ToggleMenuFrame(TargetFrame)
			end))
		end
	end

	MainMenuFrame.Visible = true
	Module:UpdateWidget()
end

function Module:CloseWidget()
	if not Module.Open then
		return
	end
	Module.Open = false

	MainMenuFrame.Visible = false
	Module.WidgetMaid:Cleanup()
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	Module:OpenWidget()
end

return Module

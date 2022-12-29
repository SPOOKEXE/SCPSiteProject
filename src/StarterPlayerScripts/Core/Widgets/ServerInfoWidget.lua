local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')
local LocalModules = require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Modules'))

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')
local ServerInfoFrame = Interface:WaitForChild('ServerInfoFrame')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local SystemsContainer = {}

local BASE_LABEL_TEXT = '<b><font color="rgb(176,77,73)">%s</font> %s in <font color="rgb(255,0,0)">%s</font></b>'

-- // Module // --
local Module = { Open = false }
Module.WidgetMaid = ReplicatedModules.Classes.Maid.New()

function Module:UpdateWidget()
	if not Module.Open then
		return
	end
	local TOTAL_PLAYERS = #Players:GetPlayers()
	ServerInfoFrame.PlayerCountLabel.Text = string.format(BASE_LABEL_TEXT, TOTAL_PLAYERS, TOTAL_PLAYERS>0 and 'player' or 'players', game.Name)
end

function Module:OpenWidget()
	if Module.Open then
		return
	end
	Module.Open = true

	ServerInfoFrame.Visible = true
	Module.WidgetMaid:Give(Players.PlayerAdded:Connect(function()
		Module:UpdateWidget()
	end))
	Module:UpdateWidget()
end

function Module:CloseWidget()
	if not Module.Open then
		return
	end
	Module.Open = false
	ServerInfoFrame.Visible = false
	Module.WidgetMaid:Cleanup()
end

function Module:Init( otherSystems )
	SystemsContainer = otherSystems

	Module:OpenWidget()
end

return Module

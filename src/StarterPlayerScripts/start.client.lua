
local ReplicatedStorage = game:GetService('ReplicatedStorage')
require(ReplicatedStorage:WaitForChild('Modules'))
require(ReplicatedStorage:WaitForChild('Core'))

local LocalPlayer = game:GetService('Players').LocalPlayer
ReplicatedStorage.Interface.Parent = LocalPlayer.PlayerGui

require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Modules'))
require(LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Core'))

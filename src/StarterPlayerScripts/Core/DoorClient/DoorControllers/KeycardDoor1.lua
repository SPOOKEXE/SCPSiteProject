-- SPOOK_EXE
local HttpService = game:GetService('HttpService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))
local DoorUtility = ReplicatedModules.Utility.DoorUtility

local BaseDoorClassModule = require(script.Parent.Parent.BaseDoor)

-- // Class // --
local Class = setmetatable({}, BaseDoorClassModule)
Class.__index = Class
Class.super = BaseDoorClassModule

function Class.New( ... )
	local self = setmetatable(BaseDoorClassModule.New( ... ), Class)
	self:SetAttribute('IsOpeningLeft', false)
	self:Setup()
	return self
end

function Class:Setup()
	--print('Setup', script.Name, ' - Create Interaction Methods - ', self.Model:GetFullName())
end

function Class:Toggle()
   -- TODO: change model
end

return Class

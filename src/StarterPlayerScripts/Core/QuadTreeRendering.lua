local RunService = game:GetService('RunService')

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild('Modules'))

local QuadTreeClass = ReplicatedModules.Classes.QuadTree

local CurrentCamera = workspace.CurrentCamera

local SystemsContainer = {}

local RenderCacheFolder = Instance.new('Folder')
RenderCacheFolder.Name = 'RenderCacheFolder'
RenderCacheFolder.Parent = ReplicatedStorage

local RenderNodeQuadTree = false
local VisibleBoundaryRectangle = false

local UPDATE_INTERVAL = 0.1 -- 0.5
local RENDER_DISTANCE = 64

-- // Module // --
local Module = {}

function Module:SetupQuadTreeRenderer()

	local RenderNodeFolder = workspace:WaitForChild('RenderNodes')
	for _, RenderNodePart in ipairs( RenderNodeFolder:GetChildren() ) do
		local PropsModelInstance = RenderNodePart.PropsModel.Value
		if not PropsModelInstance then
			warn('Render Node Part has no PropsModel Value: ' .. RenderNodePart:GetFullName())
			continue
		end
		local NodePosition = RenderNodePart.Position
		local NodePoint = QuadTreeClass.Point.New(NodePosition.x, NodePosition.z)
		NodePoint._data = { PropModelInstance = PropsModelInstance, VisiblePropParent = PropsModelInstance.Parent }
		PropsModelInstance.Parent = RenderCacheFolder
		RenderNodeQuadTree:Insert(NodePoint)
	end

	RenderNodeQuadTree:Show(10)

	local UpdateMaid = ReplicatedModules.Classes.Maid.New()
	local ActivePoints = {}
	VisibleBoundaryRectangle = QuadTreeClass.Rectangle.New(0,0,RENDER_DISTANCE,RENDER_DISTANCE)

	local _t = time()
	RunService.Heartbeat:Connect(function()
		if time() - _t < UPDATE_INTERVAL then
			return
		end
		_t = time()

		UpdateMaid:Cleanup()

		local NewPointsArray = {}

		local CharacterPoints = false
		local CharacterCFrame = LocalPlayer.Character and LocalPlayer.Character:GetPivot()
		if CharacterCFrame then
			VisibleBoundaryRectangle.x = CharacterCFrame.X
			VisibleBoundaryRectangle.y = CharacterCFrame.Z
			UpdateMaid:Give( unpack(VisibleBoundaryRectangle:Show( 10 )) )
			CharacterPoints = RenderNodeQuadTree:Query(VisibleBoundaryRectangle)
			-- Load any points that are now visible
			for _, point in ipairs( CharacterPoints ) do
				point._data.PropModelInstance.Parent = point._data.VisiblePropParent
				if not table.find(NewPointsArray, point) then
					table.insert(NewPointsArray, point)
				end
			end
		end

		VisibleBoundaryRectangle.x = CurrentCamera.CFrame.X
		VisibleBoundaryRectangle.y = CurrentCamera.CFrame.Z
		UpdateMaid:Give( unpack(VisibleBoundaryRectangle:Show( 10 )) )
		-- Load any points that are now visible
		local CameraPoints = RenderNodeQuadTree:Query(VisibleBoundaryRectangle)
		for _, point in ipairs( CameraPoints ) do
			point._data.PropModelInstance.Parent = point._data.VisiblePropParent
			if not table.find(NewPointsArray, point) then
				table.insert(NewPointsArray, point)
			end
		end

		-- Unload any points that are no longer visible
		for _, activePoint in ipairs( ActivePoints ) do
			if CameraPoints and table.find( CameraPoints, activePoint ) then
				continue
			end
			if CharacterPoints and table.find( CharacterPoints, activePoint ) then
				continue
			end
			activePoint._data.PropModelInstance.Parent = RenderCacheFolder
		end

		ActivePoints = NewPointsArray
	end)

end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	RenderNodeQuadTree = QuadTreeClass.QuadTree.New({
		capacity = 8,
		boundary = QuadTreeClass.Rectangle.New(0,0,2048,2048)
	})

	task.defer(function()
		Module:SetupQuadTreeRenderer()
	end)
end

return Module


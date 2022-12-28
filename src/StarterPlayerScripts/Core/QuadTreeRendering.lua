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
local QuadTreeMaidInstance = ReplicatedModules.Classes.Maid.New()

local UPDATE_INTERVAL = 0.5
local RENDER_DISTANCE = 32

-- // Module // --
local Module = {}

function Module:SetRenderDistance(distance)
	RENDER_DISTANCE = distance
	if VisibleBoundaryRectangle then
		VisibleBoundaryRectangle.w = distance
		VisibleBoundaryRectangle.h = distance
	end
end

function Module:GetPropModelsFromNode(NodeInstance)
	local Values = {}
	for _, Child in ipairs( NodeInstance:GetChildren() ) do
		if Child:IsA('ObjectValue') and Child.Name == 'PropsModel' then
			if Child.Value then
				table.insert(Values, Child.Value)
			else
				warn('Render Node Part has no PropsModel Value: ' .. NodeInstance:GetFullName())
			end
		end
	end
	return Values
end

function Module:GetRenderFolderNodePoints()
	local RenderNodeFolder = workspace:WaitForChild('RenderNodes')
	local NodePoints = {}
	for _, RenderNodePart in ipairs( RenderNodeFolder:GetChildren() ) do
		local RenderInstances = Module:GetPropModelsFromNode(RenderNodePart)
		if #RenderInstances == 0 then
			continue
		end

		local VisibleRenderParents = {}
		for _, ParentInstance in ipairs( RenderInstances ) do
			VisibleRenderParents[ParentInstance] = ParentInstance.Parent
			ParentInstance.Parent = RenderCacheFolder
		end

		local NodePosition = RenderNodePart.Position
		local NodePoint = QuadTreeClass.Point.New(NodePosition.x, NodePosition.z)
		NodePoint._data = { RenderInstances = VisibleRenderParents }
		table.insert(NodePoints, NodePoint)
	end

	return NodePoints
end

function Module:EnableQuadTreeRenderer()
	RenderNodeQuadTree = QuadTreeClass.QuadTree.New({ capacity = 8, boundary = QuadTreeClass.Rectangle.New(0,0,2048,2048) })
	VisibleBoundaryRectangle = QuadTreeClass.Rectangle.New(0, 0, RENDER_DISTANCE, RENDER_DISTANCE)

	local NodePoints = Module:GetRenderFolderNodePoints()
	RenderNodeQuadTree:InsertArray(NodePoints)
	-- QuadTreeMaidInstance:Give(unpack(RenderNodeQuadTree:Show(10)))

	local UpdateMaid = ReplicatedModules.Classes.Maid.New()
	local ActivePoints = {}

	local _t = time()
	QuadTreeMaidInstance:Give(RunService.Heartbeat:Connect(function()
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
			-- UpdateMaid:Give( unpack(VisibleBoundaryRectangle:Show( 10 )) )
			CharacterPoints = RenderNodeQuadTree:Query(VisibleBoundaryRectangle)
			-- Load any points that are now visible
			for _, point in ipairs( CharacterPoints ) do
				-- set visible
				for RenderInstance, VisibleParent in pairs( point._data.RenderInstances ) do
					RenderInstance.Parent = VisibleParent
				end
				-- stop duplicate references
				if not table.find(NewPointsArray, point) then
					table.insert(NewPointsArray, point)
				end
			end
		end

		VisibleBoundaryRectangle.x = CurrentCamera.CFrame.X
		VisibleBoundaryRectangle.y = CurrentCamera.CFrame.Z
		-- UpdateMaid:Give( unpack(VisibleBoundaryRectangle:Show( 10 )) )
		-- Load any points that are now visible
		local CameraPoints = RenderNodeQuadTree:Query(VisibleBoundaryRectangle)
		for _, point in ipairs( CameraPoints ) do
			-- set visible
			for RenderInstance, VisibleParent in pairs( point._data.RenderInstances ) do
				RenderInstance.Parent = VisibleParent
			end
			-- stop duplicate references
			if not table.find(NewPointsArray, point) then
				table.insert(NewPointsArray, point)
			end
		end

		-- Unload any points that are no longer visible
		for _, activePoint in ipairs( ActivePoints ) do
			-- if still active, skip
			if table.find( NewPointsArray, activePoint ) then
				continue
			end
			-- no longer active
			for RenderInstance, _ in pairs( activePoint._data.RenderInstances ) do
				RenderInstance.Parent = RenderCacheFolder
			end
		end

		ActivePoints = NewPointsArray
	end))

	QuadTreeMaidInstance:Give(function()
		RenderNodeQuadTree = false
		VisibleBoundaryRectangle = false
		ActivePoints = {}
		for _, point in ipairs( NodePoints ) do
			for RenderInstance, VisibleParent in pairs( point._data.RenderInstances ) do
				RenderInstance.Parent = VisibleParent
			end
			task.wait(0.025) -- slight delay to prevent crash
		end
	end)
end

function Module:DisableQuadTreeRenderer()
	QuadTreeMaidInstance:Cleanup()
end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems

	task.defer(function()
		Module:EnableQuadTreeRenderer() -- run the renderer
		-- Module:DisableQuadTreeRenderer()
	end)
end

return Module


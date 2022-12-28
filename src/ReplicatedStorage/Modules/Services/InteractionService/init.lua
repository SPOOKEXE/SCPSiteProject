local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService')

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local MaidClassModule = require(script.Parent.Parent.Classes.Maid)

local RemoteService = require(script.Parent.RemoteService)
local InteractionEvent = RemoteService:GetRemote('InteractionEvent', 'RemoteEvent', false)
local InteractionFunction = RemoteService:GetRemote('InteractionFunction', 'RemoteFunction', false)

local DefaultInteractionConfig = { HoldDuration = 0.5, MaxInteractDistance = 12 }

local ActiveInteractionClasses = {}

local InteractionClassModule = require(script.Interaction)
InteractionClassModule.ParentTable = ActiveInteractionClasses

local function FlashPropertyValue(TargetInstance, propertyName, newValue, duration)
	local TI = TweenInfo.new( 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut )

	local OldProperty = TargetInstance[propertyName]
	if typeof(OldProperty) == 'ColorSequence' then
		local ColVal = Instance.new('Color3Value')
		ColVal.Value = OldProperty.Keypoints[#OldProperty.Keypoints].Value
		ColVal.Changed:Connect(function(value)
			TargetInstance[propertyName] = ColorSequence.new(value)
		end)

		local T = TweenService:Create( ColVal, TI, { Value = newValue } )
		T.Completed:Connect(function()
			task.wait(0.5)
			TweenService:Create( ColVal, TI, { Value = OldProperty.Keypoints[#OldProperty.Keypoints].Value } ):Play()
		end)
		T:Play()
	else
		local T = TweenService:Create( TargetInstance, TI, { [propertyName] = newValue } )
		T.Completed:Connect(function()
			task.wait(0.5)
			TweenService:Create( TargetInstance, TI, { [propertyName] = OldProperty } ):Play()
		end)
		T:Play()
	end

	-- if typeof(OldProperty) == 'ColorSequence' and typeof(newValue) == 'Color3' then
	-- 	newValue = ColorSequence.new(newValue)
	-- end
	-- TargetInstance[propertyName] = newValue
	-- task.delay(duration, function()
	-- 	TargetInstance[propertyName] = OldProperty
	-- end)
end

-- // Module // --
local Module = {}

function Module:GetInteractionClass( TargetInstance, doCreateIfMissing, canUseInteractableCallback )
	if not ActiveInteractionClasses[TargetInstance] and doCreateIfMissing then
		local Base = InteractionClassModule.New(TargetInstance)
		ActiveInteractionClasses[TargetInstance] = Base
		if RunService:IsServer() then
			InteractionEvent:FireAllClients('SetupInteraction', TargetInstance)
		end
	end
	return ActiveInteractionClasses[TargetInstance]
end

function Module:OnInteracted( TargetInstance, Callback, WhitelistCallback )
	local class = Module:GetInteractionClass( TargetInstance, true, WhitelistCallback)
	class:OnInteracted(Callback)
	return class
end

function Module:RemoveInteraction( TargetInstance )
	local class = Module:GetInteractionClass( TargetInstance )
	if class then
		class:Destroy()
	end

	if RunService:IsServer() then
		InteractionEvent:FireAllClients('RemoveInteraction', TargetInstance)
	end
end

if RunService:IsServer() then

	InteractionFunction.OnServerInvoke = function(LocalPlayer, InteractInstance, Args)
		--print(LocalPlayer.Name, InteractInstance:GetFullName(), Args)

		local InteractableClass = Module:GetInteractionClass( InteractInstance, false )
		if not InteractableClass then
			--print('not available')
			return 1, 'This is not an available interactable.'
		end

		if (not InteractableClass._CanUseInteractable) then
			--print('free to use')
			return true
		end

		local CanUse, Err = InteractableClass._CanUseInteractable(LocalPlayer)
		if not CanUse then
			--print('cannot use interactable')
			return 2, Err or 'Cannot use this interactable.'
		end

		--print('interacted - server')
		InteractableClass._OnInteracted:Fire(LocalPlayer, Args)
		return 3, 'Successfully used interactable.'
	end

else
	local ContextActionService = game:GetService('ContextActionService')

	local LocalPlayer = game:GetService('Players').LocalPlayer
	local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')

	local CurrentCamera = workspace.CurrentCamera
	local Terrain = workspace.Terrain

	local HighlightInstance = LocalAssets.UI.Interaction.Highlight:Clone()
	local LineBeamInstance = LocalAssets.UI.Interaction.LineBeam:Clone()
	local BillboardInstance = LocalAssets.UI.Interaction.InteractUI:Clone()
	local InteractionAttachment0 = Instance.new('Attachment')
	InteractionAttachment0.Name = 'InteractionAttachment0'
	InteractionAttachment0.Visible = true
	InteractionAttachment0.Parent = Terrain
	local InteractionAttachment1 = Instance.new('Attachment')
	InteractionAttachment1.Name = 'InteractionAttachment1'
	InteractionAttachment1.Visible = true
	InteractionAttachment1.Parent = Terrain

	BillboardInstance.Frame.Bar.Size = UDim2.fromScale(0, 0.1)
	BillboardInstance.Parent = InteractionAttachment1
	LineBeamInstance.Attachment0 = InteractionAttachment0
	LineBeamInstance.Attachment1 = InteractionAttachment1
	LineBeamInstance.Parent = Terrain

	function Module:GetClosestInteraction(fromCamera)
		local Origin = fromCamera and CurrentCamera.CFrame.Position or (LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or CurrentCamera.CFrame.Position)
		local Closest, Dist = false, false
		for _, Class in pairs( ActiveInteractionClasses ) do
			local nDist = Class:DistanceFrom( Origin )
			if (nDist < DefaultInteractionConfig.MaxInteractDistance) and ((not Dist) or (nDist < Dist)) then
				Closest = Class
				Dist = nDist
			end
		end
		return Closest, Dist
	end

	function Module:InteractionVisual( InteractionClass )
		local CharacterCFrame = LocalPlayer.Character and LocalPlayer.Character:GetPivot()
		if CharacterCFrame and InteractionClass then
			-- move beam
			InteractionAttachment0.WorldPosition = CharacterCFrame.Position
			InteractionAttachment1.WorldPosition = InteractionClass.Interactable.Position
			LineBeamInstance.Enabled = true
			BillboardInstance.Enabled = true
		else
			-- disable beam
			LineBeamInstance.Enabled = false
			BillboardInstance.Enabled = false
		end
		HighlightInstance.Parent = InteractionClass and InteractionClass.Interactable or script
	end

	function Module:FlashColor(TargetColor)
		FlashPropertyValue(LineBeamInstance, 'Color', TargetColor, 2)
		FlashPropertyValue(HighlightInstance, 'FillColor', TargetColor, 2)
		FlashPropertyValue(BillboardInstance.Frame, 'BackgroundColor3', TargetColor, 2)
		FlashPropertyValue(BillboardInstance.Frame.Label, 'TextColor3', TargetColor, 2)
		FlashPropertyValue(BillboardInstance.Frame.UIStroke, 'Color', TargetColor, 2)
	end

	function Module:FlashText(Text)
		BillboardInstance.Frame.Label.Text = Text
		task.delay(1, function()
			BillboardInstance.Frame.Label.Text = 'E to Interact'
		end)
	end

	local LastInteractionClass = false
	local Holding = false

	ContextActionService:BindAction('InteractionChanged', function(actionName, inputState, inputObject)
		if actionName == 'InteractionChanged' then
			if inputState == Enum.UserInputState.Begin then
				local ClosestInteraction, Dist = Module:GetClosestInteraction(false)
				if not ClosestInteraction then
					return
				end
				LastInteractionClass = ClosestInteraction

				ClosestInteraction._OnHoldStart:Fire()
				Holding = true

				local Result, Data = InteractionFunction:InvokeServer(ClosestInteraction.Interactable, ClosestInteraction._Args)
				-- print(Result, Data)
				if Result == 2 then
					Module:FlashColor( Color3.new(1,0,0) )
					Module:FlashText(Data or 'Cannot use this interactable.')
					return -- cannot interact with it at all
				elseif Result == 1 then
					--warn('client-based interactable')
					if ClosestInteraction._CanUseInteractable then
						local CanUse, Err = ClosestInteraction._CanUseInteractable(LocalPlayer)
						if not CanUse then
							Module:FlashText(Err or 'Cannot use this interactable.')
							Module:FlashColor( Color3.new(1,0,0) )
							return
						end
					end
				end

				local _t = time()
				while Holding and (time() - _t < DefaultInteractionConfig.HoldDuration) do
					BillboardInstance.Frame.Bar.Size = UDim2.fromScale((time() - _t) / DefaultInteractionConfig.HoldDuration, 0.1)
					task.wait()
				end
				BillboardInstance.Frame.Bar.Size = UDim2.fromScale(1, 0.1)

				if Holding then
					ClosestInteraction._OnInteracted:Fire( ClosestInteraction._Args )
					Module:FlashColor( Color3.fromRGB(19, 193, 62) )
					Module:FlashText(Result==3 and Data or 'Successfully used interaction.')
					BillboardInstance.Frame.Bar.Size = UDim2.fromScale(0, 0.1)
				end
			else
				if LastInteractionClass then
					LastInteractionClass._OnHoldRelease:Fire()
					task.spawn(function()
						InteractionFunction:InvokeServer(LastInteractionClass.Interactable, true)
					end)
					LastInteractionClass = nil
				end
				Holding = false
			end
		end
	end, false, Enum.KeyCode.E)

	InteractionEvent.OnClientEvent:Connect(function(Job, ...)
		local Args = {...}
		if Job == 'RemoveInteraction' then
			Module:RemoveInteraction(unpack(Args))
		elseif Job == 'SetupInteraction' then
			Module:GetInteractionClass(unpack(Args), true)
		end
	end)

	RunService.Heartbeat:Connect(function()
		local Closest, Dist = Module:GetClosestInteraction(false)
		-- print(Closest ~= nil, Dist)
		Module:InteractionVisual( Closest )
	end)
end

return Module
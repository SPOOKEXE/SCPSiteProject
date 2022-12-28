
local Module = {}

function Module:WeldConstraint(Part0, Part1)
	local WeldConstraint = Instance.new('WeldConstraint')
	WeldConstraint.Part0 = Part0
	WeldConstraint.Part1 = Part1
	WeldConstraint.Parent = Part0
	return WeldConstraint
end

function Module:WeldModelToPrimaryPart(Model, doDescendants)
	if not Model.PrimaryPart then
		warn('Cannot weld parts to primary part when there is no primary part set. '..Model:GetFullName())
		return
	end
	for _, Descendant in ipairs( doDescendants and Model:GetDescendants() or Model:GetChildren() ) do
		if Descendant:IsA('BasePart') and Descendant ~= Model.PrimaryPart then
			Module:WeldConstraint(Descendant, Model.PrimaryPart)
		end
	end
end

return Module


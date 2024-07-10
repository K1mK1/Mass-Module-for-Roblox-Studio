local function getPartVolume(part)
	if part:IsA("Part") then
		local size = part.Size
		local volume = size.X * size.Y * size.Z
		return volume
	elseif part:IsA("BasePart") then
		local partProperties = part.CustomPhysicalProperties or PhysicalProperties.new(part.Material)
		local _, b, c, d, e = partProperties.Density, partProperties.Friction, partProperties.Elasticity, partProperties.FrictionWeight, partProperties.ElasticityWeight
		
		part.CustomPhysicalProperties = PhysicalProperties.new(1, b, c, d, e)
		
		return part.Mass
	end
	
	return 0
end

local function setPartMass(part,mass)
	local partProperties = part.CustomPhysicalProperties or PhysicalProperties.new(part.Material)
	local _, b, c, d, e = partProperties.Density, partProperties.Friction, partProperties.Elasticity, partProperties.FrictionWeight, partProperties.ElasticityWeight

	local newDensity = mass / getPartVolume(part,mass)

	part.CustomPhysicalProperties = PhysicalProperties.new(newDensity, b, c, d, e)
	
	if newDensity > 100 then
		return (mass-part.Mass)
	end
	
	return 0
end

local function numberOfParts(model :Model)
	local Count = 0

	for _,part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			Count += 1
		end
	end

	return Count
end

local function CreateAndSetMass(sentPart,mass)
	local createdWeld = Instance.new("Weld")
	createdWeld.Parent = sentPart
	
	local NewPart = Instance.new("Part")
	NewPart.Size = Vector3.new(1,1,1)
	NewPart.CanCollide = false
	NewPart.Transparency = 1
	NewPart.CanTouch = false
	
	NewPart.Parent = sentPart
	NewPart.CFrame = sentPart.CFrame
	
	createdWeld.Part0 = sentPart
	createdWeld.Part1 = NewPart
	
	setPartMass(NewPart,mass)
end

local Mass = {}

Mass["GetMass"] = function(model)
	local mass = 0;
	for _,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			mass += v.AssemblyMass;
		end
	end
	return mass;
end

Mass["SetMass"]  = function(object,sentMass)
	
	local ExtraMass = 0
	local LastPart
	
	if object:IsA("Model") then
		local PartCount = numberOfParts(object)
		if PartCount < 1 then return end
		
		local SetMass = sentMass/PartCount

		for _,part in pairs(object:GetDescendants()) do
			if part:IsA("BasePart") then
				local AnyExtra = setPartMass(part,SetMass)
				ExtraMass += AnyExtra
				LastPart = part
			end
		end
		
		if ExtraMass > 0 and LastPart then
			print(ExtraMass)
			CreateAndSetMass(LastPart,ExtraMass)
		end
		
	elseif object:IsA("BasePart") then
		setPartMass(object,sentMass)
	end

	return
end

return Mass

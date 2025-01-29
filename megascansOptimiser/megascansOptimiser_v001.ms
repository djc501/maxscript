try(DestroyDialog _optMega)catch()
rollout _optMega "Optimise Meagascans"
(
	spinner _spnDisplace "Displacement Amount:" type:#float range:[0,100,2]
-- 	spinner _spnDispShift "Displacement Shift:"
	button _btnOptimise "OPTIMISE"
	
	fn dataMap map =
	(
		map.filterMult = 0.01
		map.color_space = 0
		map.rgbColorSpace = 3
	)
	
	on _spnDisplace changed state do
	(
		arr = selection as Array
		
		for a in arr do
		(	
			if a.modifiers[#VRayDisplacementMod] != undefined do
			(
				a.modifiers[#VRayDisplacementMod].amount = _spnDisplace.value
				a.modifiers[#VRayDisplacementMod].shift = -(_spnDisplace.value/2)
			)
		)
	)
	
	on _btnOptimise pressed do
	(
		arr = selection as Array

		for a in arr do
		(
			-- normal map
			normMap = a.material.texmap_bump.normal_map
			dataMap normMap
			a.material.texmap_bump_multiplier = 100
			a.material.texmap_bump.flip_green = on
			-- gloss/rough map
			glossMap = a.material.texmap_reflectionGlossiness
			dataMap glossMap
			-- displacemap
			if a.modifiers[#VRayDisplacementMod] != undefined do
			(
				dispMap = a.modifiers[#VRayDisplacementMod].texmap
				dataMap dispMap
				a.material.texmap_displacement = dispMap
				a.material.texmap_displacement_on = off
				-- displace modifier
				dispMod = a.modifiers[#VRayDisplacementMod]
				dispMod.type = 2
				dispMod.shift = -(dispMod.amount/2)
				dispMod.texmap_min = -1.0
			)
			-- overall material
			a.material.Reflection = color 255 255 255
			a.material.brdf_useRoughness = on
			-- diffuse map
			diffMap = a.material.texmap_diffuse
			if classof diffMap == VRayBitmap do
			(
				diffMap.color_space = 2
				diffMap.rgbColorSpace = 0
			)
			if classof diffMap == VRayCompTex do
			(
				diffMap.sourceA.color_space = 2
				diffMap.sourceA.rgbColorSpace = 0
				dataMap diffMap.sourceB
			)
		)
	)
)
CreateDialog _optMega

/*
anima drop material
incemental export
static or anim
*/

-- export selected or all
actorArr = #()
namesArr = #()
global count = 0
global exportFolder = ""
global carryOn
global mainPath

try(DestroyDialog _animaSceneConverter)catch()
rollout _animaSceneConverter "Anima Converter"
(
	group "EXPORT"
	(
	edittext txtExport "TO:" pos:[5,25] width:250 text:((GetDir #export) + "\\anima")
	button btnBrowse "..." pos:[265,23]
	checkbox _chkVray "Vray Proxy" checked:true across:2
	checkbox _chkCor "Corona Proxy" checked:false
	checkbox _chkStatic "Static" checked:true across:2
	checkbox _chkAnim "Animated" checked:false
	)
	group "STATIC"
	(
	checkbox _chkStat_UseFrame "Use Frame:" checked:true across:2
	spinner _chkStatFrame type:#integer
	checkbox _chkStat_Interval "Create Incremental" tooltip:"Create incremental static proxy files" across:2
	spinner _spnStatIncrement "Increment:" enabled:false type:#integer
	)
	group "ANIMATED"
	(
	checkbox _chkAnim_Full "Use Full Timeline" checked:true enabled:false
	checkbox _chkAnim_Range "Animation Range" checked:false enabled:false
	spinner _spnAnimStart "Start:" across:2 type:#integer enabled:false range:[0,1000,0]
	spinner _spnAnimEnd "End:" type:#integer enabled:false range:[0,1000,1000]
	)
	button _convert "CONVERT SCENE!"
	label _status ""
	label _details ""
	progressBar _progress
	
	on _animaSceneConverter open do
	(
		global fstart = animationrange.start
		global fend = animationrange.end
		_spnAnimStart.value = fstart
		_spnAnimEnd.value = fend
		global rangeType = #scene
	)
	
	-- FUNCTIONS
	fn _fnVrayProxy _objName _meshName _rangeType _fstart _fend =
	(
		global newProxy = vrayMeshExport proxyName:_objName meshFile:_meshName autoCreateProxies:true animation:on animationRange:_rangeType animationStart:_fstart animationEnd:_fend animationRedrawViews:true name:_objName
		newProxy = $
		newProxy.name = _objName
		newProxy.display = 4
	)
	
	fn _fnCorProxy _mesh _filename _fstart _fend _objName =
	(
		global newProxy = CProxy name:_objName
		newProxy.animationOffset = _fstart
		newProxy.pointcloudDensity = 9.0
		newProxy.previzType = 3
		CProxy.ProxyFp.fromSceneAnimated (newProxy) (_mesh) (_filename) _fstart _fend 10000 1
		newProxy = getNodeByName _objName
	)
	
	fn getUniqueString baseString existingArray =
	(
		local uniqueString = baseString
		local check = filterstring baseString "_"
		if check.count > 1 then(
		uniqueString = check[1] + "_" + check[2]
		version = check[2] as integer
		)
		else (version = 0)

		while findItem existingArray uniqueString != 0 do
		(
			version += 1
			uniqueString = check[1] + "_" + (version as string)
		)

		append existingArray uniqueString
		return uniqueString
	)
	
	fn _fnGetMapName mat =
	(
		if classof mat == VRayMtl do
		(
			mainPath = trimRight mat.texmap_diffuse.HDRIMapName "Preview.jpg"	-- vray bitmap
		)
		if classof mat == CoronaLegacyMtl do
		(
			mainPath = trimRight mat.texmapDiffuse.filename "Preview.jpg"	-- corona bitmap
		)
		if classof mat == CoronaPhysicalMtl do
		(
			mainPath = trimRight mat.baseTexmap.filename "Preview.jpg"	-- corona bitmap
		)
		
		return mainPath
	)
	
	fn _fnConvertActors _actorArr =
	(
		for actor in _actorArr do
		(
			count += 1
			_details.text = actor[3]
			objName = actor[3]
			objName = getUniqueString objName namesArr
			-- UPDATE TEXTURES
			_status.text = "Making textures visible in viewport on actor:"
			if actor[1] == "4D" do	-- if actor is a newer 4D one update materials to use textures
			(
				print ("4D actor found: " + objName)
				_details.text = objName
				actor[2].material.showinviewport  = true
				_fnGetMapName actor[2].material
				newPath = mainPath + "00000_00000.jpg"
				actor[2].material.texmap_diffuse.HDRIMapName = newPath
			)
			if actor[1] == "ambient" do																	-- if actor is a non 4d one
			(
				print ("ambient actor found: " + objName)
				_details.text = objName
				if classof actor[2].material == Multimaterial then
				(
					for k=1 to actor[2].material.numsubs do
					(
						actor[2].material[k].showinviewport  = true
					)
				)
				else (actor[2].material.showinviewport  = true)
			)
			-- Create dummies
			_status.text = "Creating dummy for actor:"	
			DEST_OBJ = Dummy name:(objName + "_dummy")
			_details.text = objName
			slidertime = fstart
			_status.text = "Copying transfom data to dummies for actor:"
			-- Copy actor transforms to dummies
			for f = fstart to fend do
			(
				animate on
				_details.text = objName
				DEST_OBJ = getNodeByName (objName + "_dummy")
				DEST_OBJ.transform = actor[2].transform
				slidertime += 1
			)
			-- create animated proxies
			select actor[2]
			IsolateSelection.EnterIsolateSelectionMode()
			actorFolder = exportFolder + "\\" + objName
			texFolder =  actorFolder + "\\textures\\"
			proxyFolder = actorFolder + "\\proxy\\"
			if (doesDirectoryExist texFolder) == false then (makeDir texFolder)
			if (doesDirectoryExist proxyFolder) == false then (makeDir proxyFolder)
			if actor[1] == "4D" do		-- if actor is a newer 4D one create IFL file and repoint
			(
				select actor[2]
				print ("Creating ifl file for 4D actor: " + objName)
				_status.text = "Creating ifl file for 4D actor:"
				_details.text = objName
				-- Create IFL file for textures
				iflFiles = #()
				jpgfiles = #()
					
				slidertime = fstart
				for f = fstart to fend do
				(
					(
						tex =  actor[2].material.texmap_diffuse.HDRIMapName
						SRC_name = actor[2].name
						texNam = filenameFromPath tex
						newTex = texFolder + texNam
						append jpgfiles newTex
						copyFile tex newTex
					)
					sliderTime += 1
				)
				
				iflName = texFolder + objName + ".ifl"
				append iflFiles iflName
				iflFile = createfile iflName

				for i = 1 to jpgFiles.count do
				(
					format "%\n" (jpgFiles[i]) to:iflFile
				)
				
				close iflFile
				
				newMap = Bitmaptexture fileName:iflName
				
				replaceinstances (actor[2].material.texmap_diffuse) newMap	-- repoint diffuse map to IFL
				actor[2].material.texmap_diffuse.reload()
				select actor[2]
				_status.text = "Exporting Vray Proxy for actor:"
				_details.text = objName
				if _chkVray.checked do
				(
					print ("Creating vray proxy for actor: " + objName)
					meshName = proxyFolder + objName + ".vrmesh"
					_fnVrayProxy objName meshName rangeType fstart fend
				)
				if _chkCor.checked do
				(
					print ("Creating corona proxy for actor: " + objName)
					meshName = proxyFolder + objName + ".cgeo"
					_fnCorProxy $ meshName fstart fend objName
				)
				DEST_OBJ = getNodeByName (objName + "_dummy")
				slidertime = fstart
				for f = fstart to fend do
				(
					animate on
					newProxy.transform = DEST_OBJ.transform
					slidertime += 1
				)
				delete DEST_OBJ
			)
			if actor[1] == "ambient" do			-- if actor isn't a 4D one
			(
				_status.text = "Recording transform info for actor:"
				_details.text = objName
				select actor[2]
				meshName = proxyFolder + objName
				_status.text = "Exporting Vray Proxy for actor:"
				_details.text = objName
				if _chkVray.checked do
				(
					print ("Creating vray proxy for actor: " + objName)
					meshName = proxyFolder + objName + ".vrmesh"
					_fnVrayProxy objName meshName rangeType fstart fend
				)
				if _chkCor.checked do
				(
					print ("Creating corona proxy for actor: " + objName)
					meshName = proxyFolder + objName + ".cgeo"
					newProxy = _fnCorProxy $ meshName fstart fend objName
				)
				DEST_OBJ = getNodeByName (objName + "_dummy")
				slidertime = fstart
				for f = fstart to fend do
				(
					animate on
					newProxy.transform = DEST_OBJ.transform
					slidertime += 1
				)
				delete DEST_OBJ
			)
			IsolateSelection.ExitIsolateSelectionMode()
			_progress.value = 100.*count/_actorArr.count
		)
	)
	
	fn fnConfigAnimaProj obj =
	(
		_status.text = "Configuring anima scene ready for conversion."

		global exportFolder = txtExport.text

		timeDisplayMode = #frames
		sliderTime = fstart
		
		-- Configure anima project for conversion
		obj.maxmeshmodels = 999				
		obj.updatemode4d = 1
		obj.defaultTexMode = 1
		obj.showAllActors = true
		max select none
		if obj.actornodes.count > 0 then	-- if anima project has at least 1 actor node, then it's an imported anima scene
		(
			for a in obj.actornodes do
			(
				a.asArrow = off
				actorNameArr = FilterString a.name "_"
				if (MatchPattern actorNameArr[2] pattern:"*4d" ignoreCase:true) then (type = "4D")	-- if actor is a newer 4D one update materials to use textures
				else (type = "ambient")
				arr = #(type, a, actorNameArr[2])
				append actorArr arr
			)
		)
		else		-- otherwise it's an anima drop scene
		(
			if _chkCor.checked do		-- check for Corona proxy as they don't work with anima drop actors
			(
				msg = queryBox "Corona Proxy isn't compatible with Anima Drop Actors, use Vray proxy instead?"
				if msg == true then
				(
					carryOn = true
					_chkCor.checked = false
					_chkVray.checked = true
				)
				else
				(
					carryOn = false
					return messagebox "Conversion aborted."
				)
			)
			if _chkVray.checked do carryOn = true
			if carryOn == true do
			(
				for obj in geometry do
				(
					if classof obj == animaDropActor do
					(
						if obj.assettype == 4 do (type = "4D")						-- 4d actor
						if obj.assettype == 2 or 3 do (type = "ambient")			-- ready posed or ambient
						actorNameArr = filterstring obj.name "_"
						arr = #(type,obj,actorNameArr[1])
						append actorArr arr
					)
				)
			)
-- 			if carryOn = false do 	-- force exit if say no to continuing
		)
		
		_fnConvertActors actorArr
		
		max select none
		select obj
		selectmore obj.children
		delete $
		slidertime = fstart
		_status.text = ""
		_details.text = ""
		_progress.value = 0
		messagebox "Scene converted successfully."
	)
	
	on _chkVray changed state do _chkCor.checked = not state
		
	on _chkCor changed state do _chkVray.checked = not state
		
	on _chkStat_UseFrame changed state do
	(
		_chkStatFrame.enabled = state
		_chkStat_Interval.checked = not state
		_spnStatIncrement.enabled = not state
	)
		
	on _chkStat_Interval changed state do
	(
		_spnStatIncrement.enabled = state
		_chkStat_UseFrame.checked = not state
		_chkStatFrame.enabled = not state
	)
	
	on _chkStatic changed state do
	(
		for c in _animaSceneConverter.controls do
		(
			if MatchPattern (c as string) pattern:"*anim_*" do c.enabled = not state
			if MatchPattern (c as string) pattern:"*stat_*" do c.enabled = state
		)
		_chkAnim.checked = not state
		if _chkAnim_Range.checked == true do
		(
			_spnAnimStart.enabled = not state
			_spnAnimEnd.enabled = not state
		)
	)
		
	on _chkAnim changed state do
	(
		for c in _animaSceneConverter.controls do
		(
			if MatchPattern (c as string) pattern:"*stat_*" do c.enabled = not state
			if MatchPattern (c as string) pattern:"*anim_*" do c.enabled = state
		)
		_chkStatic.checked = not state
		if _chkStat_UseFrame.checked == true do	_chkStatFrame.enabled = not state
		if _chkStat_Interval.checked == true do	_spnStatIncrement.enabled = not state
		if _chkAnim_Range.checked == true then
		(
			_spnAnimStart.enabled = state
			_spnAnimEnd.enabled = state
		)
	)
	
	on _chkAnim_Range changed state do
	(
		_chkAnim_Full.checked = not state
		_spnAnimStart.enabled = state
		_spnAnimEnd.enabled = state
		
	)
	
	on _chkAnim_Full changed state do
	(
		_chkAnim_Range.checked = not state
		if _chkAnim_Range.checked == true do
		(
			_spnAnimStart.enabled = state
			_spnAnimEnd.enabled = state
		)
	)

	on btnBrowse pressed do
	(
		thePath = getSavepath initialDir:(txtExport.text)
		if thePath != undefined then (txtExport.text = thePath)
		else ()
	)
	
	on _convert pressed do
	(
		if _chkAnim_Range.checked then		-- if range checked use spinner values as frame range for animation
		(
			fstart = _spnAnimStart.value
			fend = _spnAnimEnd.value
			rangeType = #explicit
		)
		else()
		for obj in helpers do
		(
			if (classof obj == animaProject) do
			(
				_progress.value = 0
				fnConfigAnimaProj obj
			)
		)

		if (actorArr.count == 0) do
		(
			print carryOn
			if carryOn != false do messageBox "No anima actors found, please import\\drop in\nsome Anima actors first before running converter!"
		)
		gc()
	)
)
CreateDialog _animaSceneConverter width:300
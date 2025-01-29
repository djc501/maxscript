/*
BATCH IMPORTER
version 1.0.0 2023.10.18
Cherry Picker Visuals
*/
(
	global _batchImporter
	try(if _batchImporter.dialogBar then (cui.UnRegisterDialogBar _batchImporter)
		else (DestroyDialog _batchImporter)) catch()
	---------- PRE FLIGHT ----------
	--------------------------------
	scriptPath = pathConfig.removePathLeaf (getSourceFileName())
	filterArr = #("All Suppported Formats","DWG","FBX","OBJ","RVT","SKP")
	strUnits = units.decodeValue "1\""
	searchFolder = GetDir #scene
	fileTypes = #()
	fbxControls =#()
	objControls = #()
	---------- DWG ----------
	dwg_ini_import = GetDir #plugcfg + @"\dwg_dxf_import.ini"
	newDWG = scriptPath + "\\dwg_dxf_import.ini"
	theDWGKeys = getIniSetting dwg_ini_import "General"
	autoPrims = #("Layer, Blocks as Node Hierarchy","Layer, Blocks as Node Hierarchy, Split by Material","Entity, Blocks as Node Hierarchy", "Layer","Color","Color and Material","Entity","One Object")
	dwgUnits = #("Inches","Feet","Miles","Millimeters","Centimeters","Meters","Kilometers","Microinches","Mils","Yards","Angstroms","Nanometers","Microns","Decimeters","Decameters","Hectometers","Gigameters","Astronomical Units","Light Years","Parsecs")
	texMap = #("Generate coordinates for all objects","No mapping coordinates")
	splRender = #("Radial","Rectangular")
	---------- FBX ----------
	fbxPreset = #("Autodesk Architectural (Revit)","Autodesk Media & Entertainment")
	fbxUnits = #("mm","cm","dm","m","km","in","ft","yd")
	fbxMode = #("Add","Add and update animation","Update animation")
	boneConv = #("Leave as Bones","Convert as Dummy")
	---------- SKP ----------
	skpUpAxis = #("X-Up","Y-Up","Z-Up")
	skpUpAxisSet = #(#x,#y,#z)
	skpHier = #("Use Groups","Use Layers","Flattened")
	skpHierSet = #(#UsingGrouping,#UsingLayer,#Flattened)
	---------- RVT ----------
	rvtCombo = #("Do Not Combine Objects","Combine By Revit Category","Combine By Revit Family Type","Combine By Revit Material","Combine By Revit Category and Revit Material","Combine By Revit Family Type and Revit Material","Combine as One Object")
	rvtLevel = #("Default","Coarse","Medium","Fine")
	---------- OBJ ----------
	objUnits = #("Inches","Feet","Miles","Millimeters","Centimeters","Meters","Kilometers")
	objNormals = #("Import from file","From SM Group","Auto Smooth","Faceted")
	objMats = #("<No Materials>","Physical Material","Standard (Legacy)")
	obj_preset = objImp.getPresetIniName()
	objPresets = getINISetting obj_preset "ImportPresets" "PresetNames"
	objPresets = FilterString objPresets ","
	insertItem "<NONE>" objPresets 1
	obj_ini_import = objimp.getIniName()
	newOBJ = scriptPath + "\\gw_objimp.ini"
	theOBJKeys = getIniSetting obj_ini_import "General"

	---------- FUNCTIONS ----------
	-------------------------------
	fn _fnBooleanConvert var =
	(
		if var == "0" do result = false
		if var == "1" do result = true
		return result
	)

	fn getFilesRecursive root pattern =
	(
		dir_array = GetDirectories (root+"/*")
		for d in dir_array do
		  join dir_array (GetDirectories (d+"/*"))
		insertItem root dir_array 1
		my_files = #()
		for f in dir_array do
		  join my_files (getFiles (f + "\*." + pattern))
		my_files
	)

	fn _fnGetFiles &pattern =
	(
		my_files = getFiles (_folder.text + "\*." + pattern)
		my_files
	)
	

	---------- ROLLOUTS ----------
	------------------------------

	rollout _batchImporter "Batch Importer v1.0 by CPV"
	(
		checkbutton chkShowMain "Main" checked:on across:7 highlightColor:[68,68,68] width:51
		checkbutton chkShowClean "Clean" checked:off highlightColor:[68,68,68] width:51
		checkbutton chkShowDWG "DWG" checked:off highlightColor:[68,68,68] width:51
		checkbutton chkShowFBX "FBX" checked:off highlightColor:[68,68,68] width:51
		checkbutton chkShowOBJ "OBJ" checked:off highlightColor:[68,68,68] width:51
		checkbutton chkShowRVT "Revit" checked:off highlightColor:[68,68,68] width:51
		checkbutton chkShowSKP "Sketchup" checked:off highlightColor:[68,68,68] width:51
		
		subRollout roSubMain "" width:340 height:535 pos:[10,30]
		subRollout roSubClean "" width:340 height:650 visible:false pos:[10,30]
		subRollout roSubDWG "" width:340 height:750 visible:false pos:[10,30]
		subRollout roSubFBX "" width:340 height:665 visible:false pos:[10,30]
		subRollout roSubOBJ "" width:340 height:660 visible:false pos:[10,30]
		subRollout roSubRVT "" width:340 height:650 visible:false pos:[10,30]
		subRollout roSubSKP "" width:340 height:650 visible:false pos:[10,30]
		
		fn _fnTabs pattern =
		(
			arr = _batchImporter.controls
			for a in arr do
			(
				if classof a == SubRollout do
				(
					if (MatchPattern a.name pattern:("*" + pattern) ignorecase:true) then (a.visible = true)
					else (a.visible = false)
				)
				if classof a == CheckButtonControl do
				(
					if (MatchPattern a.name pattern:("*" + pattern) ignorecase:true) then (a.checked = true)
					else (a.checked = false)
				)
			)
		)
		
		on chkShowMain changed state do
		(
			_fnTabs "Main"
			_batchImporter.height = 550
		)
		on chkShowClean changed state do
		(
			_fnTabs "Clean"
			_batchImporter.height = 450
		)
		on chkShowDWG changed state do
		(
			_fnTabs "DWG"
			_batchImporter.height = 765
		)
		on chkShowFBX changed state do
		(
			_fnTabs "FBX"
			_batchImporter.height = 690
		)
		on chkShowOBJ changed state do
		(
			_fnTabs "OBJ"
			_batchImporter.height = 695
		)
		on chkShowRVT changed state do
		(
			_fnTabs "RVT"
			_batchImporter.height = 480
		)
		on chkShowSKP changed state do
		(
			_fnTabs "SKP"
			_batchImporter.height = 285
		)
		on _batchImporter open do
		(
			if (theDWGKeys.count == 0) do (deleteFile dwg_ini_import	-- see if DWG import contains any variables, and update if not
				copyFile newDWG dwg_ini_import)
			if (theOBJKeys.count == 0) do (deleteFile obj_ini_import	-- see if obj import contains any variables, and update if not
				copyFile newOBJ obj_ini_import)
		)
		
		on _batchImporter close do
		(
			print "closing"
			if _batchImporter.dialogBar then (cui.UnRegisterDialogBar _batchImporter)
			else (DestroyDialog _batchImporter)
			globalvars.remove "_batchImporter"
			try
			(
				globalvars.remove "fileNames"
				globalvars.remove "fileTypes"
				globalvars.remove "files"
			)
			catch()
		)
	)

	rollout _clean ""
	(
		checkbox _chkClean "Clean Files During Import" checked:true
		group ""
		(
			checkbox _chkBlocks "Remove CAD Blocks" checked:true across:2
			checkbox _chkLay "Remove Empty Layers" checked:true
			checkbox _chkSplines "Remove Shapes" checked:true across:2
			checkbox _chkGroups "Remove all groups" checked:true
			checkbox _chkWeld	"Weld vertices" checked:false across:2
			edittext _txtCleanWeld "Threshold:" text:"0.001"
			checkbox _chkSmooth "Remove smoothing groups" checked:false
			checkbox _chkTracks "Remove anim layers\\note tracks" checked:true width:200		
			
		)
		
		on _txtCleanWeld entered state do
		(
			_txtCleanWeld.text = ((_txtCleanWeld.text as float) as string)
		)
		
		on _chkClean changed state do
		(
			_chkBlocks.checked = state
			_chkBlocks.enabled = state
			_chkLay.checked = state
			_chkLay.enabled = state
			_chkSplines.checked = state
			_chkSplines.enabled = state
		)
	)

	rollout _dwg ""
	(
		group "Model Scale"
		(
			dropdownlist _dropDWGUnits "Incoming Units:" items:dwgUnits selection:6
			checkbox _chkRescale "Rescale" checked:((getINISetting dwg_ini_import "LastUsedSettings" "ConvertUnits") as BooleanClass)
		)
		group "Derive AutoCAD Primitives By"
		(
			dropdownList _dropPrims items:autoPrims
			checkbox _chkExtrude "Use Extrude modifier to represent thickness" checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_ExtrudeWithModifier) as BooleanClass)
			checkbox _chkCreate "Create one scene object for each AutoCAD Architecture one" checked:(_fnBooleanConvert (getINISetting dwg_ini_import #LastUsedSettings #DWG_AdtObjectTranslation))
			checkbox _chkScnMat "Use scene material definitions" checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_ReplaceSceneMtlDefs) as BooleanClass)
		)
		group "Geometry Options"
		(
			checkbox _chkWeld "Weld neaby vertices" across:2 align:#left checked:((getINISetting dwg_ini_import #LastUsedSettings #Weld) as BooleanClass)
			spinner _spnWeld "Weld Threshold:" type:#worldunits range:[0,10000,strUnits] align:#right width:140 enabled:((getINISetting dwg_ini_import #LastUsedSettings #Weld) as BooleanClass)
			checkbox _chkSmooth "Auto-smooth adjacent faces" across:2 align:#left checked:((getINISetting dwg_ini_import #LastUsedSettings #AutoSmooth) as BooleanClass)
			spinner _spnAngle "Smooth Angle:" range:[0,360,((getINISetting dwg_ini_import #LastUsedSettings #SmoothAngle) as float)] type:#float align:#right width:140
			checkbox _chkNormals "Orient normals of addjacent faces consistently" checked:((getINISetting dwg_ini_import #LastUsedSettings #UnifyNormals) as BooleanClass)
			checkbox _chkCap "Cap closed splines" checked:((getINISetting dwg_ini_import #LastUsedSettings #CapClosedEntities) as BooleanClass)
			dropdownList _drpTex "Texture Mapping:" items:texMap
			spinner _spnCurve "Curve Steps:" range:[0,1000,((getINISetting dwg_ini_import #LastUsedSettings #ShapeSteps) as integer)] type:#integer align:#right width:85
			spinner _spnDev "Maximum surface deviation for 3D solids:" range:[0,10000,strUnits] width:140 type:#worldunits align:#right
		)
		group "Include"
		(
			checkbox _chkXref "External references (xrefs)" across:2 checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_ResolveXrefs) as BooleanClass)
			checkbox _chkLights "Lights" checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateLights) as BooleanClass)
			checkbox _chkHatch "Hatches" across:2 checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateHatches) as BooleanClass)
			checkbox _chkSS "Sun and Sky" checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateSunAndSky) as BooleanClass)
			checkbox _chkPoint "Points" across:2 checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_TranslatePoints) as BooleanClass)
			checkbox _chkView "Views and Cameras" checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateCameras) as BooleanClass)
			checkbox _chkUCS "UCSs (grids)" checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateGrids) as BooleanClass)
		)
		
		group "Splines"
		(
			checkbox _chkSpRender "Enable in Renderer" across:2 checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Renderable) as BooleanClass)
			checkbox _chkSpView "Enable in Viewport"  checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_ViewportOrRenderer) as BooleanClass)
			dropdownList _drpRenderType items:splRender selection:1 width:140 enabled:false
			spinner _spnSpThick "Thickness:" range:[0,10000,strUnits] across:3 width:120 type:#worldunits align:#left enabled:false
			spinner _spnSpSide "Sides:" range:[0,100,((getINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_ViewportSides) as integer)] type:#integer width:60 enabled:false
			spinner _spnSpAngle "Angle:" range:[0,360,((getINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_ViewportAngle) as float)] type:#float width:80 align:#right enabled:false
			spinner _spnRectLeg "Length:" range:[0,10000,((getINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Length) as float)] across:3 width:110 type:#worldunits enabled:false
			spinner _spnRectWidth "Width:" range:[0,10000,((getINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Width) as float)] width:85 type:#worldunits enabled:false
			spinner _spnRectAngle "Angle:" range:[0,10000,((getINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Angle2) as float)] width:80 type:#float enabled:false
			spinner _spnRectAspect "Aspect:" range:[0,10000,1] width:85 type:#float enabled:false across:2
			checkbox _chkLockAspect "Lock Aspect Ratio" enabled:false checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_AspectLock) as BooleanClass)
			
			checkbox _chkGenMap "Generate Mapping Coords." checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_GenUVs) as BooleanClass)
			checkbox _chkReal "Real World Map Size" checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_UsePhysicalScaleUVs) as BooleanClass)
			checkbox _chkSpAuto "Auto-smooth" across:2 align:#left checked:((getINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Autosmooth) as BooleanClass)
			spinner _spnThresh "Threshold:" range:[0,360,((getINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Threshold) as float)] type:#float align:#right width:85 enabled:true
			
		)
		on _dwg open do
		(
			_dropDWGUnits.enabled = _chkRescale.state
			_spnWeld.text = (getINISetting dwg_ini_import #LastUsedSettings #WeldThreshold)
		)
		on _chkWeld changed state do (_spnWeld.enabled = state)
		on _chkSmooth changed state do (_spnAngle.enabled = state)
		on _chkSpRender changed state do
		(
			if state == true do
			(
				_drpRenderType.enabled = true
				if (_drpRenderType.selection == 1) do
				(
					_spnSpThick.enabled = true
					_spnSpSide.enabled = true
					_spnSpAngle.enabled = true
				)
				if (_drpRenderType.selection == 2) do
				(
					_spnRectLeg.enabled = true
					_spnRectWidth.enabled = true
					_spnRectAngle.enabled = true
					_spnRectAspect.enabled = true
					_chkLockAspect.enabled = true
				)
			)
			if (state == false and _chkSpView.state == false) do
			(
				_drpRenderType.enabled = false
				_spnSpThick.enabled = false
				_spnSpSide.enabled = false
				_spnSpAngle.enabled = false
				_spnRectLeg.enabled = false
				_spnRectWidth.enabled = false
				_spnRectAngle.enabled = false
				_spnRectAspect.enabled = false
				_chkLockAspect.enabled = false
			)	
		)
		on _chkSpView changed state do
		(
			if state == true do
			(
				_drpRenderType.enabled = true
				if (_drpRenderType.selection == 1) do
				(
					_spnSpThick.enabled = true
					_spnSpSide.enabled = true
					_spnSpAngle.enabled = true
				)
				if (_drpRenderType.selection == 2) do
				(
					_spnRectLeg.enabled = true
					_spnRectWidth.enabled = true
					_spnRectAngle.enabled = true
					_spnRectAspect.enabled = true
					_chkLockAspect.enabled = true
				)
			)
			if (state == false and _chkSpRender.state == false) do
			(
				_drpRenderType.enabled = false
				_spnSpThick.enabled = false
				_spnSpSide.enabled = false
				_spnSpAngle.enabled = false
				_spnRectLeg.enabled = false
				_spnRectWidth.enabled = false
				_spnRectAngle.enabled = false
				_spnRectAspect.enabled = false
				_chkLockAspect.enabled = false
			)
		)
		on _chkRescale changed state do
		(
			_dropDWGUnits.enabled = state
		)
		on _drpRenderType enabled do (print "enabled")
		on _drpRenderType selected state do (
			if (state == 1) do (_spnSpThick.enabled = true
				_spnSpSide.enabled = true
				_spnSpAngle.enabled = true
				_spnRectLeg.enabled = false
				_spnRectWidth.enabled = false
				_spnRectAngle.enabled = false
				_spnRectAspect.enabled = false
				_chkLockAspect.enabled = false)
			if (state == 2) do (_spnSpThick.enabled = false
				_spnSpSide.enabled = false
				_spnSpAngle.enabled = false
				_spnRectLeg.enabled = true
				_spnRectWidth.enabled = true
				_spnRectAngle.enabled = true
				_spnRectAspect.enabled = true
				_chkLockAspect.enabled = true)
			)
		on _chkSpAuto changed state do (_spnThresh.enabled = state)
		on _spnRectLeg changed val do
		(
			if _chkLockAspect.checked == false do (_spnRectAspect.value = _spnRectWidth.value/_spnRectLeg.value)
			if _chkLockAspect.checked == true do (_spnRectWidth.value = _spnRectLeg.value/_spnRectAspect.value)
		)
		on _spnRectWidth changed val do
		(
			if _chkLockAspect.checked == false do (_spnRectAspect.value = _spnRectWidth.value/_spnRectLeg.value)
			if _chkLockAspect.checked == true do (_spnRectLeg.value = _spnRectAspect.value*_spnRectWidth.value)
		)
		on _spnRectAspect changed val do (_spnRectWidth.value = _spnRectAspect.value*_spnRectLeg.value)

	)

	rollout _fbx ""
	(
		group "Presets"
		(
			checkbox _chkPreset "Use Preset" checked:true
			dropdownList _fbxPreset "Preset:" items:fbxPreset selection:2
		)
		group "Merge Mode"
		(
			dropdownList _drpFbxMode "File Content:" items:fbxMode selection:2
		)
		group "Geometry"
		(
			checkbox _chkFbxSmooth "Smoothing Groups" checked:(FBXImporterGetParam "SmoothingGroups")
		)
		group "Animation"
		(
			checkbox _chkFbxFill "Fill Timeline" checked:(FBXImporterGetParam "FillTimeline") across:2
			checkbox _chkFbxBake "Bake Animation Layers" checked:(FBXImporterGetParam "BakeAnimationLayers")
			checkbox _chkFbxOptical "Optical Markers" checked:(FBXImporterGetParam "Markers") across:2
			checkbox _chkFbxPoint "Point Cache File(s)" checked:(FBXImporterGetParam "PointCache")
			label _lblFbxDef "Deformations"
			checkbox _chkFbxDef "Deformations" checked:(FBXImporterGetParam "Import|IncludeGrp|Animation|Deformation") across:3
			checkbox _chkFbxSkin "Skins" checked:(FBXImporterGetParam "Skin")
			checkbox _chkFbxMorph "Morphs" checked:(FBXImporterGetParam "Shape")
			label _lblFbxBone "Bone Creation"
			checkbox _chkFbxLock "Lock width and height" checked:(FBXImporterGetParam "Import|IncludeGrp|Animation|Bone|BoneWidthHeightLock")
			dropdownList _drpFbxBone "Bone conversion:" items:boneConv selection:2
			spinner _txtFbxWidth "Width:" range:[0,10000,((FBXImporterGetParam "Import|IncludeGrp|Animation|Bone|Max4BoneWidth") as float)] width:80 across:3 type:#float
			spinner _txtFbxHeight "Height" range:[0,10000,((FBXImporterGetParam "Import|IncludeGrp|Animation|Bone|Max4BoneHeight") as float)] width:80 type:#float
			spinner _txtFbxTaper "Taper %:" range:[0,100,((FBXImporterGetParam "Import|IncludeGrp|Animation|Bone|Max4BoneTaper") as float)] width:100 type:#float
			label _lblFbxCam ""
			checkbox _chkFbxCam "Cameras" checked:(FBXImporterGetParam "Cameras")
			label _lblFbxLight ""
			checkbox _chkFbxLights "Lights" across:3 checked:(FBXImporterGetParam "Lights")
			checkbox _chkFbxSun "Sun and Sky" checked:(FBXImporterGetParam "Environment")
			checkbox _chkFbxGlob "Global Color" checked:(FBXImporterGetParam "Import|IncludeGrp|LightGrp|GlobalAmbientColor")
		)
		group "Advanced Options"
		(
			checkbox _chkFBXConv "Automatic Unit Conversion" checked:(FBXImporterGetParam "ScaleConversion")
			dropdownList _fbxUnits "File units converted to:" items:fbxUnits enabled:false
		)
		group "UI"
		(
			checkbox _chkFbxWarn "Show Warning Manager" checked:(FBXImporterGetParam "Import|AdvOptGrp|UI|ShowWarningsManager") across:2
			checkbox _chkFbxLog "Generate Log Data" checked:(FBXImporterGetParam "Import|AdvOptGrp|UI|GenerateLogData")
		)
		
		on _fbx open do
		(
			mode = FBXImporterGetParam "Mode"
			if mode == #create do _drpFbxMode.selection = 1
			if mode == #exmerge do _drpFbxMode.selection = 2
			if mode == #merge do _drpFbxMode.selection = 3
			impDum = FBXImporterGetParam "ImportBoneAsDummy"
			if impDum then _drpFbxBone.selection = 2 else _drpFbxBone.selection = 1
		)
		
		on _chkPreset changed state do
		(
			_fbxPreset.enabled = state
			if _chkPreset.state == false do
			(
				for c in fbxControls do (c.enabled = true)
			)
			if _chkPreset.state == true do
			(
				for c in fbxControls do (c.enabled = false)
			)
		)
		on _chkFbxDef changed state do (_chkFbxSkin.enabled = state
			_chkFbxMorph.enabled = state)
		on _chkFBXConv changed state do (_fbxUnits.enabled = not state)
		on _txtFbxWidth changed state do
		(
			if _chkFbxLock.checked == true do (_txtFbxHeight.value = _txtFbxWidth.value)
		)
		on _txtFbxHeight changed state do
		(
			if _chkFbxLock.checked == true do (_txtFbxWidth.value = _txtFbxHeight.value)
		)
		
		on _fbx rolledup state do 
		(
			fbxControls = _fbx.controls
			for  c = fbxControls.count to 1 by -1 do
			(
				if (MatchPattern (fbxControls[c] as string) pattern:"*Preset*" ignoreCase:true) do (deleteItem fbxControls c)
			)
			for c in fbxControls do
			(
				if (_chkPreset.checked == true) do (c.enabled = false)
			)
		)
	)

	rollout _obj ""
	(
		group "Preset"
		(
			checkbox _objUsePreset "Enable Preset" checked:false
			dropdownList _objPresets "Preset:" items:objPresets enabled:false selection:1
		)
		group "Objects"
		(
			checkbox _objReset "Reset Scene" checked:(_fnBooleanConvert (getINISetting obj_ini_import "General" "ResetScene")) across:2
			checkbox _objMesh "Import as single mesh" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Objects" "SingleMesh"))
			checkbox _objPoly "Import as Editable Poly" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Objects" "SingleMesh")) across:2
			checkbox _objTrain "Retriangulate Polygons" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Objects" "Retriangulate"))
		)
		group "Geometry"
		(
			checkbox _objFlip "Flip ZY-axis" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Geometry" "FlipNormals")) across:2
			checkbox _objCenter "Center Pivots" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Geometry" "CenterPivots"))
			checkbox _objShapes "Shapes/Lines" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Geometry" "Shapes")) across:2
			checkbox _objTex "Texture Coordinates" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Geometry" "TextureCoords"))
			checkbox _objSmooth "Smoothing groups" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Geometry" "SmoothingGroups"))
		)
		group "Normals"
		(
			radiobuttons _objNormals labels:objNormals columns:2
			spinner _objAutoS "Angle:" range:[0,360,((getINISetting obj_ini_import "Geometry" "SmoothAngle") as float)] type:#float enabled:false
			checkbox _objFlipN "Flip Normals" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Geometry" "FlipNormals"))
		)
		group "Units/Scale"
		(
			checkbox _chkOBJConv "Automatic Unit Conversion" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Units/Scale" "Convert"))
			dropdownList _objUnits "Incoming Model Units:" items:objUnits selection:((getINISetting obj_ini_import "Units/Scale" "ConvertFrom") as integer)
		)
		group "Materials"
		(
			checkbox _objUniq "Unique wire color" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Material" "UniqueWireColor"))
			dropdownList _objMats items:objMats selection:((getINISetting obj_ini_import "Material" "ImportMaterials") as integer)
			edittext _objPre "Prefix:"
			spinner _objBump "Default Bump:" range:[0,100,((getINISetting obj_ini_import "Material" "DefaultBump") as integer)]
			checkbox _objBlack "Force black ambient" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Material" "ForceBlackAmbient")) across:2
			checkbox _objImpMat "Import into material editor" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Material" "ImportIntoMatEditor"))
			checkbox _objShow "Show maps in viewport" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Material" "ShowMapsInViewport")) across:2
			checkbox _objCopy "Copy maps to project folder" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Material" "CopyMapsToProj"))
			checkbox _objOver "Overwrite Images" checked:(_fnBooleanConvert (getINISetting obj_ini_import "Material" "OverwriteImages")) enabled:false
		)
		
		checkbox _objLog "Write log to Import folder" checked:(_fnBooleanConvert (getINISetting obj_ini_import "General" "UseLogging"))
		
		on _objUsePreset changed state do
		(
			_objPresets.enabled = state
			if _objUsePreset.state == false do
			(
				for o in objControls do (o.enabled = true)
			)
			if _objUsePreset.state == true do
			(
				for o in objControls do (o.enabled = false)
			)
		)
		on _objNormals changed state do
		(
			if (state == 3) then (_objAutoS.enabled = true)
			else (_objAutoS.enabled = false)
		)
		on _objCopy changed state do (if state == true then (_objOver.enabled = true) else (_objOver.enabled = false))
		on _obj rolledup state do 
		(
			objControls = _obj.controls
			for  o = objControls.count to 1 by -1 do
			(
				if (MatchPattern (objControls[o] as string) pattern:"*Preset*" ignoreCase:true) do (deleteItem objControls o)
			)
			for o in objControls do
			(
				if (_objUsePreset.checked == true) then (o.enabled = false)
				else ()
			)

		)
	)

	rollout _rvt ""
	(
		dropdownList _rvtCombo "Combination Rule:" items:rvtCombo selection:((RevitImporterGetOption "combineoption") + 1)
		dropdownList _rvtDetail "Revit View Detail Level:" items:rvtLevel selection:((RevitImporterGetOption "viewdetail") + 1)
		group "Options"
		(
			checkbox _chkRvtMats "Materials" checked:(RevitImporterGetOption "material")
			checkbox _chkRvtCams "Cameras" checked:(RevitImporterGetOption "camera")
			checkbox _chkRvtDay "Daylight System" checked:(RevitImporterGetOption "daylight")
			checkbox _chkRvtLights "Lights" checked:(RevitImporterGetOption "light")
			checkbox _chkRvtRPC "RPCs" checked:(RevitImporterGetOption "rpc")
			checkbox _chkRvtBIM "BIM Info" checked:(RevitImporterGetOption "biminfo")
		)
		group "Geometry"
		(
			slider _sldDetail "Curved Objects Detail:" range:[0,15,8] ticks:15 type:#integer across:2 width:165
			edittext _txtDetail text:"8" width:28 align:#right readOnly:true
			checkbox _chkSimplify "Simplify Mesh" checked:false
			slider _sldSimplify "Simplify Mesh Detail:" range:[0.0,0.5,0.0] ticks:5 type:#float across:2 width:165 enabled:false
			edittext _txtSimplify text:"0.0" width:28 align:#right readOnly:true enabled:false
			checkbox _chkRvtOpt "Optimize Extrusion" checked:true
		)
			
		on _sldDetail changed state do (_txtDetail.text = _sldDetail.value as string)
		on _sldSimplify changed state do (_txtSimplify.text = _sldSimplify.value as string)
		on _chkSimplify changed state do (_sldSimplify.enabled = state
			_txtSimplify.enabled = state)
	)

	rollout _skp ""
	(
		dropdownList _skpUpAxis "Up Axis:" items:skpUpAxis selection:1
		dropdownList _skpHier "Hierarchy Mode:" items:skpHier selection:1
		checkbox _chkSkpPreserve "Preserve Layers" checked:(ATF_SKETCHUP_Import.PreserveLayers)
		Group "Options"
		(
			checkbox _chkSkpCams "Import Cameras" checked:(ATF_SKETCHUP_Import.ImportCameras)
			checkbox _chkSkpTex "Import Textures" checked:(ATF_SKETCHUP_Import.ImportTextures)
			checkbox _chkSkpMats "Double Sided Materials" checked:(ATF_SKETCHUP_Import.DoubleSidedMaterials)
			checkbox _chkSkpHidden "Import Hidden Objects" checked:(ATF_SKETCHUP_Import.ImportHiddenObjects)
		)
		
		on _skp open do
		(
			upAxis = ATF_SKETCHUP_Import.UpAxis
			if upAxis == #x do _skpUpAxis.selection = 1
			if upAxis == #y do _skpUpAxis.selection = 2
			if upAxis == #z do _skpUpAxis.selection = 3
			
			hier = ATF_SKETCHUP_Import.HierarchyMode
			if hier == #UsingGrouping do _skpHier.selection = 1
			if hier == #UsingLayer do _skpHier.selection = 2
			if hier == #Flattened do _skpHier.selection = 3
		)
	)

	fn _fnApplySettings &fType =
	(
		if fType == ".dwg" do
		(
			print "Applying DWG settings...."
			setINISetting dwg_ini_import #LastUsedSettings #DWG_UVWGeneration ((_dwg._drpTex.selection - 1) as string)
			if _dwg._chkRescale.checked then (setINISetting dwg_ini_import #LastUsedSettings #ConvertUnits "ON") else (setINISetting dwg_ini_import #LastUsedSettings #ConvertUnits "OFF")
			setINISetting dwg_ini_import #LastUsedSettings #DWG_LayerNameBasis (_dwg._dropPrims.selection as string)
			if _dwg._chkExtrude.checked then (setINISetting dwg_ini_import #LastUsedSettings #DWG_ExtrudeWithModifier "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_ExtrudeWithModifier "OFF")
			if _dwg._chkCreate.checked then (setINISetting dwg_ini_import #LastUsedSettings #DWG_AdtObjectTranslation "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_AdtObjectTranslation "OFF")
			if _dwg._chkScnMat.checked then (setINISetting dwg_ini_import #LastUsedSettings #DWG_ReplaceSceneMtlDefs "OFF") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_ReplaceSceneMtlDefs "ON")
			
			if _dwg._chkWeld.checked then (setINISetting dwg_ini_import #LastUsedSettings #Weld "ON") else (setINISetting dwg_ini_import #LastUsedSettings #Weld "OFF")
			setINISetting dwg_ini_import #LastUsedSettings #WeldThreshold (_dwg._spnWeld.value as string)
			if _dwg._chkSmooth.checked then (setINISetting dwg_ini_import #LastUsedSettings #AutoSmooth "ON") else (setINISetting dwg_ini_import #LastUsedSettings #AutoSmooth "OFF")
			setINISetting dwg_ini_import #LastUsedSettings #SmoothAngle (_dwg._spnAngle.value as string)
			if _dwg._chkNormals.checked then (setINISetting dwg_ini_import #LastUsedSettings #UnifyNormals "ON") else (setINISetting dwg_ini_import #LastUsedSettings #UnifyNormals "OFF")
			if _dwg._chkCap.checked then (setINISetting dwg_ini_import #LastUsedSettings #CapClosedEntities "ON") else (setINISetting dwg_ini_import #LastUsedSettings #CapClosedEntities "OFF")
			setINISetting dwg_ini_import #LastUsedSettings #DWG_UVWGeneration ((_dwg._drpTex.selection - 1) as string)
			setINISetting dwg_ini_import #LastUsedSettings #ShapeSteps (_dwg._spnCurve.value as string)
			setINISetting dwg_ini_import #LastUsedSettings #DWG_ACISDeviation (_dwg._spnDev.value as string)
			
			if _dwg._chkXref.checked then (setINISetting dwg_ini_import #LastUsedSettings #DWG_ResolveXrefs "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_ResolveXrefs "OFF")
			if _dwg._chkLights.checked then (setINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateLights "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateLights "OFF")
			if _dwg._chkHatch.checked then (setINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateHatches "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateHatches "OFF")
			if _dwg._chkSS.checked then (setINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateSunAndSky "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateSunAndSky "OFF")
			if _dwg._chkPoint.checked then (setINISetting dwg_ini_import #LastUsedSettings #DWG_TranslatePoints "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_TranslatePoints "OFF")
			if _dwg._chkView.checked then (setINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateCameras "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateCameras "OFF")
			if _dwg._chkUCS.checked then (setINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateGrids "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_TranslateGrids "OFF")
			
			if _dwg._chkSpRender.checked then (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Renderable "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Renderable "OFF")
			if _dwg._chkSpView.checked then (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_ViewportOrRenderer "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_ViewportOrRenderer "OFF")
			if (_dwg._drpRenderType.selection == 1) do (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Rectangular "OFF")
			if (_dwg._drpRenderType.selection == 2) do (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Rectangular "ON")
			if (_dwg._drpRenderType.selection == 1) do (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Rectangular "OFF")
			setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Thickness (_dwg._spnSpThick.value as string)
			setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Sides (_dwg._spnSpSide.value as string)
			setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Angle (_dwg._spnSpAngle.value as string)
			setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_ViewportThickness (_dwg._spnSpThick.value as string)
			setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_ViewportSides (_dwg._spnSpSide.value as string)
			setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_ViewportAngle (_dwg._spnSpAngle.value as string)
			setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Length (_dwg._spnRectLeg.value as string)
			setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Width (_dwg._spnRectWidth.value as string)
			setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Angle2 (_dwg._spnRectAngle.value as string)
			if (_dwg._chkLockAspect.checked) then (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_AspectLock "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_AspectLock "OFF")
			if (_dwg._chkLockAspect.checked) then (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_VptAspectLock "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_AspectLock "OFF")
			if (_dwg._chkGenMap.checked) then (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_GenUVs "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_GenUVs "OFF")
			if (_dwg._chkReal.checked) then (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_UsePhysicalScaleUVs "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_UsePhysicalScaleUVs "OFF")
			if (_dwg._chkSpAuto.checked) then (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Autosmooth "ON") else (setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Autosmooth "OFF")
			setINISetting dwg_ini_import #LastUsedSettings #DWG_Shape_Threshold (_dwg._spnThresh.value as string)
		)
		if fType == ".fbx" do
		(
			pluginManager.loadClass FbxImporter
			if (_fbx._chkPreset.enabled == true) do (print "Applying FBX Preset settings...."
				FBXImporterSetParam "ResetImport" (_fbx._fbxPreset.selected + ".fbximportpreset"))
			if (_fbx._chkPreset.enabled == false) do
			(
				print "Applying FBX settings...."
				if (_fbx._drpFbxMode.selection == 1) do (FBXImporterSetParam "Mode" #create)
				if (_fbx._drpFbxMode.selection == 2) do (FBXImporterSetParam "Mode" #exmerge)
				if (_fbx._drpFbxMode.selection == 3) do (FBXImporterSetParam "Mode" #merge)
				if (_fbx._chkFbxSmooth.checked) then (FBXImporterSetParam "SmoothingGroups" true) else (FBXImporterSetParam "SmoothingGroups" false)
				if (_fbx._chkFbxFill.checked) then (FBXImporterSetParam "FillTimeline" true) else (FBXImporterSetParam "FillTimeline" false)
				if (_fbx._chkFbxBake.checked) then (FBXImporterSetParam "BakeAnimationLayers" true) else (FBXImporterSetParam "BakeAnimationLayers" false)
				if (_fbx._chkFbxOptical.checked) then (FBXImporterSetParam "Markers" true) else (FBXImporterSetParam "Markers" false)
				if (_fbx._chkFbxPoint.checked) then (FBXImporterSetParam "PointCache" true) else (FBXImporterSetParam "PointCache" false)
				if (_fbx._chkFbxSkin.checked) then (FBXImporterSetParam "Skin" true) else (FBXImporterSetParam "Skin" false)
				if (_fbx._chkFbxMorph.checked) then (FBXImporterSetParam "Shape" true) else (FBXImporterSetParam "Shape" false)
				if (_fbx._chkFbxLock.checked) then (FBXImporterSetParam "SmoothingGroups" true) else (FBXImporterSetParam "SmoothingGroups" false)
				
				if (_fbx._drpFbxBone.selection == 2) do (FBXImporterSetParam "ImportBoneAsDummy" true)
				if (_fbx._drpFbxBone.selection == 1) do (FBXImporterSetParam "ImportBoneAsDummy" false)
				if (_fbx._chkFbxLock.checked) then (FBXImporterSetParam "Import|IncludeGrp|Animation|Bone|BoneWidthHeightLock" true) else (FBXImporterSetParam "Import|IncludeGrp|Animation|Bone|BoneWidthHeightLock" false)
				FBXImporterSetParam "Import|IncludeGrp|Animation|Bone|Max4BoneWidth" (_fbx._txtFbxWidth.value)
				FBXImporterSetParam "Import|IncludeGrp|Animation|Bone|Max4BoneHeight" (_fbx._txtFbxHeight.value)
				FBXImporterSetParam "Import|IncludeGrp|Animation|Bone|Max4BoneTaper" (_fbx._txtFbxTaper.value)
				
				if (_fbx._chkFbxCam.checked) then (FBXImporterSetParam "Cameras" true) else (FBXImporterSetParam "Cameras" false)
				if (_fbx._chkFbxLights.checked) then (FBXImporterSetParam "Lights" true) else (FBXImporterSetParam "Lights" false)
				if (_fbx._chkFbxSun.checked) then (FBXImporterSetParam "Environment" true) else (FBXImporterSetParam "Environment" false)
				if (_fbx._chkFbxGlob.checked) then (FBXImporterSetParam "Import|IncludeGrp|LightGrp|GlobalAmbientColor" true) else (FBXImporterSetParam "Import|IncludeGrp|LightGrp|GlobalAmbientColor" false)
				if (_fbx._chkFbxLights.checked) then (FBXImporterSetParam "Lights" true) else (FBXImporterSetParam "Lights" false)
				
				FBXImporterSetParam "ConvertUnit" fbxUnits[_fbx._fbxUnits.selection]				-- manually set incoming units
				FBXImporterSetParam "ScaleConversion" _fbx._chkFBXConv.checked					-- automatic conversion
				
				if (_fbx._chkFbxWarn.checked) then (FBXImporterSetParam "Import|AdvOptGrp|UI|ShowWarningsManager" true) else (FBXImporterSetParam "Import|AdvOptGrp|UI|ShowWarningsManager" false)
				if (_fbx._chkFbxLog.checked) then (FBXImporterSetParam "Import|AdvOptGrp|UI|GenerateLogData" true) else (FBXImporterSetParam "Import|AdvOptGrp|UI|GenerateLogData" false)
			)
		)
		if fType == ".obj" do
		(		
			if _obj._objUsePreset.checked == true then (print "Applying OBJ Preset settings...."
				setINISetting obj_ini_import "General" "Preset" _obj._objPresets.selected)
			else
			(
				print "Applying OBJ settings...."
				if _obj._objReset.checked == true then (setINISetting obj_ini_import "General" "ResetScene" "1") else (setINISetting obj_ini_import "General" "ResetScene" "0")
				
				if _obj._objMesh.checked == true then (setINISetting obj_ini_import "Objects" "SingleMesh" "1") else (setINISetting obj_ini_import "Objects" "SingleMesh" "0")
				if _obj._objPoly.checked == true then (setINISetting obj_ini_import "Objects" "AsEditablePoly" "1") else (setINISetting obj_ini_import "Objects" "AsEditablePoly" "0")
				if _obj._objTrain.checked == true then (setINISetting obj_ini_import "Objects" "Retriangulate" "1") else (setINISetting obj_ini_import "Objects" "Retriangulate" "0")
				
				if _obj._objFlip.checked == true then (setINISetting obj_ini_import "Geometry" "FlipZyAxis" "1") else (setINISetting obj_ini_import "Geometry" "FlipZyAxis" "0")
				if _obj._objCenter.checked == true then (setINISetting obj_ini_import "Geometry" "CenterPivots" "1") else (setINISetting obj_ini_import "Geometry" "CenterPivots" "0")
				if _obj._objShapes.checked == true then (setINISetting obj_ini_import "Geometry" "Shapes" "1") else (setINISetting obj_ini_import "Geometry" "Shapes" "0")
				if _obj._objTex.checked == true then (setINISetting obj_ini_import "Geometry" "TextureCoords" "1") else (setINISetting obj_ini_import "Geometry" "TextureCoords" "0")
				if _obj._objSmooth.checked == true then (setINISetting obj_ini_import "Geometry" "SmoothingGroups" "1") else (setINISetting obj_ini_import "Geometry" "SmoothingGroups" "0")
				
				setINISetting obj_ini_import "Geometry" "NormalsType" ((_obj._objNormals.state - 1) as string)
				if _obj._objNormals.state == 3 do (setINISetting obj_ini_import "Geometry" "SmoothAngle" (_obj._objAutoS.value as string))
				if _obj._objFlipN.checked == true then (setINISetting obj_ini_import "Geometry" "FlipNormals" "1") else (setINISetting obj_ini_import "Geometry" "FlipNormals" "0")
				
				if _obj._chkOBJConv.checked then (setINISetting obj_ini_import "Units/Scale" "Convert" "1") else (setINISetting obj_ini_import "Units/Scale" "Convert" "0")
				setINISetting obj_ini_import "Units/Scale" "ConvertFrom" ((_obj._objUnits.selection - 1) as string)
				
				if _obj._objUniq.checked == true then (setINISetting obj_ini_import "Material" "UniqueWireColor" "1") else (setINISetting obj_ini_import "Material" "UniqueWireColor" "0")
				setINISetting obj_ini_import "Material" "ImportMaterials" ((_obj._objMats.selection - 1) as string)
				if (_obj._objPre.text != "") then (setINISetting obj_ini_import "Material" "UseMatPrefix" "1") else (setINISetting obj_ini_import "Material" "UseMatPrefix" "0")
				setINISetting obj_ini_import "Material" "DefaultBump" (_obj._objBump.value as string)
				if _obj._objBlack.checked == true then (setINISetting obj_ini_import "Material" "ForceBlackAmbient" "1") else (setINISetting obj_ini_import "Material" "ForceBlackAmbient" "0")
				if _obj._objImpMat.checked == true then (setINISetting obj_ini_import "Material" "ImportIntoMatEditor" "1") else (setINISetting obj_ini_import "Material" "ImportIntoMatEditor" "0")
				if _obj._objShow.checked == true then (setINISetting obj_ini_import "Material" "ShowMapsInViewport" "1") else (setINISetting obj_ini_import "Material" "ShowMapsInViewport" "0")
				if _obj._objCopy.checked == true then (setINISetting obj_ini_import "Material" "CopyMapsToProj" "1") else (setINISetting obj_ini_import "Material" "CopyMapsToProj" "0")
				if _obj._objOver.checked == true then (setINISetting obj_ini_import "Material" "OverwriteImages" "1") else (setINISetting obj_ini_import "Material" "OverwriteImages" "0")
				
				if _obj._objLog.checked == true then (setINISetting obj_ini_import "General" "UseLogging" "1") else (setINISetting obj_ini_import "General" "UseLogging" "0")
			)
		)
		if fType == ".rvt" do
		(
			print "Applying Revit settings...."
			pluginManager.loadClass Revit_importer
			RevitImporterSetOption "combineoption" _rvt._rvtCombo.selection
			RevitImporterSetOption "viewdetail" (_rvt._rvtDetail.selection - 1)
			RevitImporterSetOption "material" _rvt._chkRvtMats.state
			RevitImporterSetOption "camera" _rvt._chkRvtCams.state
			RevitImporterSetOption "daylight" _rvt._chkRvtDay.state
			RevitImporterSetOption "light" _rvt._chkRvtLights.state
			RevitImporterSetOption "rpc" _rvt._chkRvtRPC.state
			RevitImporterSetOption "biminfo" _rvt._chkRvtBIM.state
			RevitImporterSetOption "geometrydetail" (_rvt._txtDetail.text as integer)
			if _rvt._chkSimplify == false do (RevitImporterSetOption "simplifymesh" -1)
			if _rvt._chkSimplify == true do (RevitImporterSetOption "simplifymesh" (_rvt._txtSimplify.text as float))
			RevitImporterSetOption "extrudedetect" _rvt._chkRvtOpt.state
		)
		if fType == ".skp" do
		(
			print "Applying Sketchup settings...."
			ATF_SKETCHUP_Import.UpAxis = skpUpAxisSet[_skp._skpUpAxis.selection]
			ATF_SKETCHUP_Import.HierarchyMode = skpHierSet[_skp._skpHier.selection]
			ATF_SKETCHUP_Import.PreserveLayers = _skp._chkSkpPreserve.state
			ATF_SKETCHUP_Import.ImportCameras = _skp._chkSkpCams.state
			ATF_SKETCHUP_Import.ImportTextures = _skp._chkSkpTex.state
			ATF_SKETCHUP_Import.DoubleSidedMaterials = _skp._chkSkpMats.state
			ATF_SKETCHUP_Import.ImportHiddenObjects = _skp._chkSkpHidden.state
		)
	)

	rollout _mainSettings ""
	(
		group "SEARCH"
		(
			edittext _folder "Folder:" text:searchFolder width:260 across:2
			button _btnBrowse "..." width:30 pos:[280,22]
			dropdownList _drpFilter "Search Filter:" items:filterArr
			button _btnGetFiles "GET FILES" across:2
			button _btnOpen "OPEN" tooltip:"Open selected asset's folder (only have 1 file selected)."
			checkbox _chkSubs "Include Subfolders" checked:true
			multilistbox _listFiles
		)
		group "SAVING"
		(
			checkbox _chkSaveCom "Save to same file" across:2 checked:true
			checkbox _chkSaveInd "Save each file separately" enabled:false
			edittext _saveFolder "Folder:" width:260 across:2
			button _btnSaveBrowse "..." width:30 pos:[280,323]
		)
		button _btnImportSel "IMPORT SELECTED" width:100 height:50 across:2
		button _btnImportAll "IMPORT ALL" width:100 height:50
		label _lblUpdate ""
		progressBar _progBar
		label _lblSpace ""
		button _btnDockLeft "<" across:3 align:#left border:false
		hyperlink _hyp "CPV Store" address:"https://cherrypicker.gumroad.com/" align:#center color:(color 222 14 14) hoverColor:(color 222 14 14) visitedColor:(color 222 14 14)
		button _btnDockRight ">" across:3 align:#right border:false

		fn _fnImport arr =
		(
			if (_chkSaveCom.checked and (_saveFolder.text == "")) then (messageBox "No save file set!")
			else
			(
				allLayNam = #()
				for n in arr do append allLayNam (filenameFromPath n)
				for i=1 to arr.count do
				(
					_lblUpdate.text = "Importing " + (filenameFromPath arr[i])
					print ("Importing " + (filenameFromPath arr[i]))
					_progBar.value = (100*i/arr.count)
					importFile arr[i] #noPrompt
					sleep 5
					windows.processPostedMessages()
					----- CAD BLOCKS -----
					----------------------
					if _clean._chkBlocks.checked do
					(
						print "Removing CAD Blocks...."
						_lblUpdate.text = "Removing CAD Blocks...."
						for i in objects do
						(
							i.transform.controller = prs()
							if (classof i.parent == LinkComposite) do (i.parent = undefined)		--unlink block children
						)
						delete (for o in (getclassinstances LinkComposite astrackviewpick:true) collect o.client)
					)
					------ SPLINES -------
					----------------------
					if _clean._chkSplines.checked do
					(
						_lblUpdate.text = "Deleting Splines...."
						print "Deleting Splines...."
						for s in shapes do
						(
							s.controller=prs()
							if classof s.parent == LinkComposite do (s.parent = undefined)
						)
						delete (for s in (getclassinstances SplineShape astrackviewpick:true) collect s.client)
					)
					------- LAYERS -------
					----------------------
					if _clean._chkLay.checked do
					(
						_lblUpdate.text = "Deleting empty layers...."
						print "Deleting empty layers...."
						try
						(
							for id = LayerManager.count - 1 to 1 by -1 do
							(
								layer = LayerManager.getLayer id
								contains_nodes = LayerManager.doesLayerHierarchyContainNodes layer.name
								if not contains_nodes then
								(
									deleted = LayerManager.deleteLayerByName layer.name
								)
							)
						)
						catch()
					)
					-- ANIM\NOTE TRACKS --
					----------------------
					if _clean._chkTracks.checked do
					(
						_lblUpdate.text = "Removing anim layers\\note tracks...."
						print "Removing anim layers\\note tracks...."
						try 
						(
							trackViewNodes[#Max_MotionClip_Manager].track = copy trackViewNodes[#Max_MotionClip_Manager].track
						)
						catch()
					)
					------- GROUPS -------
					----------------------
					if _clean._chkGroups.checked do
					(
						_lblUpdate.text = "Exploding all groups...."
						print "Exploding all groups...."
						for o in objects do (select o
							if isGroupHead o do explodeGroup o)
					)
					----- SMOOTHING ------
					----------------------
					if _clean._chkSmooth.checked do
					(
						print "Removing smoothing groups...."
						_lblUpdate.text = "Removing smoothing groups...."
						for o in objects do
						(
							disableSceneRedraw()
							if (classof o == Editable_Poly) do
							(
								select o
								local numFaces = polyop.getNumfaces o
								local faces = (for i in 1 to numFaces collect i) as bitarray
								polyOp.setFaceSmoothGroup o faces 0
							)
							if (classof o == Editable_mesh) do
							(
								for i=1 to (getNumFaces o) do
								(
									setFaceSmoothGroup o i 0
								)
								update o
							)
							enableSceneRedraw() 
						)
					)
					----- WELD VERTS -----
					----------------------
					if _clean._chkWeld.checked do
					(
						_lblUpdate.text = "Welding vertices...."
						print "Welding vertices...."
						for o in objects do
						(
							 if( isKindOf o GeometryClass ) then -- weld only in geometry objects
							(
								if classof o.baseObject == Editable_Mesh then
								(
									meshOp.weldVertsByThreshold o.mesh o.mesh.verts (_clean._txtCleanWeld.text as float)
								)
								
								if classof o.BaseObject == Editable_Poly then
								(
									select o
									setCommandPanelTaskMode #modify
									subObjectLevel = 1
									actionMan.executeAction 0 "40021"  -- Selection: Select All
									$.weldThreshold = (_clean._txtCleanWeld.text as float)
									$.EditablePoly.buttonOp  #WeldSelected
									subObjectLevel = 0
									setCommandPanelTaskMode #create
								)
							)
						)
					)
					----- ADD TO LAYER -----
					------------------------
					NewLayer = LayerManager.newLayerFromName (filenameFromPath arr[i])
					if (NewLayer == undefined) do (NewLayer = LayerManager.getLayerFromName (filenameFromPath arr[i]))
					for i = 0 to layerManager.count-1 do
					(
						counter = 0
						ilayer = layerManager.getLayer i
						for n in allLayNam do (if (ilayer.name == n) do (counter += 1))
						if counter == 0 do
						(
							if (ilayer.name != filename and ilayer.getParent() == undefined) do
							(
								if ilayer.getnumChildren() == 0 do
								(
									ilayer.setParent NewLayer
								)
							)
						)
					)
					(layerManager.getLayer 0).nodes &nodes
					if nodes.count != undefined do (NewLayer.addnodes nodes)
					----- OBJ MAT PREFIX -----
					--------------------------
					if (getFilenameType arr[i] == ".obj" and _obj._objPre.text != "") do
					(
						prefix = _obj._objPre.text
						ilayer = LayerManager.getLayerFromName (filenameFromPath arr[i])
						ilayer.select true
						objs = selection as array
						for o in objs do
						(
							matName = o.material.name
							if (MatchPattern matName pattern:(prefix + "*")) then (o.material.name = matName)
							else (o.material.name = prefix + "_" + matName)
						)
					)
					----- SAVE FILE -----
					---------------------
					_lblUpdate.text = "Saving scene..."
					if _chkSaveCom.checked do
					(
						saveMaxFile (_saveFolder.text)
					)
					if _chkSaveInd.checked do
					(
						filePath = getFilenamePath arr[i]
						filename = getFilenameFile arr[i]
						saveName = filePath + filename + ".max"
						saveMaxFile saveName
						resetMaxFile #noPrompt
					)
					_lblUpdate.text = ""
				)
				messageBox "Files imported successfully!"
			)
		)
		
		fn _fnGetList =
		(
			global fileNames = #()		-- array to hold filenames to show in multilistbox
			global fileTypes = #()		-- array to hold file extensions found
			subF = false				-- flag for searching subfolders
			global files = #()
			if _chkSubs.checked == true do (subF = true)		
			filterStr = filterArr[_drpFilter.selection]
			if filterStr == "All Suppported Formats" then
			(
				subFilArr = #("DWG","FBX","OBJ","RVT","SKP")			
				for f in subFilArr do
				(
					if subF == false do		-- if subfolders unselected
					(
						tempsArr = (_fnGetFiles f)
						for i=1 to tempsArr.count do (append files tempsArr[i])
					)
					if subF == true do
					(
						tempsArr = (getFilesRecursive _folder.text f)
						for i=1 to tempsArr.count do (append files tempsArr[i])
					)
				)
				files
			)
			else
			(
				if subF == false do (files = _fnGetFiles filterStr)
				if subF == true do (files = getFilesRecursive _folder.text filterStr)
				files
			)
			
			for f in files do (
				str = filenameFromPath f
				append fileNames str
				ext = getFilenameType f
				ext = trimLeft ext "."
				appendIfUnique fileTypes ext
			)
			if fileNames.count == 0 then
			(
				append  fileNames "No files found."
				_listFiles.items = fileNames
			)
			else (_listFiles.items = fileNames)
		)
		
		on _btnDockLeft pressed do
		(
			if _batchImporter.dialogBar == false then
			(
				cui.RegisterDialogBar _batchImporter style:#(#cui_floatable,#cui_dock_left,#cui_dock_right,#cui_handles)
				cui.DockDialogBar _batchImporter #cui_dock_left
			)
			else
			(
				cui.FloatDialogBar _batchImporter
				cui.unRegisterDialogBar _batchImporter
			)
		)
		
		on _btnDockRight pressed do
		(
			if _batchImporter.dialogBar == false then
			(
				cui.RegisterDialogBar _batchImporter style:#(#cui_floatable,#cui_dock_left,#cui_dock_right,#cui_handles)
				cui.DockDialogBar _batchImporter #cui_dock_right
			)
			else
			(
				cui.FloatDialogBar _batchImporter
				cui.unRegisterDialogBar _batchImporter
			)
		)
		
		on _btnBrowse pressed do
		(
			thePath = getSavepath initialDir:(_folder.text)
			if thePath != undefined then (_folder.text = thePath
				_saveFolder.text = (thePath + "\\batchImporter.max"))
			else ()
		)
		
		on _btnGetFiles pressed do
		(
			_fnGetList()
		)
		
		on _drpFilter selected state do
		(
			_fnGetList()
		)
		
		on _btnOpen pressed do
		(
			thePath = (getFilenamePath files[(_listFiles.selection as array)[1]])
			shellLaunch thePath ""
		)
		
		on _chkSaveCom changed state do (_saveFolder.enabled = state
			_btnSaveBrowse.enabled = state
			_chkSaveCom.enabled = state
			_chkSaveInd.enabled = not state
			_chkSaveInd.checked = not state)
			
		on _chkSaveInd changed state do (_saveFolder.enabled = not state
			_btnSaveBrowse.enabled = not state
			_chkSaveInd.enabled = state
			_chkSaveCom.enabled = not state
			_chkSaveCom.checked = not state)
		
		on _btnSaveBrowse pressed do
		(
			thePath = getSaveFileName initialDir:(_saveFolder.text) filename:"batchImporter" types:"3ds Max (*.max)|*.max"
			if (not MatchPattern thePath pattern:"*max") do thePath = thePath + ".max"
			if thePath != undefined then (_saveFolder.text = thePath)
			else ()
		)
		
		
		on _btnImportAll pressed do
		(
			arr = #()
			for i in files do
			(
				fType = getFilenameType i
				_lblUpdate.text = ("Applying " + fType + " settings....")
				_fnApplySettings fType
			)
			_fnImport files
			_progBar.value = 0
		)
		
		on _btnImportSel pressed do
		(
			arr = #()
			selected = _listFiles.selection
			for s in selected do (append arr files[s])
			if arr.count == 0 then (messageBox "No files selected!")
			else (
				for i in arr do
				(
					fType = getFilenameType i
					_lblUpdate.text = ("Applying " + fType + " settings....")
					_fnApplySettings fType
				)
				_fnImport arr
				_progBar.value = 0
			)
		)
	)
	createDialog _batchImporter width:360 height:550 pos:[150,50]
	AddSubRollout _batchImporter.roSubMain _mainSettings
	AddSubRollout _batchImporter.roSubMain _mainSettings
	AddSubRollout _batchImporter.roSubClean _clean
	AddSubRollout _batchImporter.roSubDWG _dwg
	AddSubRollout _batchImporter.roSubFBX _fbx
	AddSubRollout _batchImporter.roSubOBJ _obj
	AddSubRollout _batchImporter.roSubRVT _rvt
	AddSubRollout _batchImporter.roSubSKP _skp
)
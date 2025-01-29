try(DestroyDialog _batchInstall) catch()
rollout _batchInstall "Batch Importer Install"
(
	local tempBatchFolder = GetDir #temp + "\\tempCPV"
	local batchImp = GetDir #userscripts + "\\CPV\\BatchImporter"
	local batchMacro = GetDir #usermacros
	local batchMacroFile = batchMacro + "\\cpvBatchImporter_v1.mcr"
	local batchImpFile = batchImp + "\\cpvBatchImporter_v1.mse"
	
	ImgTag ImgTag_BG bitmap:(bitmap 2 2 color:gray) pos:[0,0]  \
			width:250 height:300 opacity:1 transparent:(color 0 255 255) enabled:off
	
	button _btnInstall "INSTALL!" width:100 height:50 pos:[75,230]
	
	fn DeleteDirAndSubDir rootDir =
	(
		try ( DOSCommand ("rmDir \"" + rootDir + "\" /s /q") ) catch (messagebox "Can't delete CPV folder!" title:"Batch Importer Install Error!")
	)
	
	fn _fnInstallBatch =
	(
		if tempBatchFolder != "" then
		(
			--	create folders
			local batchImpMainFolder = (makeDir batchImp)
			local batchMacroFolder = (makeDir batchMacro)
			
			if batchImpMainFolder != true then
			(
				messagebox "Unable to create userscript \"CPV\" folder" title:"Batch Importer Installation Error!"
			)
			if batchMacroFolder != true then
			(
				messagebox "Unable to create usermacroscript \"CPV\" folder" title:"Batch Importer Installation Error!"
			)
			else
			(
				-- check and delete existing files
				if doesFileExist batchImpFile do (deleteFile batchImpFile)
				if doesFileExist batchMacroFile do (deleteFile batchMacroFile)
				-- copy mse file
				if batchImpMainFolder == true then
				(		
					files = getFiles (tempBatchFolder + "\\CPV\\*.*")
					for f in files do
					(
						newFile = (batchImp + "\\" + (filenameFromPath f))
						if (doesFileExist newFile) do deleteFile newFile
						copyFile f newFile
					)
					if (doesFileExist batchImpFile == false) do messagebox "Installation Error!\nScript file not copied properly." title:"Batch Importer"
				)
				-- copy macroscript
				if batchMacroFolder == true then
				(		
					mcrFile = (tempBatchFolder + "\\cpvBatchImporter_v1.mcr")
					copyFile mcrFile (batchMacro + "\\cpvBatchImporter_v1.mcr")						
					if (doesFileExist batchMacroFile == false) do messagebox "Installation Error!\nMacroscript file not copied properly." title:"Batch Importer"
				)
				-- copy icons
				iconFile = tempBatchFolder + "\\cpvBatchImporter.png")
				iconName = "cpvBatchImporter.png"
				newIcon = (GetDir #userIcons) + "\\" + iconName
				if doesFileExist newIcon do deleteFile newIcon
				copyFile iconFile newIcon
				if (doesFileExist newIcon == false) do (messagebox "Installation Error!\nIcon file not copied properly." title:"Batch Importer"
				messageBox "Batch Importer successfully installed under the CPV category!"
			)
		)
		else (messagebox "Installation Error!\nTemp files not copied successfully." title:"Batch Importer")
	)
	
	on _batchInstall open do
	(
		ImgTag_BG.bitmap = (openBitmap (tempBatchFolder+"\\BatchImportInstallBG.png"))
	)
	
	on _btnInstall pressed do
	(
		_fnInstallBatch()
		DestroyDialog _batchInstall
	)
	
	on _batchInstall close do
	(
		if (tempBatchFolder != "") then (DeleteDirAndSubDir tempBatchFolder)
		try(filein (batchMacro + "\\cpvBatchImporter_v1.mcr")
			filein (batchImp + "\\cpvBatchImporter_v1.mse")) catch()
		gc()
	)
)
CreateDialog _batchInstall width:250 height:300

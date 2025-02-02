(
	global cpv_fileCopier
	global rolWidth = 400
	global fileassets	-- max file assets
	try(DestroyDialog cpv_fileCopier)catch()
	rollout cpv_fileCopier "CPV File Copier"
	(
		checkbox chk_Current "Search Current File" checked:true
		edittext txt_File "External Max File:" tooltip:"Max file to search in." across:2 fieldWidth:(rolWidth-93) enabled:false
		button btn_fileSearch "..." offset:[95,0] enabled:false
		edittext txt_oldPath "Search In:" tooltip:"Search for scene assets in this folder." across:2 fieldWidth:(rolWidth-58)
		button btn_patternSeach "..." offset:[95,0]
		edittext txt_newPath "Copy To:" tooltip:"Folder to copy files to." across:2 fieldWidth:(rolWidth-52)
		button btn_pathSearch "..." offset:[95,0]
		checkbox chk_AutoPath "Automatically repath assets" checked:true
		listbox lst_List readOnly:true
		button btn_Check "CHECK!" tooltip:"Check for files." across:2 width:200 height:50
		button btn_Copy "COPY!" width:200 height:50
		progressBar bar_Progress
		
		fn fn_search file folder = (
			fileassets = getMAXFileAssetMetadata file
			folder = trimRight folder "\\"	-- remove backslashes from end of folder search location as added in match pattern
			files = for asset in fileassets where (MatchPattern asset.filename pattern:(folder + "\\*") ignoreCase:true) collect #(asset.filename,asset.assetId)
			files
		)
		
		on btn_fileSearch pressed do (
			thePath = getOpenFileName types:"Max Files (*.max)|*.max"
			if thePath != undefined then (txt_File.text = thePath)
			else ()
		)
		
		on chk_Current changed state do (
			txt_File.enabled = not state
			btn_fileSearch.enabled = not state
		)
		
		on btn_patternSeach pressed do (
			thePath = getSavePath()
			if thePath != undefined then (txt_oldPath.text = thePath)
			else ()
		)
		
		on btn_pathSearch pressed do (
			thePath = getSavePath()
			if thePath != undefined then (txt_newPath.text = thePath)
			else ()
		)
		
		on btn_Check pressed do (
			if chk_Current.checked then file = (maxFilePath + maxFileName) else file = txt_File.text
			files = fn_search file txt_oldPath.text
			lst_List.items = for f in files collect f[1]
		)
		
		on btn_Copy pressed do (
			local classes = #(Bitmaptexture, VRayBitmap, CoronaBitmap)
			local newFile
			local fname
			bar_Progress.value = 0
			local copied = 0
			local notCopied = 0
			local newPath = (txt_newPath.text + "\\")
			if chk_Current.checked then file = (maxFilePath + maxFileName) else file = txt_File.text
			files = fn_search file txt_oldPath.text
			for f,i in files do
			(
				local fname = filenameFromPath f[1]
				local newFile = newPath + fname
				if (doesFileExist newFile == false) then (
					copyFile f[1] newFile
					copied += 1
					)
				else (notCopied += 1)
				if chk_AutoPath.checked do (		-- if autopath is checked
					if chk_Current.checked then (	-- if use current scene is checked
						for asset in fileassets do (
							for class in classes do (
								for c in (getClassInstances class) where ((MatchPattern asset.assetID pattern:f[2] ignoreCase:true) and (c.filename == asset.filename)) do (
									c.filename = newFile
								)
							)
						)
						ATSOps.Refresh()
					)
					else (
						for asset in fileassets where (MatchPattern asset.assetID pattern:f[2] ignoreCase:true) do (	-- go through asset in existing match file and if the asset matches the one in the file array
							asset.filename = newFile		-- change it's filepath to the new location
						)
					)
				)
				bar_Progress.value = 100.*i/files.count
			)
			if chk_AutoPath.checked do (
				if (queryBox "Automatically repathing assets will overwrite the existing file. Is this ok?") then (setMAXFileAssetMetadata file fileassets)
				else ()
			)
			messageBox ((files.count as string) +  " file(s) updated successfully!\n" + (copied as string) + " file(s) copied.\n" + (notCopied as string) + " file(s) not copied, as they already exist.")
			bar_Progress.value = 0
		)
	)
	CreateDialog cpv_fileCopier width:450
)

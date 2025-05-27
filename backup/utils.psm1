
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath config.psm1) -Function Get-BackupSchema -Force

Function Get-FilesCountAndSize {
	param (
			[string]$folder
	)

	$result = @{}

	Get-ChildItem -Path $folder -Recurse -File | ForEach-Object {
		$folderName = $_.Directory.FullName.Replace($folder, '~')

		$fileSize = $_.Length
		if ($result.ContainsKey($folderName)) {
			$value = $result[$folderName]
			$value.Count = $value.Count + 1
			$value.Size = $value.Size + $fileSize
		} else {
			$result[$folderName] = @{
				Count = 1
				Size = $fileSize
			}
		}
	}

	return $result
}

Function Compare-FolderSize {
	param (
		[Parameter(Mandatory)]
		[string]$folder1,
		[Parameter(Mandatory)]
		[string]$folder2
	)

	if (-not $folder1 -or -not $folder2) {
		throw "No valid arguments"
	}

	# resolve paths for folders
	$folders = $folder1, $folder2 | ForEach-Object {Resolve-Path -Path $_}

	# check if folders exist
	$folders | ForEach-Object {
		if (-not (Test-Path -Path $_)) {
			throw "Folder $_ not found"
		}
	}

	# parallel version
	$job1 = Start-Job -ScriptBlock {	
		param($inputFolderName)	
		Function Get-FilesCountAndSize {
			param (
					[string]$folder
			)

			try {
				$result = @{}

				Get-ChildItem -Path $folder -Recurse -File | ForEach-Object {
					$folderName = $_.Directory.FullName.Replace($folder, '~')

					$fileSize = $_.Length
					if ($result.ContainsKey($folderName)) {
						$value = $result[$folderName]
						$value.Count = $value.Count + 1
						$value.Size = $value.Size + $fileSize
					} else {
						$result[$folderName] = @{
							Count = 1
							Size = $fileSize
						}
					}
				}
				return $result
			} catch {
				# Capture the error and return it in the hashtable
				Write-Host "Returning error"
				return @{
					Error = $_.Exception.Message
				}
    		}
		}	
		
		Get-FilesCountAndSize -folder $inputFolderName
	} -ArgumentList $folders[0]

	$job2 = Start-Job -ScriptBlock {
		param($inputFolderName)
		
		Function Get-FilesCountAndSize {
			param (
					[string]$folder
			)

			try {
				$result = @{}

				Get-ChildItem -Path $folder -Recurse -File | ForEach-Object {
					$folderName = $_.Directory.FullName.Replace($folder, '~')

					$fileSize = $_.Length
					if ($result.ContainsKey($folderName)) {
						$value = $result[$folderName]
						$value.Count = $value.Count + 1
						$value.Size = $value.Size + $fileSize
					} else {
						$result[$folderName] = @{
							Count = 1
							Size = $fileSize
						}
					}
				}
				return $result
			} catch {
				# Capture the error and return it in the hashtable
				Write-Host "Returning error"
				return @{
					Error = $_.Exception.Message
				}
    		}
		}	
		
		Get-FilesCountAndSize -folder $inputFolderName
	} -ArgumentList $folders[1]	

	# Wait for jobs to complete and collect results
	$result1 = Receive-Job -Job $job1 -Wait
	$result2 = Receive-Job -Job $job2 -Wait	

	# Remove jobs
	Remove-Job -Job $job1, $job2

	if ($result1.Contains("Error")) {
		throw $result1["Error"]
	}

	if ($result2.Contains("Error")) {
		throw $result2["Error"]
	}

	$foldersInfo = $result1, $result2

	<#
	$foldersInfo = $folders | ForEach-Object {
		return Get-FilesCountAndSize -folder $_
	}
	#>

	$allKeysUnique = ($foldersInfo[0].Keys + $foldersInfo[1].Keys) | Sort-Object -Unique
	# Write-Host "all keys unique count: $($allKeysUnique.Count)" -ForegroundColor DarkGray

	foreach ($key in $allKeysUnique) {    
		for ($i = 0; $i -lt $folders.Length; $i++) {
			if (-Not $foldersInfo[$i].ContainsKey($key)) {
				throw "Folder $($folders[$i]) does not contain path $key"
			} 

			if ($i -gt 0) {
				$diff = @{
					Count = $foldersInfo[0][$key].Count - $foldersInfo[$i][$key].Count
					Size  = $foldersInfo[0][$key].Size - $foldersInfo[$i][$key].Size
				}
			}
		}

		if ($diff.Count -Ne 0) {
			throw "Different number of files:" + 
			"`n$($folders[0]): $($foldersInfo[0][$key].Count)" + 
			"`n$($folders[1]): $($foldersInfo[1][$key].Count)"
		}

		if ($diff.Size -Ne 0) {
			throw "Different file sizes:" + 
			"`n$($folders[0]): $($foldersInfo[0][$key].Size)" + 
			"`n$($folders[1]): $($foldersInfo[1][$key].Size)"
		}  
	}
}

Function Move-LogsByYear {
	param (
		[Parameter(Mandatory)]
		[string]$inputPath
	)
	
	if (-not (Test-Path -Path $inputPath)) {
		throw "Path $($inputPath) not found"
	}

	$path = Resolve-Path -Path $inputPath    

	Get-Childitem -Path $path -File | Where-Object {$_.Name -match '(.txt$|.log$)'} | Select-Object -Property Name, LastWriteTime | ForEach-Object {
		$name = $_.Name
		$date = $_.LastWriteTime.ToString("yyyy")

		$oldFilePath = Join-Path -Path $path -ChildPath $name

		$newFilePathDate = Join-Path -Path $path -ChildPath (Join-Path -Path "Log" -ChildPath $date)
		$newFilePath = Join-Path -Path $newFilePathDate -ChildPath $name

		if (-Not (Test-Path -Path $newFilePath)) {
			if (-Not (Test-Path -Path $newFilePathDate)) {
				New-Item -Path $newFilePathDate -ItemType Directory | Out-Null
			}
			Move-Item -Path $oldFilePath -Destination $newFilePath
			Write-Host "Moved file: $oldFilePath to $newFilePath" -ForegroundColor DarkGray
		} else {
				Write-Host "File already exists: $newFileName" -ForegroundColor Red
		}
	}
}

Function Remove-FilesByMaskWithRetention  {
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[string]$fileMask,
		[Parameter(Position=1, Mandatory=$true)]
		[int]$retainCount
	)

	$allFiles = Get-ChildItem -Path $fileMask -File | ForEach-Object {$_.FullName} | Sort-Object -Descending
	if ($allFiles.Count -gt $retainCount) {
		$retainedFiles = $allFiles[0..($retainCount - 1)]
		$filedToRemove = $allFiles | Where-Object {-not ($_ -in $retainedFiles)}

		$filedToRemove | ForEach-Object {
			Write-Host "Removing $_" -ForegroundColor DarkGray
			Remove-Item -Path $_
		}
	} else {
		Write-Host "No files to remove" -ForegroundColor DarkGray
	}
}

Function Sync-Folder {
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[string]$sourcePath,
		[Parameter(Position=1, Mandatory=$true)]
		[string]$targetPath,
		[Parameter(Position=2, Mandatory=$true)]
		[string]$folderName,
		[Parameter(Position=3, Mandatory=$false)]
		[bool]$isTargetPathLog=$false
	)

	$logFileRootPath = if($isTargetPathLog) {$targetPath} else {$sourcePath}
	$logFileName = "$(Get-Date -Format ""yyyy_MM_dd HH_mm_ss"") $folderName log.txt"
	$logFilePath = Join-Path -Path $(Split-Path -Path $logFileRootPath -Qualifier) -Child $($logFileName)

	$copyArgs = @(
		$sourcePath,
		$targetPath,
		"/MIR", 
		"/FFT",
		"/R:0", 
		"/Z",
		"/TEE", 
		"/NP",
		"/LOG:""$logFilePath"""
	)

	$process = Start-Process -FilePath "robocopy" -ArgumentList $copyArgs -NoNewWindow -Wait -PassThru
	$exitCode = $process.ExitCode

	# https://learn.microsoft.com/en-us/troubleshoot/windows-server/backup-and-storage/return-codes-used-robocopy-utility
	if ($exitCode -eq 0) {
		Write-Host "No files were copied" -ForegroundColor Magenta
	} elseif ($exitCode -eq 1) {
		Write-Host "Files were copied" -ForegroundColor Cyan
	} elseif ($exitCode -eq 2) {
		Write-Host "There are some additional files in the destination directory. No files were copied." -ForegroundColor Magenta
	} elseif ($exitCode -eq 3) {
		Write-Host "Some files were copied. Additional files were present." -ForegroundColor Cyan
	} elseif ($exitCode -eq 5) {
		Write-Host "Some files were copied. Some files were mismatched." -ForegroundColor Cyan
	} elseif ($exitCode -eq 6) {
		Write-Host "Additional files and mismatched files exist. No files were copied." -ForegroundColor Magenta
	} elseif ($exitCode -eq 7) {
		Write-Host "AFiles were copied, a file mismatch was present, and additional files were present." -ForegroundColor Cyan
	} elseif ($exitCode -gt 7) {
		throw "robocopy failed with exit code $exitCode"
	}
}

Function Sync-DriveFolders {
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[string]$sourceDriveLetter,
		[Parameter(Position=1, Mandatory=$true)]
		[string]$targetDriveLetter,
		[Parameter(Position=2, Mandatory=$true)]
		[string[]]$folderList
	)

	$sourceDrivePath = "$($sourceDriveLetter):\"
	if (-not (Test-Path -Path $sourceDrivePath)) {
		throw "Source path $($sourceDrivePath) not found"   
	}

	$targetDrivePath = "$($targetDriveLetter):\"
	if (-not (Test-Path -Path $targetDrivePath)) {
		throw "Target path $($targetDrivePath) not found"   
	}

	# handle Odeon separately
	$odeon = "Odeon"
	$odeonSourcePath = Join-Path -Path $sourceDrivePath -ChildPath $odeon
	if (Test-Path -Path $odeonSourcePath) {
		$oneDriveRootPath = $env:ONEDRIVE
		if ($null -ne $oneDriveRootPath) {
			$oneDriveOdeonPath = Join-Path -Path $oneDriveRootPath -ChildPath $odeon
			if (Test-Path -Path $oneDriveOdeonPath) {        
				Sync-Folder $oneDriveOdeonPath $odeonSourcePath $odeon $true
				Write-Host "Odeon refreshed" -ForegroundColor Magenta
			}
		}
	}

	# backup / sync
	foreach ($folder in $folderList) {
		$sourcePath = Join-Path -Path $sourceDrivePath -ChildPath $folder 
		$targetPath = Join-Path -Path $targetDrivePath -ChildPath $folder 

		if (-not (Test-Path -Path $sourcePath)) {
			throw "Source path $($sourcePath) not found"   
		}
		Write-Host "Processing source path $sourcePath" -ForegroundColor DarkGray

		$executionTime = Measure-Command {
			Sync-Folder $sourcePath $targetPath $folder 
		}
		Write-Host "Processing source path $sourcePath completed in $($executionTime.Seconds) seconds" -ForegroundColor DarkGray
	}

	# compare
	foreach ($folder in $folderList) {
		$sourcePath = Join-Path -Path $sourceDrivePath -ChildPath $folder 
		$targetPath = Join-Path -Path $targetDrivePath -ChildPath $folder 
		Write-Host "`nComparing $sourcePath with $targetPath ..." -ForegroundColor DarkGray

		$executionTime = Measure-Command {
			Compare-FolderSize $sourcePath $targetPath
		}
		Write-Host "Comparing $folder completed in $($executionTime.Seconds) seconds" -ForegroundColor DarkGray
	}

	# archive logs
	Move-LogsByYear $sourceDrivePath
	Write-Host "Archiving logs completed" -ForegroundColor DarkGray
}

Function Sync-SchemaDrives {
	$backupSchema = Get-BackupSchema

	$availableDriveNames = Get-PSDrive | Where-Object {$_.Provider.Name -eq 'FileSystem'} | Select-Object -ExpandProperty Name

	$availableBackupSchemas = $backupSchema | Where-Object {
		$availableDriveNames.contains($_.sourceDrive) -and $availableDriveNames.contains($_.targetDrive)
	}

	if ($availableBackupSchemas.Length -eq 0) {
		throw "Backup schema not found for available drives: $($availableDriveNames -join ', ')"
	}

	if ($availableBackupSchemas.Length -gt 1) {
		throw "More than one backup schema found for available drives: $($availableDriveNames -join ', ')"
	}

	$workingBackupSchema = $availableBackupSchemas[0]
	Write-Host "Found backup schema: $($workingBackupSchema.name)" -ForegroundColor Magenta
	
	Sync-DriveFolders $workingBackupSchema.sourceDrive $workingBackupSchema.targetDrive $workingBackupSchema.folders
}
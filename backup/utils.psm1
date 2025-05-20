Function Get-FilesCountAndSize {
    param (
        [string]$folder
    )

    $result = @{}

    Get-ChildItem -Path $folder -Recurse -File | ForEach-Object {
        $folderName = $_.Directory.Name.Replace($folder, 'root')
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

    $foldersInfo = $folders | ForEach-Object {
        return Get-FilesCountAndSize -folder $_
    }
    Write-Host "Read folders info" -ForegroundColor DarkGray

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
    Write-Host "Resolved path $path" -ForegroundColor DarkGray
  }
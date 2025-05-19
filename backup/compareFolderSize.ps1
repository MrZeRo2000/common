param (
    [string]$folder1,
    [string]$folder2
)

$ErrorActionPreference = "Stop"

Function Get-FilesCountAndSize {
    param (
        [string]$folder
    )

    $result = @{}

    Get-ChildItem -Path $folder -Recurse -File | Group-Object -Property Directory | ForEach-Object {
        $name = $_.Name.Replace($folder, 'root')
        $result.Add($name, (@{         
            Count     = $_.Group.Count
            Size     = (($_.Group | Measure-Object -Property Length -Sum).Sum)
        }))
    }

    return $result
}

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

$allKeysUnique = ($foldersInfo[0].Keys + $foldersInfo[1].Keys) | Sort-Object -Unique
Write-Host "all keys unique count: $($allKeysUnique.Count)" -ForegroundColor DarkGray

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


<#
$jobs = foreach ($folder in $folders) {
    Start-Job -ScriptBlock {
        # return Get-FilesCountAndSize -folder $folder

        $result = @{}

        Get-ChildItem -Path $folder -Recurse -File | Group-Object -Property Directory | ForEach-Object {
            Write-Host "Processing name $($_.Name)" -ForegroundColor DarkGray
            $name = $_.Name.Replace($folder, '')
            $result.Add($name, (@{         
                Count     = $_.Group.Count
                Size     = (($_.Group | Measure-Object -Property Length -Sum).Sum)
            }))
        }

        return $result

    } -ArgumentList $folder
}
#>

# Get-FilesCountAndSize -folder $folders[0]
# Get-FilesCountAndSize -folder $folders[1]

<#
Get-ChildItem -Path ../data/f1 -Recurse -File | Group-Object -Property Directory | ForEach-Object {
    @{
        DirectoryName = $_.Name
        FileCount     = $_.Group.Count
        TotalSize   = (($_.Group | Measure-Object -Property Length -Sum).Sum)
    }
}
#>
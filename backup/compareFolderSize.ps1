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
        $name = $_.Name.Replace($folder, '')
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

$foldersFiledCountAndSizes = $folders | ForEach-Object {
    return Get-FilesCountAndSize -folder $_
}

Write-Host "1 count: $($foldersFiledCountAndSizes[0].Keys.Count)" -ForegroundColor DarkGray
Write-Host "2 count: $($foldersFiledCountAndSizes[1].Keys.Count)" -ForegroundColor DarkGray

$allKeys = $foldersFiledCountAndSizes[0].Keys + $foldersFiledCountAndSizes[1].Keys
Write-Host "all keys count: $($allKeys.Count)" -ForegroundColor DarkGray

$allKeysUnique = $allKeys | Sort-Object -Unique
Write-Host "all keys unique count: $($allKeysUnique.Count)" -ForegroundColor DarkGray


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
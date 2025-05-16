param (
    [string]$folder1,
    [string]$folder2
)

if (-not $folder1 -or -not $folder2) {
    throw "No valid arguments"
}

$folders = $folder1, $folder2
$folders | ForEach-Object {
    if (-not (Test-Path -Path $_)) {
        throw "Folder $_ not found"
    }
}

foreach ($folder in $folders) {
    # $folderSize = (Get-ChildItem -Path $folder -Recurse | Measure-Object -Property Length -Sum).Sum
    # Write-Host "Folder: $folder, Size: $($folderSize / 1MB) MB" -ForegroundColor DarkGray
}

<#

Get-ChildItem -Path ../data/f1 -Recurse -File | Group-Object -Property Directory | ForEach-Object {
    @{
        DirectoryName = $_.Name
        FileCount     = $_.Group.Count
        TotalSize   = (($_.Group | Measure-Object -Property Length -Sum).Sum)
    }
}

#>
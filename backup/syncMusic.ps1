<#
.SYNOPSIS
    Updates music in Z drive
.DESCRIPTION
    Updates music archive on Z drive without extensive checks
    Has no arguments
#>

$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath utils.psm1) -Function Sync-Folder -Force

$sourceRootPath = "J:\ARCHIVE"
$targetRootPath = "Z:"
$folders = "Lossless", "MP3 Music", "Classics"

foreach($folder in $folders) {
    #Write-Host "Sync $sourceRootPath\$folder $targetRootPath\$folder $folder"
    Sync-Folder "$sourceRootPath\$folder" "$targetRootPath\$folder" $folder
}
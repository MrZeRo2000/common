<#
.SYNOPSIS
    Backup lightroom to OneDrive
.DESCRIPTION
    This script backs up lightroom catalog to OneDrive and removes old archives.
    Has no arguments
#>

$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath config.psm1) -Function Get-BackupConfig
Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath utils.psm1) -Function Remove-FilesByMaskWithRetention

$backupConfig = Get-BackupConfig
Write-Host "winRAR folder: $($backupConfig.winRARPath)" -ForegroundColor DarkGray
Write-Host "Target root folder: $($backupConfig.targetRootPath)" -ForegroundColor DarkGray

$archiveName = "Lightroom"
$sourcePath = Join-Path -Path (Join-Path -Path (Join-Path -Path "$env:USERPROFILE" -ChildPath Photo) -ChildPath Lightroom) -ChildPath "*.lrcat"
$targetPath = Join-Path -Path $backupConfig.targetRootPath -ChildPath Project
$targetArchivePath = Join-Path -Path $targetPath -ChildPath "$archiveName.rar"

$arguments = "a -r -e+shrad -hp$($backupConfig.archivePassword) -agYYMMDD_HHMM -m5 -ep ""$targetArchivePath"" ""$sourcePath"""
Write-Host "Arguments: $arguments" -ForegroundColor DarkGray

$currentDate = Get-Date

Start-Process -FilePath """$($backupConfig.winRARPath)""" -ArgumentList $arguments -NoNewWindow -Wait

# check produced file
$targetArchiveMaskPath = Join-Path -Path $targetPath -ChildPath "$archiveName*.*"
if ((Get-ChildItem -Path "$targetArchiveMaskPath" -File -Recurse | Where-Object { $_.LastWriteTime -ge ($currentDate) }).Count -eq 0) {
    throw "No files were produced for $targetArchiveMaskPath in $targetPath"
}

# remove old archives
$targetArchiveAllPath = Join-Path -Path $targetPath -ChildPath "$archiveName*.rar"
Remove-FilesByMaskWithRetention -fileMask $targetArchiveAllPath -retainCount 2
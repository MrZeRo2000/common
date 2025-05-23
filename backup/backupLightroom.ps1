<#
.SYNOPSIS
    Backup lightroom to OneDrive
.DESCRIPTION
    This script backs up lightroom catalog to OneDrive.
    Has no arguments
#>

$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath config.psm1) -Function Get-BackupConfig

$backupConfig = Get-BackupConfig
Write-Host "winRAR folder: $($backupConfig.winRARPath)" -ForegroundColor DarkGray
Write-Host "Target root folder: $($backupConfig.targetRootPath)" -ForegroundColor DarkGray

$archiveName = "Lightroom"
$sourcePath = Join-Path -Path (Join-Path -Path (Join-Path -Path "$env:USERPROFILE" -ChildPath Photo) -ChildPath Lightroom) -ChildPath "*.lrcat"
$targetPath = Join-Path -Path $backupConfig.targetRootPath -ChildPath Project
$targetArchivePath = Join-Path -Path $targetPath -ChildPath "$archiveName.rar"
$targetArchiveMaskPath = Join-Path -Path $targetPath -ChildPath "$archiveName*.*"


$arguments = "a -r -e+shrad -hp$($backupConfig.archivePassword) -agYYMMDD_HHMM -m5 -ep ""$targetArchivePath"" ""$sourcePath"""
Write-Host "Arguments: $arguments" -ForegroundColor DarkGray

$currentDate = Get-Date

Start-Process -FilePath """$($backupConfig.winRARPath)""" -ArgumentList $arguments -NoNewWindow -Wait

if ((Get-ChildItem -Path "$targetArchiveMaskPath" -File -Recurse | Where-Object { $_.LastWriteTime -ge ($currentDate) }).Count -eq 0) {
    throw "No files were produced for $targetArchiveMaskPath in $targetPath"
}

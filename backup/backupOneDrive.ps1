<#
.SYNOPSIS
    Backup OneDrive folder
.DESCRIPTION
    Backup OneDrive folder to %TEMP%\backup.
    Has no arguments
#>

$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath config.psm1) -Function Get-BackupConfig

$backupConfig = Get-BackupConfig
Write-Host "winRAR folder: $($backupConfig.winRARPath)" -ForegroundColor DarkGray
Write-Host "OneDrive root folder: $($backupConfig.targetRootPath)" -ForegroundColor DarkGray

$sourcePath = $($backupConfig.targetRootPath)
$targetPath = Join-Path -Path (Join-Path -Path $env:TEMP -ChildPath backup) -ChildPath priv

$archivePaths = Get-ChildItem -Path $sourcePath -Recurse -Directory -Depth 0 | ForEach-Object {"`"$($_.FullName)`""}
$archivePathsString = $archivePaths -Join " "

$arguments = "a -s -m5 -r -x$sourcePath\Odeon\db\backup\*.bak* -x$sourcePath\Temp\ -e+shrad -hp$($backupConfig.archivePassword) -agYYMMDD_HHMM ""$targetPath"" $archivePathsString"

Write-Host "Arguments: $arguments" -ForegroundColor DarkGray

Start-Process -FilePath """$($backupConfig.winRARPath)""" -ArgumentList $arguments -NoNewWindow -Wait

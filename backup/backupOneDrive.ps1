<#
.SYNOPSIS
    Backup OneDrive folder
.DESCRIPTION
    Backup OneDrive folder to %TEMP%\backup. Np arguments
    Has no arguments
#>

$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath config.psm1) -Function Get-BackupConfig

$backupConfig = Get-BackupConfig
Write-Host "winRAR folder: $($backupConfig.winRARPath)" -ForegroundColor DarkGray
Write-Host "OneDrive root folder: $($backupConfig.targetRootPath)" -ForegroundColor DarkGray

$sourcePath = $($backupConfig.targetRootPath)
$targetPath = Join-Path -Path (Join-Path -Path $env:TEMP -ChildPath backup) -ChildPath priv

$arguments = "a -s -m5 -r -e+shrad -hp$($backupConfig.archivePassword) -agYYMMDD_HHMM ""$targetPath"" ""$sourcePath"""

Write-Host "Arguments: $arguments" -ForegroundColor DarkGray

Start-Process -FilePath """$($backupConfig.winRARPath)""" -ArgumentList $arguments -NoNewWindow -Wait

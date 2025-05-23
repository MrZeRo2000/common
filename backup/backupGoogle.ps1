<#
.SYNOPSIS
    Backup Google data to OneDrive
.DESCRIPTION
    Backup Google data (bookmarks, feedly subscriptions, contacts, calendars) to OneDrive.
    Has no arguments
#>

$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath config.psm1) -Function Get-BackupConfig

$backupConfig = Get-BackupConfig
Write-Host "winRAR folder: $($backupConfig.winRARPath)" -ForegroundColor DarkGray
Write-Host "Target root folder: $($backupConfig.targetRootPath)" -ForegroundColor DarkGray

$sourceRootPath = Join-Path -Path $env:TEMP -ChildPath "backup"
if (-not (Test-Path $sourceRootPath)) {
    throw "Backup path $sourceRootPath not found"
}

$archives = @{
    bookmarks = "bookmarks.html"
    feedly_subscriptions = "feedly.opml"
    contacts = "contacts.csv"
    gmail_ical = "*@gmail.com.ical.zip"
}

$sourcePaths = @{}

# fill and check source files
$archives.Keys | ForEach-Object {
    $archiveFile = $archives[$_]
    $sourcePath = Join-Path -Path (Join-Path -Path $env:TEMP -ChildPath backup) -ChildPath $archiveFile

    if (-not (Test-Path $sourcePath)) {
        throw "Source file $sourcePath does not exist"
    }

    $sourcePaths[$_] = $sourcePath
}

$archives.Keys | ForEach-Object {
    $archiveName = $_
    
    $sourcePath = $sourcePaths[$archiveName]
    $targetRootPath = Join-Path -Path $backupConfig.targetRootPath -ChildPath Internet
    $targetPath = Join-Path -Path $targetRootPath -ChildPath $archiveName

    $arguments = "a -r -e+shrad -hp$($backupConfig.archivePassword) -agYYMMDD_HHMM -m5 -ep ""$targetPath"" ""$sourcePath"""

    Write-Host "Arguments: $arguments" -ForegroundColor DarkGray

    $currentDate = Get-Date

    Start-Process -FilePath """$($backupConfig.winRARPath)""" -ArgumentList $arguments -NoNewWindow -Wait
    
    if ((Get-ChildItem -Path "$targetRootPath" -File -Recurse | Where-Object { $_.LastWriteTime -ge ($currentDate) }).Count -eq 0) {
        throw "No files were produced for $archiveFile in $targetRootPath"
    }
}
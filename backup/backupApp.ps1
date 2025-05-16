
$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath config.psm1) -Function Get-BackupConfig

$backupConfig = Get-BackupConfig
Write-Host "winRAR folder: $($backupConfig.winRARPath)" -ForegroundColor DarkGray
Write-Host "Target root folder: $($backupConfig.targetRootPath)" -ForegroundColor DarkGray

$targetPath = Join-Path -Path $backupConfig.targetRootPath -ChildPath "App"

# Prepare registry exports
$process = Start-Process -FilePath "regedit" -ArgumentList "/e", "$env:TEMP\TagRename.reg", "HKEY_CURRENT_USER\Software\Softpointer" -NoNewWindow -Wait -PassThru
$exitCode = $process.ExitCode
if (($exitCode -ne 0) -and ($null -ne $exitCode)) {
  Write-Host "WinRAR failed with exit code $exitCode" -ForegroundColor Red
  exit 1
}

$apps = @{
  foobar2000_v2_config = "$env:APPDATA\foobar2000-v2"
  photoshop_settings = "$env:APPDATA\Adobe\Adobe Photoshop*\Adobe Photoshop*Settings\*.*"
  lightroom_settings = "$env:APPDATA\Adobe\Lightroom"
  TagRename_config = "$env:TEMP\TagRename.reg"
  ssh_config = "$env:USERPROFILE\.ssh"
}

$argsTemplate = "a -r -hp$($backupConfig.archivePassword) -agYYMMDD_HHMM -m5 ""$targetPath\{0}"" ""{1}"""
Write-Host "Arguments template: $argsTemplate" -ForegroundColor DarkGray

$apps.Keys | ForEach-Object {
  $appName = $_
  $appPath = $apps[$_]
  # Write-Host "Backing up $appName to $appPath" -ForegroundColor DarkGray

  $arguments = $argsTemplate -f $appName, $appPath
  Write-Host "Arguments: $arguments" -ForegroundColor DarkGray

  $currentDate = Get-Date

  Start-Process -FilePath """$($backupConfig.winRARPath)""" -ArgumentList $arguments -NoNewWindow -Wait

  if ((Get-ChildItem -Path "$targetPath\$appName*.*" -File -Recurse | Where-Object { $_.LastWriteTime -ge ($currentDate) }).Count -eq 0) {
    # throw "No files were produced for $appName in $appPath"
    Write-Host "No files were produced for $appName in $appPath" -ForegroundColor Yellow
  }
}
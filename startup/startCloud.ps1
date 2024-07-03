<#
.Description
Startup script for cloud services
PowerShell parameters to run hidden:
-WindowStyle Hidden -ExecutionPolicy Bypass -File "startCloud.ps1"
#>


Write-Host "Starting" -ForegroundColor DarkGray

do {
  Write-Host "Checking volume ..." -ForegroundColor DarkMagenta
  $volumeFound = Test-Path "R:\"

  if (!($volumeFound)) {
    Start-Sleep -Seconds 1
  }

} until ($volumeFound)
Write-Host "Volume found" -ForegroundColor DarkGreen

$startPath = "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
Write-Host "Starting $startPath ..." -ForegroundColor DarkMagenta
Start-Process -FilePath $startPath -ArgumentList "/background"
Write-Host "Started" -ForegroundColor DarkGreen
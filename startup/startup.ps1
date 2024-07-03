<#
.Description
Startup script
PowerShell parameters to run hidden:
-WindowStyle Hidden -ExecutionPolicy Bypass -File "startup.ps1"
#>

$foobarPath = "${env:ProgramFiles}\foobar2000\foobar2000.exe"
if (Test-Path -Path $foobarPath -PathType leaf) {
  Write-Host "Starting FooBar" -ForegroundColor DarkGray
  Start-Process -FilePath $foobarPath -WindowStyle Minimized
} else {
  Write-Host "FooBar not found: $foobarPath" -ForegroundColor Red
}

# Write-Host "Deleting temp files" -ForegroundColor DarkGray
# Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
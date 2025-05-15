
Function Get-BackupConfig {
  $winRARPaths = "$env:LOCALAPPDATA\Programs\WinRAR\winrar.exe", "$env:ProgramFiles\WinRAR\winrar.exe"

  $winRARPath = $winRARPaths | ForEach-Object -Process {
    if (Test-Path -Path $_) {
      return $_      
    }
  }

  if ($null -eq $winRARPath) {
    throw "WinRAR not found in the expected locations"
  }

  $targetRootPaths = "R:/OneDrive/", "$env:USERPROFILE\OneDrive\"

  $targetRootPath = $targetRootPaths | ForEach-Object -Process {
    if (Test-Path -Path $_) {
      return $_      
    }
  }

  if ($null -eq $targetRootPath) {
    throw "Target root path not found"
  }


  return @{
    winRARPath = $winRARPath
    targetRootPath = $targetRootPath
  }
}
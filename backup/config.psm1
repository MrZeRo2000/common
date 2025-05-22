
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

  $securityPath = Join-Path -Path $PSScriptRoot -ChildPath "security.json"
  if (-Not (Test-Path -Path $securityPath)) {
    throw "Security file not found at $securityPath"
  }

  $security = Get-Content -Raw $securityPath | ConvertFrom-Json


  return @{
    winRARPath = $winRARPath
    targetRootPath = $targetRootPath
    archivePassword = $security.archivePassword
  }
}

Function Get-BackupSchema {

  $schemaPath = Join-Path -Path $PSScriptRoot -ChildPath "schema.json"
  if (-Not (Test-Path -Path $schemaPath)) {
    throw "Schema file not found at $schemasPath"
  }

  return Get-Content -Raw -Path $schemaPath | ConvertFrom-Json
}
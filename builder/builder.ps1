<#

#>

function Find-Java {
  $SearchPaths = "$env:LOCALAPPDATA\Programs", "C:\WinApp"
  Write-Host Path to search: $SearchPaths

  $path = $null
  foreach($SearchPath in $SearchPaths | Where-Object {Test-Path $_}) {
    Write-Host "Searching in $SearchPath"
    $found = Get-ChildItem -Path $SearchPath | Where-Object {$_.name -like "*jdk*"} | Select-Object Name | Select-Object -First 1
    if ($found) {
      $path = "$SearchPath\$($found.Name)"
      break
    }
  }  
  return $path
}

function Set-Java-Home {
  if (-Not ($env:JAVA_HOME)) {
    $javaPath = Find-Java    
    if ($javaPath) {
      Write-Host Found JAVA path: $javaPath
      $env:JAVA_HOME = $javaPath
      return $true
    } else {
      Write-Host JAVA path not found
      return $false
    }
  } else {
    Write-Host JAVA HOME: $env:JAVA_HOME
    return $true
  }
}

function Build {
  param (        
        [string]$rootLocation = "/",
        [string]$projects,
        [string]$command        
    )

    # Write-Host "RootLocation: $rootLocation, projects: $projects, command: $command"
    $startLocation = Get-Location
    
    foreach ($project in $projects.split()) {
      Set-Location -Path "$PSScriptRoot../../..$rootLocation/$project"
      ./gradlew.bat $command.split()
    }

    Set-Location $startLocation
}


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
      ./gradlew.ps1 $command
    }

    Set-Location $startLocation
}

function Start-Build-Java-Int {
  param (        
        [string]$project        
    )
    $startLocation = Get-Location    
    
    Set-Location -Path "$PSScriptRoot../../..$rootLocation/$project"
    ./gradlew.ps1 clean deployInt    

    Set-Location $startLocation
}
function Start-Build-Java-Prod {
  param (        
        [string]$project        
    )
    $startLocation = Get-Location    
    
    Set-Location -Path "$PSScriptRoot../../../$project"
    ./gradlew.ps1 clean deployProd

    Set-Location $startLocation
}

function Find-Tomcat  {
  param (        
    [string]$version = "10.1.10"  
  )

  $SearchPaths = "D:\prj\apache-tomcat-$version", "$env:USERPROFILE\prj\apache-tomcat-$version"
  Write-Host Searching for TomCat in: $SearchPaths

  foreach($SearchPath in $SearchPaths | Where-Object {Test-Path $_}) {
    Write-Host Found TomCat in $SearchPath
    return $SearchPath
  }
}

function Remove-If-Exists {
  param (
    [string]$path
  )

  if (Test-Path -Path $path) {
    Remove-Item -Path "$path\*" -Recurse -Confirm:$false
  }
}

function Start-Build-Web {
  param (
    [string]$project
  )
  Write-Host Building project $project -ForegroundColor DarkGray

  $startLocation = Get-Location

  Set-Location "$PSScriptRoot../../../$project"
  $env:Path += ";$env:LOCALAPPDATA\Programs\node;$PSScriptRoot../../../$project/node_modules/.bin"
  
  # remove prevously built project
  Remove-If-Exists "dist/$project" -Recurse -Confirm:$false
  # build the project
  ng build --configuration production --base-href=/$project/

  Set-Location $startLocation

  Write-Host Project $project build completed -ForegroundColor Cyan
}

function Start-Deploy-Web {
  param (
    [string]$tomcat,
    [string]$project
  )
  Write-Host Deploying project $project -ForegroundColor DarkGray

  Remove-If-Exists "$tomcat\work\Catalina\localhost\$project"
  Remove-If-Exists "$tomcat\webapps\$project"
  
  Copy-Item -Path "$PSScriptRoot../../../$project/dist/$project/*" -Destination "$tomcat\webapps\$project\" -Recurse  

  Write-Host Project $project deployed -ForegroundColor Cyan
}

function Start-Build-And-Deploy-Web {
  param (
    [string]$project
  )
  $tomcat = Find-Tomcat
  if (-Not($tomcat)) {
    Write-Host "Tomcat not found" -ForegroundColor Red
    return
  }

  Start-Build-Web -project $project
  Start-Deploy-Web -tomcat $tomcat -project $project    
}

function Start-Build-And-Deploy-Java-Web {
  param (
    [string]$project
  )
  Start-Build-Java-Prod "$project-wss"
  Start-Build-And-Deploy-Web "$project-ang"
}
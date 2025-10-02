<#

#>

$ErrorActionPreference = "Stop"

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

function Set-JavaHome {
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

function Start-BuildJavaInt {
  param (        
        [string]$project        
    )
    $startLocation = Get-Location    
    
    Set-Location -Path "$PSScriptRoot../../..$rootLocation/$project"
    ./gradlew.ps1 clean deployInt    

    Set-Location $startLocation
}
function Start-BuildJavaProd {
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

function Remove-IfExists {
  param (
    [string]$path
  )

  if (Test-Path -Path $path) {
    Remove-Item -Path "$path\*" -Recurse -Confirm:$false
  }
}

function  New-IfNotExists {
  param (
    [string]$path
  )

  Write-Host Checking folder $path -ForegroundColor DarkGray

  if (-not (Test-Path -Path $path -PathType Container)) {
    Write-Host Creating folder $path -ForegroundColor DarkGray
    New-Item -ItemType Directory -Path $path
  }
}


function Start-BuildWeb {
  param (
    [string]$project
  )
  Write-Host Building project $project -ForegroundColor DarkGray

  $startLocation = Get-Location

  Set-Location "$PSScriptRoot../../../$project"

  $localNodePath = "$env:LOCALAPPDATA\Programs\node\"
  if (Test-Path -Path $localNodePath) {
      $env:Path = $env:Path.Replace(";$env:Programfiles\nodejs\", "")
      $env:Path += ";$localNodePath"      
  }
  $env:Path += ";$PSScriptRoot../../../$project/node_modules/.bin"
  
  # remove prevously built project
  Remove-IfExists "dist/$project" -Recurse -Confirm:$false
  # build the project
  Write-Host "Current location: $(Get-Location)" -ForegroundColor DarkGray
  Invoke-Expression "ng build --configuration production --base-href=/$project/"

  Set-Location $startLocation

  Write-Host Project $project build completed -ForegroundColor Cyan
}

function Start-DeployWeb {
  param (
    [string]$tomcat,
    [string]$project
  )
  Write-Host Deploying project $project -ForegroundColor DarkGray

  $DestinationFolder = "$tomcat\webapps\$project"

  Remove-IfExists "$tomcat\work\Catalina\localhost\$project"
  Remove-IfExists "$DestinationFolder"
  New-IfNotExists "$DestinationFolder"

  Write-Host Copying to $DestinationFolder -ForegroundColor DarkGray
  
  Copy-Item -Path "$PSScriptRoot../../../$project/dist/$project/browser/*" -Destination "$DestinationFolder\" -Recurse  

  Write-Host Project $project deployed -ForegroundColor Cyan
}

function Start-BuildAndDeployWeb {
  param (
    [string]$project
  )
  $tomcat = Find-Tomcat
  if (-Not($tomcat)) {
    Write-Host "Tomcat not found" -ForegroundColor Red
    return
  }

  Start-BuildWeb -project $project
  Start-DeployWeb -tomcat $tomcat -project $project    
}

function Start-BuildAndDeployJavaWeb {
  param (
    [string]$project
  )
  Start-BuildJavaProd "$project-wss"
  Start-BuildAndDeployWeb "$project-ang"
}
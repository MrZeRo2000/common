param ($project = $(throw "Project parameter is required."))

$ErrorActionPreference = "Stop"
Import-Module $PSScriptRoot\builder.psm1

Write-Host "Started with project $project" -ForegroundColor DarkGray
Start-Build-And-Deploy-Java-Web $project
Write-Host "Project $project completed" -ForegroundColor DarkGray

param ($project = $(throw "Project parameter is required."))

$ErrorActionPreference = "Stop"
Import-Module $PSScriptRoot\builder.psm1  -Force

Write-Host "Started with project $project" -ForegroundColor DarkGray
Start-BuildAndDeployWeb $project
Write-Host "Project $project completed" -ForegroundColor DarkGray

param ($project = $(throw "Project parameter is required."))
Import-Module $PSScriptRoot\builder.ps1 -Force

Write-Host "Started with project $project" -ForegroundColor DarkGray
Start-Build-And-Deploy-Web $project
Write-Host "Project $project completed" -ForegroundColor DarkGray

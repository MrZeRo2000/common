param ($project = $(throw "Project parameter is required."))
. $PSScriptRoot\builder.ps1

Write-Host "Started with project $project" -ForegroundColor DarkGray
Start-Build-And-Deploy-Web $project
Write-Host "Project $project completed" -ForegroundColor DarkGray

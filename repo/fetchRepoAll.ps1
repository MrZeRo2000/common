. "$PSScriptRoot\fetchRepo.ps1"

# Write-Host "$PSScriptRoot\builder.ps"
FetchRepoAll "\", "\AndroidStudioProjects\"
Set-Location -Path "$PSScriptRoot"
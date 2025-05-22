Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath fetchRepo.psm1) -Function FetchRepoAll -Force

# Write-Host "$PSScriptRoot\builder.ps"

FetchRepoAll "AndroidStudioProjects", "PyCharmProjects"

Set-Location -Path "$PSScriptRoot"
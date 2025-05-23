Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath utils.psm1) -Function Update-RepoAll -Force

# Write-Host "$PSScriptRoot\builder.ps"

Update-RepoAll "AndroidStudioProjects", "PyCharmProjects"

Set-Location -Path "$PSScriptRoot"
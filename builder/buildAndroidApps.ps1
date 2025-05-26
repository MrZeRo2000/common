$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\builder.psm1

if (Set-JavaHome) {
  Build -rootLocation /AndroidStudioProjects/ -projects 'symphonytimer-android violetnote-android odeon-android fingerlocker-android' -command 'clean build'
}
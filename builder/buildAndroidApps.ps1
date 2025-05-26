$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\builder.psm1

if (Set-Java-Home) {
  Build -rootLocation /AndroidStudioProjects/ -projects 'symphonytimer-android violetnote-android odeon-android fingerlocker-android' -command 'clean build'
}
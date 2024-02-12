. $PSScriptRoot\builder.ps1

if (Set-Java-Home) {
  Build -rootLocation /AndroidStudioProjects/ -projects 'symphonytimer-android violetnote-android odeon-android fingerlocker-android' -command 'clean build'
}
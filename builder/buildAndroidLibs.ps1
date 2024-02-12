. $PSScriptRoot\builder.ps1

if (Set-Java-Home) {
  Build -rootLocation /AndroidStudioProjects/ -projects 'library-common-android library-gdrive-android library-msgraph-android library-view-android' -command 'clean publishToMavenLocal'
}
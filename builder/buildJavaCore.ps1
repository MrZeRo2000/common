. $PSScriptRoot\builder.ps1

if (Set-Java-Home) {
  Build -projects 'jutils-core violetnote-core' -command 'clean publishToMavenLocal'
}
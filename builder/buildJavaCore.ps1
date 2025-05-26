$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\builder.psm1


if (Set-Java-Home) {
  Build -projects 'jutils-core violetnote-core' -command 'clean publishToMavenLocal'
}
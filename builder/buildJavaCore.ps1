$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\builder.psm1

if (Set-JavaHome) {
  Build -projects 'jutils-core violetnote-core' -command 'clean publishToMavenLocal'
}
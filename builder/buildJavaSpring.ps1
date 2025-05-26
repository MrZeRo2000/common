$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\builder.psm1

if (Set-Java-Home) {
  Build -projects 'rainments-wss violetnote-wss odeon-wss' -command 'clean build'
}
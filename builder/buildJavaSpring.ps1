$ErrorActionPreference = "Stop"

Import-Module $PSScriptRoot\builder.psm1

if (Set-JavaHome) {
  Build -projects 'rainments-wss violetnote-wss odeon-wss' -command 'clean build'
}
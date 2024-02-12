. $PSScriptRoot\builder.ps1

if (Set-Java-Home) {
  Build -projects 'rainments-wss violetnote-wss odeon-wss' -command 'clean build'
}
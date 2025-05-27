$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath utils.psm1) -Function Remove-FilesByMaskWithRetention

Remove-FilesByMaskWithRetention -fileMask "../data/2024/SDS*.*" -retainCount 2



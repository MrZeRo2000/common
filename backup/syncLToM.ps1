$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath utils.psm1) -Function Sync-DriveFolders

Sync-DriveFolders L M "app", "data"
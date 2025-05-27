$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath utils.psm1) -Function Compare-FolderSize

Compare-FolderSize "../data/f1" "../data/f2"



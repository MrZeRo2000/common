
$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath utils.psm1) -Function Copy-EXIF

Copy-EXIF -srcFolder "C:\Users\r1525\Photo\JPEG Orig" -destFolder "C:\Users\r1525\Photo\JPEG"


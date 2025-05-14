<#
.SYNOPSIS
    Copies EXIF data from JPEG Щкшп JPEG
.DESCRIPTION
    Synchronizes EXIF data from the original JPEG files to the processed JPEG files
#>

$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath utils.psm1) -Function Copy-EXIF

Copy-EXIF -srcFolder "$env:USERPROFILE\Photo\JPEG Orig" -destFolder "$env:USERPROFILE\Photo\JPEG"
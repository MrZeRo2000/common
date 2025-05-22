<#
.SYNOPSIS
    Backup files across different drives
.DESCRIPTION
    This script collects finds available drives and chooses backup according to configuration in schema.json
    Has no arguments
#>

$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath utils.psm1) -Function Sync-SchemaDrives -Force

Sync-SchemaDrives
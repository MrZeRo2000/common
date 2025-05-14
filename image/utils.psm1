<#
.SYNOPSIS
    Image processing utils
.DESCRIPTION
    Utility functions for image processing tasks
#>

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath config.psm1) -Function Get-ImgConfig

Function Copy-EXIF() {
    param (        
        [string]$srcFolder,
        [string]$destFolder
    )

    Write-Host "Source folder: $srcFolder, Destination folder: $destFolder" -ForegroundColor DarkGray

    $exifToolPath = (Get-ImgConfig).tool_exif

    $srcFiles = Get-ChildItem -Path $srcFolder -Recurse -File -Include *.jpg
    $destFiles = Get-ChildItem -Path $destFolder -Recurse -File -Include *.jpg

    Write-Host "Source files: $($srcFiles.Count), Destination files: $($dstFiles.Count)" -ForegroundColor DarkGray

    # Create a hashtable for destination files using their names as keys
    $destFileTable = @{}
    foreach ($file in $destFiles) {
        if (-not $destFileTable.ContainsKey($file.Name)) {
            $destFileTable[$file.Name] = @()
        }
        $destFileTable[$file.Name] += $file.FullName
        Write-Host "Added full name: $($file.FullName) to key $($file.Name)"
    }

    foreach ($srcFile in $srcFiles) {
      if ($destFileTable.ContainsKey($srcFile.Name)) {
          foreach ($destMatch in $destFileTable[$srcFile.Name]) {
              $cmd = "$exifToolPath -overwrite_original -tagsFromFile ""$($srcFile.FullName)"" ""$destMatch"""
              Write-Host "Command: $cmd" -ForegroundColor DarkGray

              Invoke-Expression -Command $cmd

              $exitCode = $LASTEXITCODE
              if ($exitCode -ne 0) {
                  Write-Host "EXIFTool failed with exit code $exitCode" -ForegroundColor Red
                  exit 1
              }
          }
      }
    }
}
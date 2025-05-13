<#
.SYNOPSIS
    Moves and converts jpeg images
.DESCRIPTION
    The script moves jpeg images from raw folder to jpeg folder, resizes them for viewing.
#>

$ErrorActionPreference = "Stop"

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath config.psm1) -Function Get-ImgConfig, Test-Tools

$config = Get-ImgConfig

Write-Host "NEW folder: $($config.img_new_folder)" -ForegroundColor DarkGray
Write-Host "RAW folder: $($config.img_raw_folder)" -ForegroundColor DarkGray
Write-Host "JPEG folder: $($config.img_jpeg_folder)" -ForegroundColor DarkGray
Write-Host "View folder: $($config.img_view_folder)" -ForegroundColor DarkGray
Write-Host ""

Test-Tools
Write-Host ""

# Copy RAW to JPEG
Write-Host "Copy RAW to JPEG Started" -ForegroundColor Magenta
Get-ChildItem -Path $config.img_raw_folder -Directory | ForEach-Object {
    Copy-Item -Path "$($config.img_raw_folder)\$($_.Name)" -Filter *.jpg -Destination "$($config.img_jpeg_folder)\" -Recurse
    Get-ChildItem -Path "$($config.img_raw_folder)\$($_.Name)" -Include *.jpg -Recurse | Remove-Item
} 
Write-Host "Copy RAW to JPEG Completed" -ForegroundColor DarkGreen
Write-Host ""

# Set EXIF
Write-Host "Set EXIF Started" -ForegroundColor Magenta
$cmd = "$($config.tool_exif) ""-filemodifydate<datetimeoriginal"" $($config.img_jpeg_folder)\ -r -charset FileName=Cyrillic"
Write-Host "Command: $cmd" -ForegroundColor DarkGray
Invoke-Expression -Command $cmd

$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Host "EXIFTool failed with exit code $exitCode" -ForegroundColor Red
    exit 1
}

Write-Host "Set EXIF Completed" -ForegroundColor DarkGreen
Write-Host ""

# Copy JPEG to VIEW
Write-Host "Copy JPEG to VIEW Started" -ForegroundColor Magenta
Get-ChildItem -Path $config.img_jpeg_folder -Directory | ForEach-Object {
    Copy-Item -Path "$($config.img_jpeg_folder)\$($_.Name)" -Filter *.jpg -Destination "$($config.img_view_folder)\" -Recurse
} 
Write-Host "Copy JPEG to VIEW Completed" -ForegroundColor DarkGreen
Write-Host ""

# Resize
Write-Host "Resize View Started" -ForegroundColor Magenta
Get-ChildItem -Path $config.img_view_folder -Directory | ForEach-Object { 
    $cmd = "$($config.tool_mogrify) -quality 90 -filter Lanczos -resize 1280x1280> -monitor ""$($config.img_view_folder)\$($_.Name)\*.jpg"""
    Invoke-Expression -Command $cmd

    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        Write-Host "Mogrify failed with exit code $exitCode" -ForegroundColor Red
        exit 1
    }
} 
Write-Host "Resize View Completed" -ForegroundColor DarkGreen

# Set EXIF for resized
Write-Host "Set EXIF for resized Started" -ForegroundColor Magenta
$cmd = "$($config.tool_exif) ""-filemodifydate<datetimeoriginal"" $($config.img_view_folder)\ -r -charset FileName=Cyrillic"
Invoke-Expression -Command $cmd

$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Host "EXIFFool for resized failed with exit code $exitCode" -ForegroundColor Red
    exit 1
}

Write-Host "Set EXIF for resized Completed" -ForegroundColor DarkGreen
Write-Host ""
Write-Host "Completed" -ForegroundColor Cyan

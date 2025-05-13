<#
.SYNOPSIS
  Configuration module for image processing scripts
.DESCRIPTION
  Variables and functions to set up the environment for image processing tasks
#>

Function Get-ImgConfig {
  return @{
    img_new_folder = "$Env:USERPROFILE\Photo\New"
    img_raw_folder = "$env:USERPROFILE\Photo\RAW"
    img_jpeg_folder = "$env:USERPROFILE\Photo\JPEG"
    img_view_folder = "$env:USERPROFILE\Photo\View"
    tool_exif = "$env:USERPROFILE\AppData\Local\Programs\EXIFTool\exiftool.exe"
    tool_mogrify = "$env:USERPROFILE\AppData\Local\Programs\ImageMagick\mogrify.exe"
  }
}

Function Test-Tools {
    $config = Get-ImgConfig
    $tools = $config.tool_exif, $config.tool_mogrify    
    foreach ($tool in $tools) {
        Write-Host "Checking tool $tool" -ForegroundColor Magenta
        if (-Not (Test-Path -Path $tool)) {
            throw "Tool $tool does not exist."
        } else {
            Write-Host "Tool $tool found." -ForegroundColor DarkGreen
        }
    }
}
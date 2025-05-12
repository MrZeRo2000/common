<#
.SYNOPSIS
  Configuration for image processing scripts
.DESCRIPTION
  Variables and functions to set up the environment for image processing tasks
#>

$img_new_folder = $Env:USERPROFILE + "\Photo\New"
$img_jpeg_folder = "$env:USERPROFILE\Photo\JPEG"
$img_view_folder = "$env:USERPROFILE\Photo\View"

$tool_exif = "$env:USERPROFILE\AppData\Local\Programs\EXIFTool\exiftool.exe"
$tool_mogrify = "$env:USERPROFILE\AppData\Local\Programs\ImageMagick\mogrify.exe"

$tools = $tool_exif, $tool_mogrify

Function Test-Tools {
    param (
        [string[]]$tools
    )
    
    foreach ($tool in $tools) {
        if (-Not (Test-Path -Path $tool)) {
            throw "Tool $tool does not exist."
        }
    }
}
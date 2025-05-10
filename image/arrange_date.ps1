Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath config.ps1) -Variable "img_new_folder"


$path = $img_new_folder
if (-Not (Test-Path -Path $path)) {
    throw "Path $path does not exist."
}

$files = Get-Childitem -Path $path | Where-Object -Property Length -Value 10000 -GE | Select-Object -Property Name, LastWriteTime

Write-Host "Found $($files.Count) files." -ForegroundColor Green

$files | ForEach-Object {
    $file = $_.Name
    $date = $_.LastWriteTime.ToString("yyyy_MM_dd")
    # $newFileName = "$date-$file"
    $oldFilePath = Join-Path -Path $path -ChildPath $file

    $newFilePathDate = Join-Path -Path $path -ChildPath $date
    $newFilePath = Join-Path -Path $newFilePathDate -ChildPath $file

    if (-Not (Test-Path -Path $newFilePath)) {
      if (-Not (Test-Path -Path $newFilePathDate)) {
        New-Item -Path $newFilePathDate -ItemType Directory
      }
      Move-Item -Path $oldFilePath -Destination $newFilePath
      Write-Host "Moved file: $oldFilePath to $newFilePath" -ForegroundColor DarkGray
    } else {
        Write-Host "File already exists: $newFileName" -ForegroundColor Red
    }
}
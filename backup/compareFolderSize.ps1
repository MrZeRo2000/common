param (
    [string]$folder1,
    [string]$folder2
)

if (-not $folder1 -or -not $folder2) {
    throw "No valid arguments"
}

$folders = $folder1, $folder2
$folders | ForEach-Object {
    if (-not (Test-Path -Path $_)) {
        throw "Folder $_ not found"
    }
}


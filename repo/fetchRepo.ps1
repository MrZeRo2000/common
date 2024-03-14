function FetchRepoAll {
    param (
        [Parameter(Mandatory)]
        [string[]]$FolderNames
    )    

    # Write-Host "Invoked with params: $FolderNames"

    ForEach($FolderName in $FolderNames) {
        # Write-Host "Folder: $FolderName"
        $Location = "$PSScriptRoot$FolderName"
        # Write-Host "Location: $Location"

        ForEach($RepoFolder in Get-ChildItem -Path $Location -Directory | Select-Object -Property "Name") {
            $RepoLocation = "$Location$($RepoFolder.Name)"
            FetchRepo $RepoLocation
        }
    }
    
}

function FetchRepo {
    param (
        [Parameter(Mandatory)]
        [string[]]$Location
    )    
    
    Write-Host "Fetching repo in $Location" -ForegroundColor DarkCyan
    
    if (Test-Path "$Location\.git\") {
        Write-Host "Found Git in $Location" -ForegroundColor DarkGreen
        Set-Location -Path "$Location\"
        Invoke-Expression -Command "git pull --rebase"
    } else {
        Write-Host "No Git in $Location" -ForegroundColor DarkGray
    }

}

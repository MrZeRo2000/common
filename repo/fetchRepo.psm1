function FetchRepoAll {
    param (
        [Parameter(Mandatory)]
        [string[]]$FolderNames
    )    
    # Write-Host "Started with params $($FolderNames -join ', ')" -ForegroundColor DarkGray

    $rootPath = Join-Path -Path $env:USERPROFILE -Child "prj"
    if (-not (Test-Path $rootPath)) {
        throw "Path $rootPath not found"
    }

    # include root folder
    $allFolderNames = $FolderNames + ""
    
    ForEach($FolderName in $allFolderNames) {
        $path = Join-Path -Path $rootPath -Child $FolderName
        if (-not (Test-Path $path)) {
            throw "Path from folder name $path not found"
        }
        Write-Host "Processing path $path" -ForegroundColor DarkGray

        $RepoFolders = Get-Childitem -Path $path -Recurse -Depth 1 -Directory -Force -Filter .git | 
            Select-Object -ExpandProperty  "FullName" | 
            Split-Path -Parent

        # Write-Host "Running for folders  $($RepoFolders -join ', ')" -ForegroundColor DarkGray            
        ForEach($RepoFolder in $RepoFolders) {            
            FetchRepo $RepoFolder
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
        # Invoke-Expression -Command "git pull --rebase"

        $process = Start-Process -FilePath "git" -ArgumentList "pull", "--rebase" -NoNewWindow -Wait -PassThru
        $exitCode = $process.ExitCode
        if (($exitCode -ne 0) -and ($null -ne $exitCode)) {
            throw "GIT pull failed with exit code $exitCode"
        }

    } else {
        Write-Host "No Git in $Location" -ForegroundColor DarkGray
    }
}

# Define the function that returns a hashtable
function Get-Data {
    param (
        [string]$dataInput
    )
    try {
        # Simulate some work and potential error
        if ($dataInput -eq "Error") {
            throw "An error occurred with dataInput: $dataInput"
        }

        # Return a hashtable
        return @{
            dataInput = $dataInput
            Length = $dataInput.Length
            Timestamp = (Get-Date).ToString()
        }
    }
    catch {
        # Capture the error and return it in the hashtable
        return @{
            Error = $_.Exception.Message
            dataInput = $dataInput
            Timestamp = (Get-Date).ToString()
        }
    }
}

# Create a runspace pool
$runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
$runspacePool.Open()

# Define the script block to execute in parallel
$scriptBlock = {
    param($dataInput)
    # Define the function within the script block
    function Get-Data {
        param (
            [string]$dataInput
        )
        Write-Host "Running with dataInput: $dataInput"

        try {
            # Simulate some work and potential error
            if ($dataInput -eq "Error") {
                throw "An error occurred with dataInput: $dataInput"
            }

            # Return a hashtable
            return @{
                dataInput = $dataInput
                Length = $dataInput.Length
                Timestamp = (Get-Date).ToString()
            }
        }
        catch {
            # Capture the error and return it in the hashtable
            return @{
                Error = $_.Exception.Message
                dataInput = $dataInput
                Timestamp = (Get-Date).ToString()
            }
        }
    }

    # Call the function
    Get-Data -dataInput $dataInput
}

# Create PowerShell instances for each parallel execution
$powershell1 = [powershell]::Create().AddScript($scriptBlock).AddArgument("Hello")
$powershell1.RunspacePool = $runspacePool

$powershell2 = [powershell]::Create().AddScript($scriptBlock).AddArgument("Error")
$powershell2.RunspacePool = $runspacePool

# Start the parallel execution
$asyncResult1 = $powershell1.BeginInvoke()
$asyncResult2 = $powershell2.BeginInvoke()

# Wait for completion and collect the results
$result1 = $powershell1.EndInvoke($asyncResult1)
$result2 = $powershell2.EndInvoke($asyncResult2)

# Close the runspace pool
$runspacePool.Close()
$runspacePool.Dispose()

# Output the results
Write-Output "Result 1:"
Write-Output $result1

Write-Output "Result 2:"
Write-Output $result2
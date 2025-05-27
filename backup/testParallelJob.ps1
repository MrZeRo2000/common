# Start background jobs
$job1 = Start-Job -ScriptBlock {
    # Define the function within the job
    function Get-Data {
        param (
            [string]$Input
        )
        try {
            # Simulate some work and potential error
            if ($Input -eq "Error") {
                throw "An error occurred with input: $Input"
            }

            # Return a hashtable
            return @{
                Input = $Input
                Length = $Input.Length
                Timestamp = (Get-Date).ToString()
            }
        }
        catch {
            # Capture the error and return it in the hashtable
            return @{
                Error = $_.Exception.Message
                Input = $Input
                Timestamp = (Get-Date).ToString()
            }
        }
    }

    # Call the function
    Get-Data -Input "Hello"
}

$job2 = Start-Job -ScriptBlock {
    # Define the function within the job
    function Get-Data {
        param (
            [string]$Input
        )
        try {
            # Simulate some work and potential error
            if ($Input -eq "Error") {
                throw "An error occurred with input: $Input"
            }

            # Return a hashtable
            return @{
                Input = $Input
                Length = $Input.Length
                Timestamp = (Get-Date).ToString()
            }
        }
        catch {
            # Capture the error and return it in the hashtable
            return @{
                Error = $_.Exception.Message
                Input = $Input
                Timestamp = (Get-Date).ToString()
            }
        }
    }

    # Call the function
    Get-Data -Input "Error"
}

# Wait for jobs to complete and collect results
$result1 = Receive-Job -Job $job1 -Wait
$result2 = Receive-Job -Job $job2 -Wait

# Remove jobs
Remove-Job -Job $job1, $job2

# Output the results
Write-Output "Result 1:"
Write-Output $result1

Write-Output "Result 2:"
Write-Output $result2
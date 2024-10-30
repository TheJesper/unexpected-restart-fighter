# Save as `unexpected-restart-fighter.ps1`

# Spinner function to show progress
function Show-Spinner {
    param (
        [string]$Message = "Processing"
    )
    $spinnerChars = @('|', '/', '-', '\')
    $i = 0
    $script:spinnerJob = Start-Job -ScriptBlock {
        param ($Message, $spinnerChars)
        while ($true) {
            Write-Host -NoNewline "`r$Message $($spinnerChars[$i % $spinnerChars.Length])"
            Start-Sleep -Milliseconds 100
            $i++
        }
    } -ArgumentList $Message, $spinnerChars
}

# Stop the spinner once processing is complete
function Stop-Spinner {
    Stop-Job $script:spinnerJob -Force
    Remove-Job $script:spinnerJob
    Write-Host "`rProcessing complete!`n" -ForegroundColor Green
}

# Define the time range (last 20 days)
$timeLimit = (Get-Date).AddDays(-20)

# Start spinner
Show-Spinner -Message "Analyzing shutdown events..."

# Get all shutdown/restart events (41, 1074, 6008) within the time range
$shutdownEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    Id = @(41, 1074, 6008)
    StartTime = $timeLimit
} | Sort-Object TimeCreated

# Stop spinner once events are fetched
Stop-Spinner

# Initialize output for summary and detailed investigation
$output = ""
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$logPath = Join-Path -Path $scriptDirectory -ChildPath "DetailedShutdownAnalysis.txt"

# Start analyzing each shutdown event
Show-Spinner -Message "Analyzing shutdown causes..."

foreach ($event in $shutdownEvents) {
    $output += "Time: $($event.TimeCreated)`n"
    $output += "Event ID: $($event.Id)`n"
    $output += "Description: $($event.Message)`n"
    $output += "Preceding Events:`n"

    # Capture events before each shutdown to analyze preceding errors or warnings
    $beforeShutdown = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        Level = @(1, 2, 3) # Error, Warning, Critical levels
        StartTime = $timeLimit
        EndTime = $event.TimeCreated.AddMinutes(-1)
    } | Sort-Object TimeCreated -Descending | Select-Object -First 5

    foreach ($precedingEvent in $beforeShutdown) {
        $output += "  - Time: $($precedingEvent.TimeCreated), Event ID: $($precedingEvent.Id), Description: $($precedingEvent.Message)`n"
    }
    $output += "`n"
}

# Stop spinner after analysis
Stop-Spinner

# Display summary on screen
Write-Host "Shutdown/Restart Events in the Last 20 Days" -ForegroundColor Cyan
Write-Host $output

# Save detailed log to the same directory
$output | Out-File -FilePath $logPath -Encoding UTF8
Write-Host "Detailed restart logs saved to $logPath" -ForegroundColor Blue

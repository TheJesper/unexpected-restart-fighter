# unexpected-restart-fighter.ps1

# Parameter block for verbose and help options
param (
    [switch]$Verbose,
    [switch]$Help
)

# Define log file paths (relative to script folder)
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$logFile = Join-Path -Path $scriptDir -ChildPath "DetailedRestartLogs.txt"

# Check for help flag
if ($Help) {
    Write-Output "Usage: .\unexpected-restart-fighter.ps1 [-Verbose] [-Help]"
    Write-Output "-Verbose: Show detailed events before shutdown, including recent errors."
    Write-Output "-Help: Display this help message."
    exit
}

# Variables
$daysToCheck = 20
$timeWindowBeforeShutdown = -5 # in minutes

# Functions
function Write-Log {
    param (
        [string]$message
    )
    Add-Content -Path $logFile -Value $message
    Write-Output $message
}

# Initialize log
Write-Log "===== Unexpected Restart Fighter Log ====="
Write-Log "Run Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Log "Script Location: $logFile"

# Fetch recent shutdown/restart events (Event IDs: 41, 6008, 1001)
$shutdownEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    Id = @(41, 6008, 1001)
    StartTime = (Get-Date).AddDays(-$daysToCheck)
} -ErrorAction SilentlyContinue

if (-not $shutdownEvents) {
    Write-Log "No recent shutdown or crash events found in the last $daysToCheck days."
    exit
}

# Process each shutdown event
foreach ($event in $shutdownEvents) {
    $lastShutdownTime = $event.TimeCreated
    Write-Log "Event Time: $($event.TimeCreated) | Event ID: $($event.Id) | Message: $($event.Message)"

    # Only if -Verbose is set, check for critical error events 5 minutes before shutdown
    if ($Verbose) {
        $errorEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'System'
            Level = 2
            StartTime = $lastShutdownTime.AddMinutes($timeWindowBeforeShutdown)
            EndTime = $lastShutdownTime
        } -ErrorAction SilentlyContinue

        if ($errorEvents) {
            $errorSummary = @{}
            foreach ($error in $errorEvents) {
                $eventId = $error.Id
                if ($errorSummary.ContainsKey($eventId)) {
                    $errorSummary[$eventId]++
                } else {
                    $errorSummary[$eventId] = 1
                }
                Write-Log "Error Time: $($error.TimeCreated) | Event ID: $($error.Id) | Message: $($error.Message)"
            }

            # Summary of hardware errors
            if ($errorSummary.Count -gt 0) {
                Write-Log "`nHardware-Related Errors Summary (Last 5 Minutes Before Shutdown):"
                foreach ($errorType in $errorSummary.Keys) {
                    Write-Log "Event ID ${errorType}: $($errorSummary[$errorType]) occurrence(s)"
                }
            } else {
                Write-Log "`nNo hardware-related error events found in the last 5 minutes before shutdown."
            }
        } else {
            Write-Log "`nNo critical error events found in the last 5 minutes before shutdown."
        }
    }
}

Write-Log "`nDetailed log saved to $logFile"

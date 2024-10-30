# Writing the updated README content to a file so the user can download it.

readme_content = """

# Unexpected Restart Fighter

A PowerShell script designed to diagnose and log unexpected shutdowns, restarts, and crashes on Windows systems. This script tracks recent shutdown events and logs critical errors leading up to these events to help identify potential hardware or software issues.

## Features

- Tracks recent unexpected shutdown and restart events in the last 20 days.
- Identifies errors and critical issues leading up to the last few minutes before each shutdown event.
- Provides a summary of hardware-related errors for easier diagnosis.
- Optionally shows additional error details with the `-Verbose` flag.
- Simple `-Help` option for guidance on usage.

## Usage

### Running the Script

Run the script from PowerShell:

```powershell
.\unexpected-restart-fighter.ps1 [-Verbose] [-Help]
```

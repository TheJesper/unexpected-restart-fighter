# Unexpected Restart Fighter

This PowerShell script identifies and analyzes unexpected shutdowns or restarts on a Windows system. It captures recent shutdown events and reviews preceding system warnings or errors, helping to diagnose and resolve frequent restarts.

## Features

- Retrieves all shutdown and restart events within the last 20 days.
- Summarizes events with timestamps, descriptions, and event IDs.
- Analyzes preceding errors or warnings for potential causes.
- Exports a detailed log in the script's directory for further investigation.

## Usage

1. **Run the Script**

   - Double-click `run-unexpected-restart-fighter.bat` to execute the PowerShell script.
   - Alternatively, run the PowerShell script directly:

     ```powershell
     .\unexpected-restart-fighter.ps1
     ```

2. **View Output**
   - The script displays a structured summary on the screen.
   - A detailed XML log file, `DetailedShutdownAnalysis.xml`, is saved in the same directory as the script.

## Requirements

- PowerShell
- Administrator privileges for access to event logs

## Sample Output

```plaintext
Shutdown/Restart Events in the Last 20 Days
Time: 10/30/2024 22:12:44
Event ID: 41
Description: The system has rebooted without cleanly shutting down first...
Preceding Events:
  - Time: 10/30/2024 22:12:30, Event ID: 6008, Description: The previous system shutdown was unexpected...
```

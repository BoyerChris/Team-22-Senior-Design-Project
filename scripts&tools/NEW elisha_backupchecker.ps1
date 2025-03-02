# Elisha Backup Checker Tool

# Make sure to run as admin
$AdminCheck = [System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $AdminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    exit
}

# Check the backup status of Windows File History
Write-Host "Checking File History Backup..." -ForegroundColor Cyan
$FileHistoryStatus = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\FileHistory" -ErrorAction SilentlyContinue
if ($FileHistoryStatus -and $FileHistoryStatus.ServiceStatus -eq 1) {
    Write-Host "File History Backup is ENABLED." -ForegroundColor Green
    $FileHistoryEnabled = "Enabled"

    # IF File History then it checks for te last backup date and prints it 
    $BackupLogPath = "C:\Users\$env:UserName\AppData\Local\Microsoft\Windows\FileHistory\Configuration\Config1.xml"
    if (Test-Path $BackupLogPath) {
        $BackupLog = [xml](Get-Content $BackupLogPath)
        $LastBackupDate = $BackupLog.Configuration.LastBackupTime
        if ($LastBackupDate) {
            Write-Host "Last Backup Date: $LastBackupDate" -ForegroundColor Green
        } else {
            Write-Host "No backup date found. Backups may not have been performed yet." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Backup log not found. No backup records available." -ForegroundColor Yellow
    }

} else {
    Write-Host "File History Backup is DISABLED." -ForegroundColor Red
    $FileHistoryEnabled = "Disabled"
}

# Check the System Restore status
Write-Host "`nChecking System Restore Status..." -ForegroundColor Cyan
$RestoreStatus = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
if ($RestoreStatus) {
    Write-Host "System Restore is ENABLED. Restore points are available." -ForegroundColor Green
    $SystemRestoreEnabled = "Enabled"
} else {
    Write-Host "System Restore is DISABLED. No restore points found." -ForegroundColor Red
    $SystemRestoreEnabled = "Disabled"
}

# Creates a file on your C drive if it hasn't already been made, then saves the results to a report
$ReportPath = "C:\BackupCheck\BackupStatusReport.txt"
if (!(Test-Path "C:\BackupCheck")) { New-Item -ItemType Directory -Path "C:\BackupCheck" | Out-Null }

@"
===== Backup Checker Report =====
File History Backup: $FileHistoryEnabled
Last Backup Date: $(if ($LastBackupDate) { $LastBackupDate } else { "No Backup Recorded" })
System Restore: $SystemRestoreEnabled
=================================
"@ | Out-File -FilePath $ReportPath

Write-Host "`nReport saved to: $ReportPath" -ForegroundColor Yellow
Write-Host "Consider enabling backups if they are disabled!" -ForegroundColor Magenta

pause

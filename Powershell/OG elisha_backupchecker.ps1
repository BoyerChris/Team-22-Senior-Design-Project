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
System Restore: $SystemRestoreEnabled
=================================
"@ | Out-File -FilePath $ReportPath

Write-Host "`nReport saved to: $ReportPath" -ForegroundColor Yellow
# potentially can make this an if statement if we would like to do that
Write-Host "Consider enabling backups if they are disabled!" -ForegroundColor Magenta

pause

# Elisha Update/Patch Checking Tool

# Has to be run as admin
$AdminCheck = [System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $AdminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    exit
}

# Checks for updates by using windows built-in update features
Write-Host "Checking for updates, please wait..." -ForegroundColor Cyan
$Updates = (New-Object -ComObject Microsoft.Update.Searcher).Search("IsInstalled=0").Updates

# If no required updates are detected print this
if ($Updates.Count -eq 0) {
    Write-Host "Your system is fully updated! No missing updates found." -ForegroundColor Green
    exit
}

# Categories for updates, currently just windows and third party, but able to expand later if necessary.
$WindowsUpdates = @($Updates | Where-Object { $_.Title -match "Cumulative Update|Security Update|Windows" })
$ThirdPartyPatches = @($Updates | Where-Object { $_.Title -notmatch "Cumulative Update|Security Update|Windows" })

# Display Necessary Update Counts 
Write-Host "`n!!!! Missing Windows Updates Detected !!!!`n" -ForegroundColor Yellow
Write-Host "Total Missing Updates: $($Updates.Count)" -ForegroundColor Cyan
Write-Host "Windows Updates: $($WindowsUpdates.Count)" -ForegroundColor Green
Write-Host "Third-Party Patches: $($ThirdPartyPatches.Count)" -ForegroundColor Magenta

# Display Windows Updates
if ($WindowsUpdates.Count -gt 0) {
    Write-Host "`n[WINDOWS UPDATES]" -ForegroundColor Green
    foreach ($update in $WindowsUpdates) {
        Write-Host "- $($update.Title)" -ForegroundColor White
    }
}

# Display Third-Party Patches/Updates
if ($ThirdPartyPatches.Count -gt 0) {
    Write-Host "`n[THIRD-PARTY PATCHES]" -ForegroundColor Magenta
    foreach ($update in $ThirdPartyPatches) {
        Write-Host "- $($update.Title)" -ForegroundColor White
    }
}

# Creates folder if it isn't already present and exports a report to a CSV file 
$ReportPath = "C:\PatchCheck\MissingUpdatesReport.csv"
if (!(Test-Path "C:\PatchCheck")) { New-Item -ItemType Directory -Path "C:\PatchCheck" | Out-Null }
$ReportData = @()
$WindowsUpdates | ForEach-Object { $ReportData += [PSCustomObject]@{ Type="Windows Update"; Title=$_.Title } }
$ThirdPartyPatches | ForEach-Object { $ReportData += [PSCustomObject]@{ Type="Third-Party Patch"; Title=$_.Title } }
$ReportData | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host "`nReport saved to $ReportPath" -ForegroundColor Green
Write-Host "Consider installing critical updates immediately!" -ForegroundColor Yellow

pause

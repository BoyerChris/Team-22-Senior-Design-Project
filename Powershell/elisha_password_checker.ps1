# Elisha Password Checker - Enhanced Version

# Get Local Security Policy Values
$PasswordPolicies = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
$AccountPolicies = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$LsaPolicies = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

# Extract Values
$MinPasswordLength = $LsaPolicies.MinimumPasswordLength
$MaxPasswordAge = $PasswordPolicies.MaximumPasswordAge
$PasswordComplexity = $PasswordPolicies.PasswordComplexity
$LockoutThreshold = $AccountPolicies.LockoutBadCount
$MaxPasswordLength = $LsaPolicies.MaximumPasswordLength  # This value is hypothetical; some systems may not have it.

# Default Fallbacks
if (-not $MinPasswordLength) { $MinPasswordLength = 0 }
if (-not $PasswordComplexity) { $PasswordComplexity = 0 }
if (-not $LockoutThreshold) { $LockoutThreshold = "Not Set" }
if (-not $MaxPasswordLength) { $MaxPasswordLength = "Not Defined" }

# Convert to Readable Values
$PasswordComplexity = if ($PasswordComplexity -eq 1) { "Enabled" } else { "Disabled" }
$MaxPasswordAge = if ($MaxPasswordAge -eq 0) { "Unlimited" } else { "$MaxPasswordAge days" }

# Display the Results
Write-Host "Checking Local Password Policy" -ForegroundColor Cyan
Write-Host "--------------------------------"
Write-Host "Minimum Password Length: $MinPasswordLength"
Write-Host "Maximum Password Length: $MaxPasswordLength"
Write-Host "Password Complexity: $PasswordComplexity"
Write-Host "Maximum Password Age: $MaxPasswordAge"
Write-Host "Account Lockout Threshold: $LockoutThreshold"
Write-Host "--------------------------------"

# Warnings and Recommendations
if ([int]$MinPasswordLength -lt 8) {
    Write-Host "Warning: Minimum password length is weak! Consider increasing it to at least 8 characters." -ForegroundColor Yellow
} else {
    Write-Host "Minimum password length is secure." -ForegroundColor Green
}

if ($PasswordComplexity -eq "Disabled") {
    Write-Host "Warning: Password complexity is disabled! Enable it to require a mix of characters." -ForegroundColor Yellow
} else {
    Write-Host "Password complexity is enabled." -ForegroundColor Green
}

if ($MaxPasswordAge -eq "Unlimited") {
    Write-Host "Warning: Maximum password age is unlimited! Set an expiration period to enforce password changes." -ForegroundColor Yellow
} else {
    Write-Host "Maximum password age is set to $MaxPasswordAge." -ForegroundColor Green
}

if ($LockoutThreshold -eq "Not Set") {
    Write-Host "Warning: Account lockout threshold is not set! Configure it to prevent brute force attacks." -ForegroundColor Yellow
} else {
    Write-Host "Account lockout threshold is set to $LockoutThreshold attempts." -ForegroundColor Green
}

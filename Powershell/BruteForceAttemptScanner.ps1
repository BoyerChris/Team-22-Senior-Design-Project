# Get active network connections
$ActiveConnections = Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' } | 
    Select-Object LocalAddress, RemoteAddress, RemotePort

# Get failed login attempts (Last 30 minutes)
$TimeFrame = (Get-Date).AddMinutes(-30)
$FailedLogins = Get-WinEvent -LogName Security -MaxEvents 1000 | 
    Where-Object { $_.Id -eq 4625 -and $_.TimeCreated -ge $TimeFrame }

# Count failed login attempts per user
$FailedCounts = @{ }
foreach ($event in $FailedLogins) {
    # Attempt to extract the username (check different indices if necessary)
    $User = $event.Properties[5].Value  # Attempt to extract username from index 5

    # Handle cases where the username is missing or invalid
    if (-not $User) {
        $User = "Unknown User"  # Use a more descriptive fallback
    }

    # Handle "guest" account (common in some failed login attempts)
    if ($User -eq "guest") {
        $User = "Guest Account"  # Use a more readable label for guest
    }

    # Count failed attempts per user
    if ($FailedCounts.ContainsKey($User)) {
        $FailedCounts[$User] += 1
    } else {
        $FailedCounts[$User] = 1
    }
}

# Detect suspicious IPs from active sessions
$SuspiciousIPs = @{ }
foreach ($conn in $ActiveConnections) {
    $IP = $conn.RemoteAddress
    if ($IP -and $IP -ne "0.0.0.0" -and $IP -ne "::") {  # Ignore local addresses
        if ($SuspiciousIPs.ContainsKey($IP)) {
            $SuspiciousIPs[$IP] += 1
        } else {
            $SuspiciousIPs[$IP] = 1
        }
    }
}

# Display Results
Write-Output "===== Failed Login Attempts in Last 30 Minutes ====="
foreach ($user in $FailedCounts.Keys) {
    Write-Output "User: $user | Failed Attempts: $($FailedCounts[$user])"
}

Write-Output "`n===== Active Network Connections (Possible Attackers) ====="
foreach ($ip in $SuspiciousIPs.Keys) {
    Write-Output "IP: $ip | Connection Count: $($SuspiciousIPs[$ip])"
}

# Highlight potential brute-force attacks
Write-Output "`n===== Potential Brute Force Detected ====="
foreach ($ip in $SuspiciousIPs.Keys) {
    if ($SuspiciousIPs[$ip] -ge 5) {  # Threshold for multiple connections
        Write-Output "WARNING: Possible attack from $ip (Connections: $($SuspiciousIPs[$ip]))"
    }
}

# Define file paths for CSV export
$FailedLoginsFile = "C:\ScriptTest\FailedLogins.csv"
$SuspiciousIPsFile = "C:\ScriptTest\SuspiciousIPs.csv"

# Export Failed Login Attempts to CSV
$FailedLoginsExport = $FailedCounts.GetEnumerator() | 
    Select-Object @{Name="User"; Expression={$_.Key}}, @{Name="Failed Attempts"; Expression={$_.Value}}
$FailedLoginsExport | Export-Csv -Path $FailedLoginsFile -NoTypeInformation

# Export Suspicious IPs to CSV
$SuspiciousIPsExport = $SuspiciousIPs.GetEnumerator() | 
    Select-Object @{Name="IP"; Expression={$_.Key}}, @{Name="Connection Count"; Expression={$_.Value}}
$SuspiciousIPsExport | Export-Csv -Path $SuspiciousIPsFile -NoTypeInformation

Write-Output "Exported Failed Login Attempts and Suspicious IPs to CSV files."

pause


# Initialize an array to store the results
$results = @()

# Check if Remote Desktop is enabled
$rdpStatus = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections"
$rdpStatusResult = if ($rdpStatus.fDenyTSConnections -eq 0) {
    "Remote Desktop is enabled. Consider disabling if not required."
} else {
    "Remote Desktop is disabled."
}
# Add to results
$results += [PSCustomObject]@{
    Check      = "Remote Desktop Status"
    Status     = $rdpStatusResult
    User       = ""
    LastSet    = ""
    RuleName   = ""
    Direction  = ""
    Action     = ""
}

# Check password policy settings
$passwordPolicy = Get-LocalUser | Select-Object -Property Name, PasswordLastSet
foreach ($user in $passwordPolicy) {
    $results += [PSCustomObject]@{
        Check      = "Password Policy"
        Status     = ""
        User       = $user.Name
        LastSet    = $user.PasswordLastSet
        RuleName   = ""
        Direction  = ""
        Action     = ""
    }
}

# Check firewall rules
$firewallRules = Get-NetFirewallRule | Where-Object { $_.Enabled -eq "True" } | Select-Object DisplayName, Direction, Action
foreach ($rule in $firewallRules) {
    $results += [PSCustomObject]@{
        Check      = "Firewall Rule"
        Status     = ""
        User       = ""
        LastSet    = ""
        RuleName   = $rule.DisplayName
        Direction  = $rule.Direction
        Action     = $rule.Action
    }
}

# Export results to CSV
$results | Export-Csv -Path "C:\ScriptTest\SecurityCheckResults.csv" -NoTypeInformation

Write-Output "Results have been exported to C:\ScriptTest\SecurityCheckResults.csv"
pause
param (
    [string]$TargetIP,
    [int[]]$Ports = @(21, 22, 23, 25, 53, 80, 110, 139, 143, 443, 445, 3306, 3389)
)

if (-not $TargetIP) {
    Write-Host "Usage: .\elisha_openport_scanner.ps1 -TargetIP <IP Address>"
    exit
}

Write-Host "Scanning Target: $TargetIP"
Write-Host "------------------------------"

foreach ($Port in $Ports) {
    try {
        $connection = New-Object System.Net.Sockets.TCPClient($TargetIP, $Port)
        if ($connection.Connected) {
            Write-Host "Port $Port is open"
            $connection.Close()
        }
    } catch {
        Write-Host "Port $Port is closed"
    }
}

Write-Host "Scan complete."
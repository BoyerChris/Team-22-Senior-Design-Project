function Get-NetworkAdapterSecurityReport 
{
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
    
    foreach ($adapter in $adapters) 

    {
        # set the name to be returned
	$adapterName = $adapter.Name

	# get the DNS for each adapter
        $dnsServers = Get-DnsClientServerAddress -InterfaceAlias $adapterName | Select-Object -ExpandProperty ServerAddresses

	# get the NetBIOS Settings for each adapter
	$netbiosProperty = Get-NetAdapterAdvancedProperty -Name $adapterName -DisplayName "NetBIOS over TCP/IP" -ErrorAction SilentlyContinue
        $netbiosEnabled = if ($netbiosProperty) {
            $netbiosValue = $netbiosProperty.DisplayValue
            switch ($netbiosValue) {
                "Enabled" { 1 }
                "Disabled" { 0 }
                default { $null }
            }} else { $null }




	# Comparing DNS to known Public DNS servers, then notifying the user
        $publicDNS = $dnsServers | Where-Object { $_ -match "^(8\.8\.8\.8|8\.8\.4\.4|1\.1\.1\.1|9\.9\.9\.9)" }
        $dnsStatus = if ($publicDNS) { "Public DNS Used (Risky)" } else { "Internal DNS Used (Secure)" }

	# Checking to see if NetBIOS is enabled, then notifying the user
	$netbiosStatus = if ($netbiosEnabled -eq 1) { 'Enabled (Risky)' } elseif ($netbiosEnabled -eq 0) { 'Disabled (Secure)' } else { 'Not Available (Secure)' }




        # Return messaging per adapter
        Write-Host "Network Adapter Name: $adapterName" -ForegroundColor Blue
        Write-Host "DNS Status: $dnsStatus"
	Write-Host "NetBIOS: $netbiosStatus`n"
    }

}

Get-NetworkAdapterSecurityReport

Read-Host "Press Enter to exit"
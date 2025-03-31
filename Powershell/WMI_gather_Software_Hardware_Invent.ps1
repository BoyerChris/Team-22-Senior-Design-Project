# Using PowerShell scripting 

# Gathering hardware inventory
$hardwareInfo = Get-WmiObject -Class Win32_ComputerSystem
$cpuInfo = Get-WmiObject -Class Win32_Processor
$memoryInfo = Get-WmiObject -Class Win32_PhysicalMemory
# Gather software inventory
$softwareInfo = Get-WmiObject -Class Win32_Product

# Output hardware information
Write-Output "Hardware Information:"
Write-Output "----------------------"
Write-Output "Manufacturer: $($hardwareInfo.Manufacturer)"
Write-Output "Model: $($hardwareInfo.Model)"
Write-Output "Total Physical Memory: $([math]::round($hardwareInfo.TotalPhysicalMemory / 1GB, 2)) GB"
Write-Output "CPU: $($cpuInfo.Name)"
Write-Output "Number of Cores: $($cpuInfo.NumberOfCores)"
Write-Output "Number of Logical Processors: $($cpuInfo.NumberOfLogicalProcessors)"

# Output software information
Write-Output "`nSoftware Information:"
Write-Output "----------------------"
foreach ($software in $softwareInfo) {
    Write-Output "Name: $($software.Name)"
    Write-Output "Version: $($software.Version)"
    Write-Output "Vendor: $($software.Vendor)"
    Write-Output "Install Date: $($software.InstallDate)"
    Write-Output "----------------------"
}

# Save the information to a file
$hardwareInfo | Out-File -FilePath "C:\Inventory\HardwareInfo.txt"
$softwareInfo | Out-File -FilePath "C:\Inventory\SoftwareInfo.txt"


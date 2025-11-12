Write-Host "Retrieving Hardware Identifiers..." -ForegroundColor Yellow
Write-Host ""
# Get SMBIOS
Write-Host "===== SMBIOS Identifiers =====" -ForegroundColor Cyan

$su = (Get-CimInstance Win32_ComputerSystemProduct).UUID
Write-Host ("/SU (System UUID):      {0}" -f $su)

$ss = (Get-CimInstance Win32_BIOS).SerialNumber
Write-Host ("/SS (System Serial):    {0}" -f $ss)

$bs = (Get-CimInstance Win32_BaseBoard).SerialNumber
Write-Host ("/BS (Baseboard Serial): {0}" -f $bs)

# Get all physical fixed disks
Write-Host ""
Write-Host "===== Fixed Disk Serials =====" -ForegroundColor Cyan

$disks = Get-CimInstance Win32_DiskDrive | Where-Object { $_.MediaType -like "*Fixed*" -or $_.MediaType -eq $null }

foreach ($disk in $disks) {
    $serial = if ([string]::IsNullOrWhiteSpace($disk.SerialNumber)) { "<Null>" } else { $disk.SerialNumber.Trim() }
    Write-Host ("{0,-25} {1,-30} Serial: {2}" -f $disk.DeviceID, $disk.Model, $serial)
}

# Get all active physical MAC addresses
Write-Host ""
Write-Host "===== Active Network Adapters =====" -ForegroundColor Cyan

$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.HardwareInterface -eq $true }

foreach ($adapter in $adapters) {
    $mac = if ([string]::IsNullOrWhiteSpace($adapter.MacAddress)) { "<Null>" } else { $adapter.MacAddress }
    Write-Host ("{0,-25} {1,-35} MAC: {2}" -f $adapter.Name, $adapter.InterfaceDescription, $mac)
}
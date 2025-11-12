# Changes the last 24 bits of a MAC Address
function New-PartialMac {
    param([string]$baseMac)
    $clean = ($baseMac -replace '[^0-9A-Fa-f]', '')
    if ($clean.Length -lt 12) { throw "Invalid MAC: $baseMac" }

    # Keep first 3 bytes (6 hex chars)
    $prefix = $clean.Substring(0, 6)
    # Randomize last 3 bytes (6 hex chars)
    $rand = -join ((1..3) | ForEach-Object { "{0:X2}" -f (Get-Random -Minimum 0 -Maximum 256) })
    return "$prefix$rand"
}

# Find primary physical adapter
$adapter = Get-NetAdapter |
    Where-Object { $_.Status -eq 'Up' -and $_.HardwareInterface -eq $true } |
    Sort-Object -Property InterfaceMetric |
    Select-Object -First 1

if (-not $adapter) {
    Write-Host "❌ No active physical adapter found." -ForegroundColor Red
    exit 1
}

$currentMac = $adapter.MacAddress -replace '[^0-9A-Fa-f]', ''
$newMac = New-PartialMac $currentMac

Write-Host "Primary adapter: $($adapter.Name) [$($adapter.InterfaceDescription)]" -ForegroundColor Cyan
Write-Host "Current MAC: $currentMac" -ForegroundColor Yellow
Write-Host "New MAC: $newMac" -ForegroundColor Yellow

try {
    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "Network Address" -DisplayValue $newMac -ErrorAction Stop
    Write-Host "✅ MAC address set successfully via adapter property." -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to set MAC via adapter property: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Restart adapter to apply
Write-Host "Restarting adapter..."
Restart-NetAdapter -Name $adapter.Name -Confirm:$false
Start-Sleep 3

$newActiveMac = (Get-NetAdapter -Name $adapter.Name).MacAddress
Write-Host "New active MAC: $newActiveMac" -ForegroundColor Cyan

# Page Title
Write-Host "Monitors Detected on Computer"
Write-Host "==================================="

function Decode {
    If ($args[0] -is [System.Array]) {
        [System.Text.Encoding]::ASCII.GetString($args[0])
    }
    Else {
        "Not Found"
    }
}

$adapterTypes = @{
    '-2' = 'Unknown'
    '-1' = 'Unknown'
    '0' = 'VGA'
    '1' = 'S-Video'
    '2' = 'Composite'
    '3' = 'Component'
    '4' = 'DVI'
    '5' = 'HDMI'
    '6' = 'LVDS'
    '8' = 'D-Jpn'
    '9' = 'SDI'
    '10' = 'DisplayPort (external)'
    '11' = 'DisplayPort (internal)'
    '12' = 'Unified Display Interface'
    '13' = 'Unified Display Interface (embedded)'
    '14' = 'SDTV dongle'
    '15' = 'Miracast'
    '16' = 'Internal'
    '2147483648' = 'Internal'
}

$monitors = Get-WmiObject WmiMonitorID -Namespace root\wmi
$connections = Get-WmiObject WmiMonitorConnectionParams -Namespace root\wmi

$monitorTable = @()

foreach ($monitor in $monitors) {
    $manufacturer = Decode $monitor.ManufacturerName -notmatch 0
    $name = Decode $monitor.UserFriendlyName -notmatch 0
    $serial = Decode $monitor.SerialNumberID -notmatch 0
    $connectionType = ($connections | Where-Object { $_.InstanceName -eq $monitor.InstanceName }).VideoOutputTechnology
    $connectionType = $adapterTypes."$connectionType"

    # Check if the interface is "Internal"
    if ($connectionType -eq "Internal") {
        $name = "Internal"
        $serial = "N/A"
        $connectionType = "Internal Notebook Display"
    }

    if ($manufacturer -ne "Not Found" -or $name -ne "Not Found" -or $serial -ne "Not Found") {
        $monitorTable += @{
            Manufacturer = $manufacturer
            Model = $name
            "Serial Number" = $serial
            "Interface Connected" = $connectionType
        }
    }
}

# Sort the columns and output the table
$sortedColumns = $monitorTable | ForEach-Object {
    [PSCustomObject]@{
        Manufacturer = $_.Manufacturer
        Model = $_.Model
        "Serial Number" = $_."Serial Number"
        "Interface Connected" = $_."Interface Connected"
    }
} | Sort-Object Manufacturer

$sortedColumns | Format-Table -AutoSize

$maass = @()
$devices = Get-MobileDevice


Foreach ($device in $devices){
    $props = Get-MobileDeviceStatistics -Identity $device.Identity
    if ($props.DeviceUserAgent -like "*MaaS360*"){
        $maass += $props  
    }
}

$maass | Export-Csv "C:\temp\maasExport.csv"
$maass | Out-GridView
[string[]] $apps = Get-Content apps.txt

foreach($app in $apps){
    $package = Get-AppxPackage *$app* 
    IF ($package -eq $null){
        Write-host "No installed packages with $app"
        Continue
    }
    try {
        Remove-AppxPackage $package -ErrorAction Stop
        Write-Host "Successfully removed $package"
    }
    catch{Write-Host "Could not remove $($package)" -ForegroundColor Yellow}
}

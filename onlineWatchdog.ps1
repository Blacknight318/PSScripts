$Host.UI.RawUI.BackgroundColor = "Yellow"
$Host.UI.RawUI.ForegroundColor = "Black"
#$wshell = New-Object -ComObject Wscript.Shell
$machine = Read-Host -Prompt "What machine are we checking?"

while($true){
    Start-Sleep -Seconds 10
    $time = Get-Date -Format HH:mm:ss
    try {
        $online = Test-Connection $machine -Count 1 -ErrorAction Stop -Quiet
    }
    catch{
    }
    #$online
    if($online -eq $False){
        #$wshell.Popup("$machine went down at $time",0,"Outage",0x0)
        $Host.UI.RawUI.BackgroundColor = "Red"
        Write-Host $machine "down as of " $time 
    }   
    else {
        $Host.UI.RawUI.BackgroundColor = "Green"
        Write-Host $machine "up as of " $time      
    }
}
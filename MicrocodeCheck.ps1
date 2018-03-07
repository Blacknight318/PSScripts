#CPUID's affected from https://support.microsoft.com/en-us/help/4090007/intel-microcode-updates
$UpdateID = @("506E3", "406E3")

#Pulls OS Version
$osver = (Get-CimInstance Win32_OperatingSystem).Version
if($osver -eq "10.0.16299"){
    $oschk = "True"
    $oschkColor = "Green"
}
else {
    $oschk = "False"
    $oschkColor = "Red"
}

#Pulls Processor ID and slicing for compare
$ProcID = Get-WmiObject win32_Processor -Property ProcessorID | Select-Object -Property ProcessorID
$prod = $ProcID.ProcessorID
$ipid = $prod.Substring($prod.Length -5)
if($UpdateID -contains $ipid){
    $cpuchk = "True"
    $cpuchkColor = "Green"
}
else {
    $cpuchk = "False"
    $cpuchkColor = "Red"
}

#Value compare to see if system is ready to receive
if($oschk -eq "True" -and $cpuchk -eq "True"){
    $upgrade = "True"
    $upgradeColor = "Green"
}
else {
    $upgrade = "False"
    $upgradeColor = "Red"
}

#Lets see our results
Write-Host("Is Windows compatible with KB4090007: ") -NoNewline -ForegroundColor White
Write-Host($oschk) -ForegroundColor $oschkColor
Write-Host("Is CPU Compatible with KB4090007: ") -NoNewline -ForegroundColor White
Write-Host($cpuchk) -ForegroundColor $cpuchkColor
Write-Host("Is this machine recommended to install KB4090007: ") -NoNewline -ForegroundColor White
Write-Host($upgrade) -ForegroundColor $upgradeColor


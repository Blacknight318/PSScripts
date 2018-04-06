#Last Updated/Verified April 6th, 2018
#CPUID's affected from https://support.microsoft.com/en-us/help/4090007/intel-microcode-updates
$UpdateID = @("506E3", "406E3", "50654", "806E9", "806EA", "906E9", "906EA", "906EB")

#Pulls OS Version
$osver = (Get-CimInstance Win32_OperatingSystem).Version
if($osver -eq "10.0.16299"){
    $oschk = "Yes"
    $oschkColor = "Green"
}
else {
    $oschk = "No"
    $oschkColor = "Red"
}

#Pulls Processor ID and slicing for compare
$ProcID = Get-WmiObject win32_Processor -Property ProcessorID | Select-Object -Property ProcessorID
$prod = $ProcID.ProcessorID
$ipid = $prod.Substring($prod.Length -5)
if($UpdateID -contains $ipid){
    $cpuchk = "Yes"
    $cpuchkColor = "Green"
}
else {
    $cpuchk = "No"
    $cpuchkColor = "Red"
}

#Check for presence of KB4090007
$patch = Get-HotFix KB4090007 -ErrorAction SilentlyContinue
if($patch -ne $null){
    $patchStat = "Yes"
    $patchStatColor = "Green"
}
else {
    $patchStat = "No"
    $patchStatColor = "Red"
}

#Lets see our results
Write-Host("Is Windows compatible with KB4090007:    ") -NoNewline -ForegroundColor Yellow
Write-Host($oschk) -ForegroundColor $oschkColor
Write-Host("Is CPU Compatible with KB4090007:        ") -NoNewline -ForegroundColor Yellow
Write-Host($cpuchk) -ForegroundColor $cpuchkColor
Write-Host("Is this machine has KB4090007 installed: ") -NoNewline -ForegroundColor Yellow
Write-Host($patchStat) -ForegroundColor $patchStatColor


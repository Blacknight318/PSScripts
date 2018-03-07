#CPUID's affected from https://support.microsoft.com/en-us/help/4090007/intel-microcode-updates
$UpdateID = @("506E3", "406E3")

#Pulling the CPUID and slicing to match expected value from above site
$ProcID = Get-WmiObject win32_Processor -Property ProcessorID | Select-Object -Property ProcessorID
$prod = $ProcID.ProcessorID
$ipid = $prod.Substring($prod.Length -5)

#Time to check the list
if($UpdateID -contains $ipid){
    Write-Host("This machine has a microcode update available! `n Please visit https://support.microsoft.com/en-us/help/4090007/intel-microcode-updates and download the appropriate updates!")
}
else {
    Write-Host("There are currently no microcode updates available through Microsoft.")
}
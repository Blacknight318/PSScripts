#REF: https://support.microsoft.com/en-us/help/4487266/activation-failures-and-not-genuine-notifications-on-vl-win-7-kms-clie
#This is an early version of the script for immediate use in my current role and has not yet been tested

#Check for problem update
$check = Get-HotFix -Id KB971033

#If Remove offending update if installed
if($check.length -gt 0){
    Start-Process -FilePath dism.exe -ArgumentList '/online /Remove-Package /PackageName:Microsoft-Windows-Security-WindowsActivationTechnologies-Package~31bf3856ad364e35~amd64~~7.1.7600.16395'
    Get-Process -Name dism | Wait-Process
}

#Stopping necessary services
Stop-Service -Name sppuinotify
Set-Service -Name sppuinotify -StartupType Disabled
Stop-Service -Name sppsvc

#Cleanup KMS cache
Remove-Item C:\Windows\system32\7B296FB0-376B-497e-B012-9C450E1B7327-5P-0.C7483456-A289-439d-8115-601632D005A0 -Force
Remove-Item C:\Windows\system32\7B296FB0-376B-497e-B012-9C450E1B7327-5P-1.C7483456-A289-439d-8115-601632D005A0 -Force
Remove-Item C:\Windows\\ServiceProfiles\NetworkService\AppData\Roaming\Microsoft\SoftwareProtectionPlatform\tokens.dat -Force
Remove-Item C:\Windows\\ServiceProfiles\NetworkService\AppData\Roaming\Microsoft\SoftwareProtectionPlatform\cache\cache.dat -Force

#Starting back up the Software Protectio(sppsvc)
Start-Service -Name sppsvc

#Run cscripts to reregister as Windows 7 Enterprise
Start-Process -FilePath cscript.exe -ArgumentList 'C:\Windows\system32\slmgr.vbs /ipk 33PXH-7Y6KF-2VJC9-XBBR8-HVTHH'
Get-Process -Name cscript | Wait-Process
Start-Process -FilePath cscript.exe -ArgumentList 'C:\windows\system32\slmgr.vbs /ato'
Get-Process -Name cscript | Wait-Process

#Set sppuinotify service back to on demand
Set-Service -Name sppuinotify -StartupType Manual

Write-Host 'Registration complete, computer will reboot in 1 minute!!'
Start-Sleep -Seconds 60
Start-Process shutdown.exe -ArgumentList 'r'

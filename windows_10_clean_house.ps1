#This is a general house cleaning of "bloat-ware", for those that remember the term, from Windows 10
#***This is recomended for fresh installs or buils ONLY***

Get-AppxPackage * | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

#Now to reinstall the Windows Store
Get-AppXPackage *WindowsStore* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

#WIP for full disk cleanup

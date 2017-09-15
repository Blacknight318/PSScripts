//Find Mailbox Infor
Get-mailbox | get-mailboxstatistics | sort-object totalitemsize –descending | ft displayname,totalitemsize | Out-file c:\temp\mailbox_size.txt

//Pull chkdsk results for logs
Get-EventLog -LogName Application -Source wininit | Select-Object -Last 1 -ExpandProperty message

//Event Log Search
Get-EventLog -LogName Application | Where-Object {$_.source -eq "Microsoft-Windows-User Prifles Service"} | Out-Gridview

//Remove IE 11 with CLI
FORFILES /P %WINDIR%\servicing\Packages /M Microsoft-Windows-InternetExplorer-*11.*.mum /c "cmd /c echo Uninstalling package @fname && start /w pkgmgr /up:@fname /quiet /norestart"

//Search for expired certificates
Get-ChildItem -Recurse cert:\ | where {$_.notafter -le (get-date)} | select subject, issuer, notafter | out-gridview

//Disable multiple AD Accounts
echo test1 test2 test3 | Disable-ADAccount -PassThru

//Search security logs for lockouts
Get-WinEvent -FilterHashtable @{LogName='Security';id=4771;data='username'} | select -expand message

//Find in Exchange what a user has access to
Get-Mailbox | Get-MailboxPermission -User username | Out-Gridview

//Get Mobile devices attached to Exchange account
 Get-MobileDevice -Mailbox user@example | Select-Object -Property Name, DeviceOS DeviceAccessState

//Search remote logs ***Must use Admin shell***
Get-EventLog -ComputerName computer -LogName Log -After $after | where {$_.EventID -eq 6008} | Select-Object TimeGenerated, Source, EntryType, Message | Format-Table -Autosize -Wrap
 
//Search for specific software
Get-WmiObject -ComputerName optional -Class win32_Product | where {$_.Vendor -like '*vendor name*'} | Select-Object -Property Name, Version

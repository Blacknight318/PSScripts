function Get-Lockout(){
    #Polling DC's for lockouts

    <#
    .Synopsis
        List Active Directory lockouts
    .Description
        This will pull a list of domain controllers and poll them for lockouts for the specified user.
    .Inputs
        Active Directory Username
    .Outputs
        List of servers, number of failed attempts, and lockout time. This also spits out an object for further use.
    .Link
        https://github.com/Blacknight318/PSScripts/blob/master/ADLockoutModule.ps1
    #>

    [CmdletBinding()]
    param(    
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$User
    )
    $start = Get-Date
    $DomainControllers = Get-ADDomainController -Filter *
    $unlock = {
        Param(
            $userName,
            $serverName)
        
        $runup = Get-Date
        $lockup = Get-ADUser -Identity $userName -Server $serverName -Properties LockedOut,BadlogonCount,AccountLockoutTime -ErrorAction Stop
        $rundown = Get-Date
        $runTime = New-TimeSpan -Start $runup -End $rundown

        $writeItem = New-Object System.Object
                $writeItem | Add-Member NoteProperty -Name "Domain Controller" -Value $serverName
                $writeItem | Add-Member NoteProperty -Name "Bad Attempts" -Value $lockup.BadLogonCount
                $writeItem | Add-Member NoteProperty -Name "Lockout time" -Value $lockup.AccountLockoutTime
                $writeItem | Add-Member NoteProperty -Name "Locked Out" -Value $lockup.LockedOut
                $writeItem | Add-Member NoteProperty -Name "TTR" -Value $runTime
        $writeItem | Export-Csv -Append -Path "C:\temp\pslock.csv"
    }
    
    try {
        [string[]] $blist = Get-Content blistdc.txt -ErrorAction Stop
    }
    catch {}

    foreach ($DC in $DomainControllers){
        IF ($blist -contains $DC.Name) {break} #Blacklist for readonly or  a DR DC
        $Server = $DC.Name
        Start-Job -ScriptBlock $unlock -ArgumentList @($User,$Server) | Out-Null
    }
    Get-Job | Wait-Job | Out-Null

    $lockOuts = Import-Csv -Path "C:\temp\pslock.csv" 
    #$lockOuts | Out-GridView
    $lockOuts | Format-Table
    $end = Get-Date
    $runtime = New-TimeSpan -Start $start -End $end
    Write-Host $runtime
    Get-Job | Remove-Job
    Remove-Item -Path "C:\temp\pslock.csv"
}

Function Clear-Lockout{
    <#
    .Synopsis
        Clear Lockouts
    .Description
        Clear lockouts for a given user on all supplied Domain Controllers
    .Inputs
        Active Directory Username(required) and Domain Controllers(optional, if none supplied all available Domain Controllers will be cleared)
    .Outputs
        Servers where lockouts were cleared
    .Link
        https://github.com/Blacknight318/PSScripts/blob/master/ADLockoutModule.ps1
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$User,

        [Parameter(Mandatory=$false)]
        [string[]]$Servers
    )
    
    $creds = Get-Credential
    $start = Get-Date

    $unlock = {
        Param(
            $userName,
            $serverName,
            $creds)
        
        $runup = Get-Date
        Unlock-ADAccount -Identity $userName -Server $serverName -Credential $creds
        $rundown = Get-Date
        $runtime = New-TimeSpan -Start $runup -End $rundown
        $writeItem = New-Object System.Object
                $writeItem | Add-Member NoteProperty -Name "Domain Controller" -Value $serverName
                $writeItem | Add-Member NoteProperty -Name "TTR" -Value $runtime
        $writeItem | Export-Csv -Append -Path "C:\temp\clearedLocks.csv"
    }

    if($Servers -eq $null){
        $Servers = Get-ADDomainController -Filter *
    }
    foreach($Server in $Servers){
        Start-Job -ScriptBlock $unlock -ArgumentList @($User, $Server, $creds) | Out-Null
        #Write-Host $Server " unlocked"
    }

    Get-Job | Wait-Job | Out-Null
    $end = Get-Date
    $runTime = New-TimeSpan -Start $start -End $end
    
    $cleared = Import-Csv -Path "C:\temp\clearedLocks.csv" 
    $cleared | Format-Table
    Write-Host $runTime
    #Invoke-Command -ComputerName $Servers -Credential $creds {Unlock-ADAccount -Identity $User -Credential $creds}
    Get-Job | Remove-Job
    Remove-Item -Path "C:\temp\clearedLocks.csv"
}
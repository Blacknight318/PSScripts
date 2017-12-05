function Get-Lockouts(){
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

    $DomainControllers = Get-ADDomainController -Filter *
    $prop = @('LockedOut', 'AccountLockoutTime', 'BadLogonCount', 'LastBadPasswordAttempt', 'LastLogonDate', 'msDS-UserPasswordExpiryTimeComputed')
    $listBad = @()
    $servs = @()
    try {
        [string[]] $blist = Get-Content blistdc.txt -ErrorAction Stop
    }
    catch {}
    
    foreach($DC in $DomainControllers) #The purpose of this section is to give detailed lockout information
    {
        IF ($blist -contains $DC.Name) {Continue} #Blacklist for readonly or  a DR DC
        try{
            $locked = Get-ADUser -Identity $user -Server $DC -Properties LockedOut -ErrorAction Stop
        }
        catch { Write-Host $DC.Name "Failed to read, consider adding to blacklist!" -foregroundcolor red }
        if($locked.LockedOut -eq "True"){
            $deets = Get-ADUser -Identity $user -Server $DC -Properties $prop
            $writeItem = New-Object System.Object
                $writeItem | Add-Member NoteProperty -Name "Domain Controller" -Value $DC.Name
                $writeItem | Add-Member NoteProperty -Name "Bad Attempts" -Value $deets.BadLogonCount
                $writeItem | Add-Member NoteProperty -Name "Lockout time" -Value $deets.AccountLockoutTime
            $listBad += $writeItem
            $servs += $DC.Name
         }
    }
    $listBad
    if($servs.length -eq 0){break}
    $clearLocks = Read-Host -Prompt "Press enter to unlock, press Ctrl+C to exit"

    if($clearLocks -eq ""){
        Clear-Lockouts -User $User -Servers $servs
    }
}

Function Clear-Lockouts{
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

    if($Servers -eq ""){
        $Servers = Get-ADDomainController -Filter *
    }
    IF ($blist -contains $Servers.Name) {Continue}
    foreach($Server in $Servers){
        Unlock-ADAccount -Identity $User -Server $Server -Credential $creds
        Write-Host $Server " unlocked"
    }
    #Invoke-Command -ComputerName $Servers -Credential $creds {Unlock-ADAccount -Identity $User -Credential $creds}
}
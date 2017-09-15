$task = "start"
$time = Get-Date -Format HH:mm:ss
$start = $time
# $write = @()

While ($task -ne "") {
    $runningTask = $task
    $task = Read-Host -Prompt "Current task description"
    
    $time = Get-Date -Format HH:mm:ss
    $timeDiff = New-TimeSpan $start $time

    $writeItem = New-Object System.Object
       $writeItem | Add-Member NoteProperty -Name "Description" -Value $runningTask
       #$writeItem | Add-Member NoteProperty -Name "Description" -Value $task
       #$writeItem | Add-Member NoteProperty -Name "Start Time" -Value $start
       $writeItem | Add-Member NoteProperty -Name "Time Stamp" -Value $time
       $writeItem | Add-Member NoteProperty -Name "Duration" -Value $timeDiff
    $writeItem | Export-Csv -NoTypeInformation -Append -Path "track_$((Get-Date).ToString('MM-dd-yy')).csv"

    #$task = Read-Host -Prompt "Current task description"
    $start = $time 
}

$grids = Import-Csv -Path "track_$((Get-Date).ToString('MM-dd-yy')).csv" | Out-GridView
Read-Host -Prompt "Press enter to exit"


$comList = [System.IO.Ports.SerialPort]::GetPortNames() # Getting list of serial Ports with the help of C#

#Space to allow from import of .ini file in event used as a service

#Query Port and log location
$com = Read-Host -Prompt "Please enter the serial port name from list $comList" # Need to add COM validation 
$logLocation = Read-Host -Prompt "Please enter the path where the log will be stored: "

#Setting up the serial port for communication with Arduino, again using C#
$port = New-Object System.IO.Ports.SerialPort
$port.PortName = $com
$port.BaudRate = "9600"
$port.Parity = "None"
$port.DataBits = 8
$port.StopBits = 1
$port.DtrEnable = "true"
#$port.Open()

#Main loop to collect data
while($true){
    $port.Open()
    $temp = $port.ReadLine()
    $port.Close()
    $temp = $temp -replace "`t|`n|`r","" #Formatting to remove carriage return from serial readline
    $timestamp = Get-Date
    $writeItem = New-Object System.Object
       $writeItem | Add-Member NoteProperty -Name "Temp Farenheit" -Value $temp
       $writeItem | Add-Member NoteProperty -Name "Timestamp" -Value $timestamp
    $writeItem | Export-Csv -NoTypeInformation -Append -Path "$logLocation\temp_Log_for_$((Get-Date).ToString('MM-dd-yy')).csv"
    $writeItem
    Start-Sleep -s 5
}
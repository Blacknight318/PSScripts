
$comList = [System.IO.Ports.SerialPort]::GetPortNames() # Getting list of serial Ports

#Space to allow from import of .ini file in event used as a service

#Query Port and log location
$com = Read-Host -Prompt "Please enter the serial port name from list $comList" # Need to add COM validation 
$logLocation = Read-Host -Prompt "Please enter the path where the log will be stored: "

#Setting up the serial port for communication with Arduino
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
    $timestamp = Get-Date
    $writeItem = New-Object System.Object
       $writeItem | Add-Member NoteProperty -Name "Temp Farenheit" -Value $temp
       $writeItem | Add-Member NoteProperty -Name "Timestamp" -Value $timestamp
    $writeItem
    Start-Sleep -s 5
}
$ProcID = Get-WmiObject win32_Processor -Property ProcessorID | Select-Object -Property ProcessorID
$prod = $ProcID.ProcessorID
$ipid = $prod.Substring($prod.Length -5)
$ipid
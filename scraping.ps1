$hpPage = Invoke-WebRequest -Uri https://support.hp.com/us-en/document/c05869091
$hpPage.AllElements | where {$_.Class -eq 'label docSubtitle'} | Select-Object -Expand I
nnerText

$vms = (get-content listVMs.txt)

foreach ($vm in $vms) {
    Write-Host("$vm ") -NoNewline
    (Get-Datastore -vm $vm | Select-Object -Property name -First 1).name
}    

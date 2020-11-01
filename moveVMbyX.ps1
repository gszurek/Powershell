
$src = $args[0]
$dst = $args[1]
$skip = $args[2]

if ( ($args.Length -ne 3) -or ( $skip -eq 0 ) )  {
    Write-Host("Usage: ./moveVMbyX.ps1 <datastore src> <datastore dst> <parallelism>
    Liczba <parallelism> musi byc wieksza od zera.")
    exit
}

$datastores = Get-Datastore | Select-Object -Property Name

if ( !($datastores.Name -contains $src) -or !($datastores.Name -contains $dst) ) {
    Write-Host("Usage: ./moveVMbyX.ps1 <datastore src> <datastore dst> <parallelism>
    <datastore src> <datastore dst> musza byc faktycznymi datastorami.")
    exit
}

$VMs = Get-Datastore -Name $src | Get-VM | Sort-Object -Property Name

$VMs
exit

# wolne miejsce na docelowym datastore
$dst_free = Get-Datastore -Name vm_019_P4_04 | Select-Object -Property FreeSpaceGB
if ( $dst_free -lt $VMs_size ){
    Write-Host("Ilosc danych zrodlowych jest wieksza od docelowej wolnej przestrzeni.")
    exit
}

$vmscount = $VMs.count
$rest = $vmscount % $skip
$start = 0
$date = Get-Date
Write-Output("------------------ $date -----------------------
src: $src, dst: $dst, skip: $skip, start: $start, vmscout: $vmscount, rest: $rest 
VMs: $VMs") | Out-File -FilePath .\moveVMbyX.txt -Append

do {
    $VMs | Select-Object -First $skip -Skip $start #|
    #Move-VM -Datastore $dst | Out-File -FilePath .\moveVMbyX.txt -Append
    $start += $skip
    Write-Host(".")
}
until ($start -gt ($vmscount+$rest))
Write-Output("----------------------------- END ----------------------------
") | Out-File -FilePath .\moveVMbyX.txt -Append

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

# wolne miejsce na docelowym datastore
# do użycia może później: Get-Datastore -Name $src | select Name,@{N='Capacity (GB)';E={[math]::Round($_.ExtensionData.Summary.Capacity/1GB,2)}},@{N='Consumed (GB)';E={[math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace)/1GB,2)}}
$dst_free     = ([Math]::Round((Get-Datastore -Name $dst | Select-Object -Property FreeSpaceGB).FreeSpaceGB, 2))
$src_used     = ([Math]::Round((Get-Datastore -Name $dst | Select-Object -Property CapacityGB).CapacityGB, 2)) - $dst_free
$src_capacity = ([Math]::Round((Get-Datastore -Name $src | Select-Object -Property CapacityGB).CapacityGB, 2))

if ( $dst_free -lt $src_used ){
    Write-Host("    !!! Ilosc danych zrodlowych jest wieksza od docelowej wolnej przestrzeni !!!")
    Write-Host("    Ilosc wolnego miejsca datastore docelowego ($dst):      $dst_free GB
    Ilosc danych na datastore zrodlowym ($src):             $src_used GB")
    exit
}else{
    Write-Host("    Ilosc wolnego miejsca datastore docelowego ($dst):      $dst_free GB
    Ilosc danych na datastore zrodlowym ($src):             $src_used GB")
}
$go = Read-Host("Migrujemy? T/N [N]")
if ($go -ne "T"){
    exit
}

$VMs = Get-Datastore -Name $src | Get-VM | Sort-Object -Property Name
$vmscount = $VMs.count
$rest = $vmscount % $skip
$start = 0
$date = Get-Date
Write-Output("------------------ $date -----------------------
src: $src, dst: $dst, skip: $skip, start: $start, vmscout: $vmscount, rest: $rest 
VMs: $VMs") | Out-File -FilePath .\moveVMbyX.txt -Append

do {
    $VMs | Select-Object -First $skip -Skip $start #|
    Move-VM -Datastore $dst -Confirm | Out-File -FilePath .\moveVMbyX.txt -Append
    $start += $skip
    Write-Host(".")
}
until ($start -gt ($vmscount+$rest))
Write-Output("----------------------------- END ----------------------------
") | Out-File -FilePath .\moveVMbyX.txt -Append
Write-Host("Log: .\moveVMbyX.txt")
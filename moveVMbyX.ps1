# https://serverfault.com/questions/980212/script-to-storage-vmotion-from-one-datastore-to-another
$src = $args[0]
$dst = $args[1]
$skip = $args[2]

if ( ($args.Length -ne 3) -or ( $skip -eq 0 ) )  {
    Write-Host("Usage: $_name_ <datastore src> <datastore dst> <parallelism>
    Liczba <parallelism> musi byc wieksza od zera.")
    exit
}

$datastores = Get-Datastore | Select-Object -Property Name

if ( !($datastores.Name -contains $src) -or !($datastores.Name -contains $dst) ) {
    Write-Host("Usage: $_name_ <datastore src> <datastore dst> <parallelism>
    <datastore src> <datastore dst> musza byc faktycznymi datastorami.")
    #!$datastores.contains($src)
    exit
}

$VMs = Get-Datastore -Name $src | Get-VM | Sort-Object -Property Name
$vmscount = $VMs.count
$rest = $vmscount % $skip
$start = 0
Write-Output("src: $src, dst: $dst, skip: $skip, start: $start, vmscout: $vmscount, rest: $rest 
VMs: $VMs") | Out-File -FilePath .\moveVMbyX.txt

do {
    $VMs | Select-Object -First $skip -Skip $start |
    Move-VM -Datastore $dst | Out-File -FilePath .\moveVMbyX.txt -Append
    $start += $skip
    Write-Host(".")
}
until ($start -gt ($vmscount+$rest))
Write-Output("--------\n") | Out-File -FilePath .\moveVMbyX.txt -Append
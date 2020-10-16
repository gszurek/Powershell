# https://serverfault.com/questions/980212/script-to-storage-vmotion-from-one-datastore-to-another

$start = 0
do {
    $VMs |Select -First 10 -Skip $start | 
        Move-VM -Datastore $NewDatastore |
        Select Name |Out-File -FilePath "c:\logfile" -Append
    $start += 10
}
until ($start -gt $VMs.Length)
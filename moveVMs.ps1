$toDatastore = "bcloud_016_P3_1" 
$vms = ( Get-Content .\listVMs.txt )

foreach ( $vm in $vms ){
    #Write-Host "$vm -> ${toDatastore}:  " -NoNewline
    Get-VM $vm  | Move-VM -Datastore $toDatastore -runAsync
    #Write-Host "." 
}

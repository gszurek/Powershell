function find-thin{
    write-host -fore green `n "getting all VMs, this may take a while"

    $vms = get-vm |sort name |get-view
    
    Write-host -fore green `n "Starting Scan"
    
    $vmdks = @()
    
    foreach ($vm in $vms){
        foreach ($dev in $vm.config.hardware.Device){
            if($dev.GetType().Name -eq "VirtualDisk"){
                if($dev.Backing.ThinProvisioned){
                    #$getvm = get-vm $vm.name
                    $info = "" | Select VM, File, SizeInGB, Thin
                    $info.VM = $vm.name
                    $info.File = $dev.backing.filename
                    $info.SizeInGB = $dev.capacityinkb/1048576
                    $info.thin = $dev.Backing.ThinProvisioned
                    #$info.tier = $getvm.CustomFields["Tier"]
                    $vmdks += $info
                }
            }
        }
    }
    
    write-host -fore green `n "finished searching all VMs" `n
    
    $vmdks | export-csv d:\thindisk.csv
}

find-thin
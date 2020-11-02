#  Get count of targets, devices, and paths per hba per host
foreach($esx in Get-VMHost | Sort-Object -Property Name){
    foreach($hba in (Get-VMHostHba -VMHost $esx -Type "FibreChannel")){
        $target = ((Get-View $hba.VMhost).Config.StorageDevice.ScsiTopology.Adapter | where {$_.Adapter -eq $hba.Key}).Target
        $luns = Get-ScsiLun -Hba $hba  -LunType "disk" -ErrorAction SilentlyContinue
        $nrPaths = ($target | %{$_.Lun.Count} | Measure-Object -Sum).Sum
        $props = [ordered]@{
            VMHost = $esx.name
            HBA = $hba.Name
            Targets = $target.Count
            Devices = $luns.Count
            Paths = $nrPaths
        }
        New-Object PSObject -Property $props
    }
} 
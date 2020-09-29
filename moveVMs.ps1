$datastore = "bcloud_011_P0_01" 
$vms = "SNP2006 SNP2109" #z pliku (get-content MyList.txt)
get-vm  $vms | move-vm -datastore $datastore -runAsync | wait-task
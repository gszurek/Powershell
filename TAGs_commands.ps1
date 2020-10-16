function DisplayMenu { 
    $command = Read-Host "
    [1] Create tag categories 
    [2] Assign tags
    [3] Display tag categories
    [4] Show connected vCenter
    Choose"
    return $command
}
function CreateTagCategories {
    #param ($tagsCategories)
    $i=1
    foreach ($tagCategory in $tagsCategories){
        Write-Host "Create tag category ($i/$tagsCategoriesCount): $tagCategory"
        # Tworzenie nowej kategorii tagów:
        #New-TagCategory -Name $tag -EntityType VM
        sleep 1
        ++$i
    }
}

function CreateAssignTag {
    #param ($tagsCategories)
    # Plik musi mieć przecinki jako separatory kolumn
    $plik = 'C:\Users\szurkalogr\Documents\SNP\VMware\Obiekty - VM - Wszystko2.csv'
    $Lines = (Get-Content -Path $plik | Measure-Object -Line).Lines
    #Write-Host $Lines
    $csv = Import-Csv -Encoding UTF8 -Path $plik

    #Write-Host $Lines
    
    # Dla każdego wiersza pliku CSV:
    $csv | ForEach-Object {
        $count += 1
        $progress = [Math]::Round(($count * 100)/$Lines)
        Write-Progress -Activity "Progress" -Status "[$($count)/$($Lines)] $progress% complete:" -PercentComplete $progress -CurrentOperation "$($_."Nazwa") - $($_."System type")"
        #lub: Write-Host "Progress[$($count)/$($Lines)]: ${progress}%"
        
        ##Write-Host "Name: $($_."Nazwa")"
        ##Write-Host "System type: $($_."System type")"
        
        # Dla każdej kategorii tagów tworzymy tag i przypisujemy go do danej VM:
        foreach ($tagCategory in $tagsCategories) {
            Write-Host "Host: $($_.Nazwa) - Tag Category: $tagCategory"
            #New-Tag $_."System type" -Category "System type" -ErrorAction Ignore
            #Get-VM $_."Nazwa" | New-TagAssignment -Tag $_."System type" -ErrorAction Ignore
            
            # System type
            # Backup policy
            # Antyvirus policy
            # Storage tier
            # Host tier
            # Responsible team
            # Cost allocation
            # External owner
            # LDAP or AD
            # Ansible
            # Central monitoring
            # Central log
        }

        sleep 1
 
        Write-Host ""
        #$vmName=Get-VM $_.name
        #New-TagAssignment -Tag $_.tag -Entity $vmName
    }
}

# Main:
$tagsCategories = @("System type","Backup policy","Antyvirus policy","Storage tier","Host tier","Responsible team","Cost allocation","External owner","LDAP or AD","Ansible","Central monitoring","Central log")
$tagsCategoriesCount=$tagsCategories.Count
$command = DisplayMenu

if ($command -eq "1"){
    CreateTagCategories($tagsCategories) 
}elseif ($command -eq "2") {
    CreateAssignTag($tagsCategories)
}elseif ($command -eq "3") {
    Write-Host "Tag categories:"
    $i=1
    foreach ($tagCategory in $tagsCategories){
        Write-Host "$i. $tagCategory"
        ++$i
    }
}elseif ($command -eq "4") {
    Write-Host "Connected vCenter: $global:defaultviserver"
}else{
    Write-Host "Bad parameter ($command)."
}

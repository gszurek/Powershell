function DisplayMenu { 
    $command = Read-Host "
    [1] Create tag categories 
    [2] Assign tags
    [3] Display tag categories
    [4] Show connected vCenter
    [5] Get current tags info
    [6] Get current notes
    Choose"
    return $command
}
function CreateTagCategories {
    #param ($tagsCategories)
    $i=1
    foreach ($tagCategory in $tagsCategories){
        Write-Host "Create tag category ($i/$tagsCategoriesCount): $tagCategory"
        # Tworzenie nowej kategorii tagów:
        New-TagCategory -Name $tagCategory -EntityType VM -ErrorAction Ignore
        Start-Sleep 1
        ++$i
    }
}

function CreateAssignTag {
    #param ($tagsCategories)
    # Plik musi mieć przecinki jako separatory kolumn
    $plik = 'C:\Users\szurkalogr\Documents\SNP\VMware\Obiekty - VM - Wszystko2.csv'
    # Pomiar ilości linni - do progresu poniżej w for 
    $Lines = (Get-Content -Path $plik | Measure-Object -Line).Lines
    $csv = Import-Csv -Encoding UTF8 -Path $plik
       
    # Dla każdego wiersza pliku CSV:
    $csv | ForEach-Object {
        $count += 1
        $progress = [Math]::Round(($count * 100)/$Lines)
        # Progres, tak dla zabawy ;)
        Write-Progress -Activity "Progress" -Status "[$($count)/$($Lines)] $progress% complete:" -PercentComplete $progress -CurrentOperation "$($_."Nazwa") - $($_."System type")"
        #lub: Write-Host "Progress[$($count)/$($Lines)]: ${progress}%"
        
        # Zostawiam, może się przyda
        ##Write-Host "Name: $($_."Nazwa")"
        ##Write-Host "System type: $($_."System type")"
        
        # Dla każdej kategorii tagów tworzymy tag i przypisujemy go do danej VM:
        foreach ($tagCategory in $tagsCategories) {
            #Write-Host "Host: $($_.Nazwa) - Tag Category: $tagCategory"
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

        #Start-Sleep 1
 
        Write-Host ""
        #$vmName=Get-VM $_.name
        #New-TagAssignment -Tag $_.tag -Entity $vmName
    }
}

function GetCurrentTags {
    Write-Host "Current tags:"
    Get-Tag           | ft
    Write-Host "Current tags categories:"
    Get-TagCategory   | ft
    Write-Host "Current tags assignments:"
    Get-TagAssignment | ft
}

function GetCurrentNotes {
    Write-Host "VMs notes for vCenter " -NoNewline
    Write-Host $vcenter -ForegroundColor Blue -NoNewline
    Write-Host ":"
    Get-VM | Select-Object Notes
}

# Main:
$vcenter = $global:defaultviserver.name
$tagsCategories = @("System type","Backup policy","Antyvirus policy","Storage tier","Host tier","Responsible team","Cost allocation","External owner","LDAP or AD","Ansible","Central monitoring","Central log")
$tagsCategoriesCount=$tagsCategories.Count
$command = DisplayMenu

if ($command -eq "1"){ # Creates tags categories from CMDB
    CreateTagCategories
}elseif ($command -eq "2") { # Create and sssign tags from CMDB
    CreateAssignTag($tagsCategories)
}elseif ($command -eq "3") { # Display categories
    Write-Host "Tag categories:"
    $i=1
    foreach ($tagCategory in $tagsCategories){
        Write-Host "$i. $tagCategory"
        ++$i
    }
}elseif ($command -eq "4") { # Show connected vCenter
    Write-Host "Connected vCenter: " -NoNewline
    Write-Host $vcenter -ForegroundColor Blue
}elseif ($command -eq "5") { # Show current tags
    GetCurrentTags 
}elseif ($command -eq "6") { # show current notes
    GetCurrentNotes
}else{ # Bad command.
    Write-Host "Bad parameter ($command)."
}

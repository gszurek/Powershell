function DisplayMenu { 
    $command = Read-Host "
    [0] Listuj plik csv
    [1] Tworzenie kategorii tagow ze zmiennej 'tagsCategories'
    [2] Utworzenie i przypisanie tagow do VMs 
    [3] Listuj kategorie tagow ze zmiennej 'tagsCategories'
    [4] Aktualne tagi i ich kategorie
    [5] Aktualne pola Notes
    Wybierz"
    return $command
}

function DisplayCsv {
    param($plik)
    Write-Host ("Plik: $plik")
    $csv = Import-Csv -Encoding UTF8 -Path $plik -Delimiter ";"
    $csv | ForEach-Object {
        if($_.Nazwa -eq ""){
            exit
        }
        $_ 
        sleep 1 
    }  
}
function CreateTagCategories {
    #param ($tagsCategories)
    $i=1
    foreach ($tagCategory in $tagsCategories){
        Write-Host "Create tag category ($i/$tagsCategoriesCount): $tagCategory"
        # Tworzenie nowej kategorii tagów:
        New-TagCategory -Name $tagCategory -EntityType VM #-ErrorAction Ignore
        Start-Sleep 1
        ++$i
    }
}

function CreateAssignTag {
    param($plik)
    # Plik musi mieć średniki jako separatory kolumn
    Write-Host $plik
    Write-Host $tagsCategories
    #exit
    # Pomiar ilości linni - do progresu poniżej w 'for'
    $Lines = (Get-Content -Path $plik | Measure-Object -Line).Lines
    $csv = Import-Csv -Encoding UTF8 -Path $plik -Delimiter ";"
       
    # Dla każdego wiersza pliku CSV:
    $csv | ForEach-Object {
        $count += 1
        $progress = [Math]::Round(($count * 100)/$Lines)
        # Progres, tak dla zabawy ;)
        Write-Progress -Activity "Progress" -Status "[$($count)/$($Lines)] $progress% complete:" -PercentComplete $progress -CurrentOperation "$($_."Nazwa") - $($_."System type")"
        #lub: Write-Host "Progress[$($count)/$($Lines)]: ${progress}%"
        if($_.Nazwa -eq ""){
            exit
        }
               
        #Write-Host "System type: $($_."System type")"
        
        # Dla każdej kategorii tagów tworzymy tag i przypisujemy go do danej VM:
        foreach ($tagCategory in $tagsCategories) {
            Write-Host "VM: $($_.Nazwa) - Tag Category: $tagCategory -> $($_.$tagCategory)"
            #write-host "New-Tag $($_.$tagCategory) -Category $tagCategory -ErrorAction Ignore"
            #write-host "Get-VM $($_."Nazwa") | New-TagAssignment -Tag $($_.$tagCategory) -ErrorAction Ignore"
            if($tagCategory -eq "Customer" -or $tagCategory -eq "Uwagi"){ # wstawiamy w tym przypadku CustomAttributes zamiast TAGów
                Write-Host "Annotation!"
                Set-Annotation -Entity $_.Nazwa -CustomAttribute $tagCategory -Value $_.$tagCategory
            }else{
                New-Tag $_.$tagCategory -Category $tagCategory -ErrorAction Ignore
                Get-VM $($_."Nazwa") | New-TagAssignment -Tag $_.$tagCategory -ErrorAction Ignore
            }
            Write-Host
            #sleep 1

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
if (!$vcenter) {
    Write-Host "vCenter disconnected!"
    exit
}else{
    Write-Host "vCenter connected: " -NoNewline
    Write-Host $vcenter -ForegroundColor Blue
}

if (!$args[0]){
    Write-Host("Skladnia: TAGs_commands.ps1 <plik CMDB w formie csv>")
    exit
}else {
    Write-Host($args[0])
}

$tagsCategories = @("System type","Backup policy","Antyvirus policy","Storage tier","Host tier","Responsible team","Cost allocation","LDAP or AD","Ansible","Central monitoring","Central log","Customer","Uwagi")
$tagsCategoriesCount=$tagsCategories.Count
$command = DisplayMenu

if($command -eq 0){
    DisplayCsv($args[0])
}elseif($command -eq "1"){ # Creates tags categories from '$tagsCategories' list
    CreateTagCategories
}elseif ($command -eq "2") { # Create and assign tags from CMDB
    CreateAssignTag($args[0])
}elseif ($command -eq "3") { # Display categories
    Write-Host "
    Tag categories:"
    $i=1
    foreach ($tagCategory in $tagsCategories){
        Write-Host "    $i. $tagCategory"
        ++$i
    }
}elseif ($command -eq "4") { # Show current tags
    GetCurrentTags 
}elseif ($command -eq "5") { # show current notes
    GetCurrentNotes
}else{ # Bad command.
    Write-Host "Nieprawidlowy wybor ($command)."
}

Write-Host
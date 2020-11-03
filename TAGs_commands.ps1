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
        if($tagCategory -eq "Customer" -or $tagCategory -eq "Uwagi"){ # wstawiamy w tym przypadku CustomAttributes zamiast TAGów dla pol 'Customer' i 'Uwagi'
            Write-Host("Custom arrtibute, do utworzenia recznie ($i/$tagsCategoriesCount): $tagCategory") -ForegroundColor Yellow
        }else{
            Write-Host("Tworzenie kategorii tagow ($i/$tagsCategoriesCount): $tagCategory") -NoNewline
            # Tworzenie nowej kategorii tagów:
            New-TagCategory -Name $tagCategory -EntityType VM -ErrorAction Ignore
            Write-Host(" OK.") -ForegroundColor Green
            Start-Sleep 1
        }
        ++$i
    }
    Write-Host
}
function CreateAssignTag {
    param($plik)
    # Plik musi mieć średniki jako separatory kolumn !!!
    # Pomiar ilości linni - do progresu poniżej w 'for'
    $Lines = (Get-Content -Path $plik | Measure-Object -Line).Lines
    $csv = Import-Csv -Encoding UTF8 -Path $plik -Delimiter ";"
    $date = Get-Date
    Write-Output("------------------ $date -----------------------") | Tee-Object -FilePath ".\TAGs_commands.log" -Append
    # Dla każdego wiersza pliku CSV:
    $csv | ForEach-Object {
        $count += 1
        $progress = [Math]::Round(($count * 100)/$Lines)
        # Progres, tak dla zabawy ;)
        Write-Progress -Activity "Progress" -Status "[$($count)/$($Lines)] $progress% complete:" -PercentComplete $progress -CurrentOperation "$($_."Nazwa") - $($_."System type")"
        #lub: Write-Host "Progress[$($count)/$($Lines)]: ${progress}%"
        if($_.Nazwa -eq "" -or $vcDomain -ne $_."Cloud name"){ #Jeśli brak nazwy VM lub 'Cloud name' jest różne od domeny obecnie podpiętego vCenter
            Write-Host("$($_.Nazwa).$($_."Cloud name")") -NoNewline
            Write-Host(" != $vcDomain") -ForegroundColor Red
            #sleep 2
        }else{
            #Write-Host "System type: $($_."System type")"
            # Dla każdej kategorii tagów tworzymy tag i przypisujemy go do danej VM:
            foreach ($tagCategory in $tagsCategories) {
                if($tagCategory -eq "Customer" -or $tagCategory -eq "Uwagi"){ # wstawiamy w tym przypadku CustomAttributes zamiast TAGów dla pol 'Customer' i 'Uwagi'
                    Write-Output("VM: $($_.Nazwa) - CustomAttribute: $tagCategory -> $($_.$tagCategory)") | out-file -FilePath ".\TAGs_commands.log" -Append
                    Write-Host("VM: $($_.Nazwa) - CustomAttribute: $tagCategory -> $($_.$tagCategory): ") -NoNewline
                    Write-Host("(custom attribute): ") -NoNewline -ForegroundColor Yellow
                    #Set-Annotation -Entity $_.Nazwa -CustomAttribute $tagCategory -Value $_.$tagCategory
                }else{
                    Write-Output("VM: $($_.Nazwa) - Tag Category: $tagCategory -> $($_.$tagCategory)") | out-file -FilePath ".\TAGs_commands.log" -Append
                    Write-Host("VM: $($_.Nazwa) - Tag Category: $tagCategory -> $($_.$tagCategory): ") -NoNewline
                    #New-Tag $_.$tagCategory -Category $tagCategory -ErrorAction Ignore
                    #Get-VM $($_."Nazwa") | New-TagAssignment -Tag $_.$tagCategory -ErrorAction Ignore
                }
                Write-Host("OK.") -ForegroundColor Green
                #Write-Host
                #sleep 1
            }
        }
        Write-Host
    }
}
function GetCurrentTags {
    Write-Host "Aktualne tagi:"
    Get-Tag           | ft
    Write-Host "Aktualne kategorie tagow:"
    Get-TagCategory   | ft
    #Write-Host "Current tags assignments:"
    #Get-TagAssignment | ft
}
function GetCurrentNotes {
    Write-Host "VMs notes for vCenter " -NoNewline
    Write-Host $vcenter -ForegroundColor Blue -NoNewline
    Write-Host ":"
    Get-VM | Select-Object Notes
}

##################### Main:
$vcenter = $global:defaultviserver.Name
$vcDomain = $vcenter.Substring($vcenter.Length -7)
$vcConnected = $global:defaultviserver.IsConnected
if (!$vcConnected) {
    Write-Host "vCenter disconnected!"
    exit
}else{
    Write-Host "Aktualne vCenter: " -NoNewline
    Write-Host $vcenter -ForegroundColor Blue
}

if (!$args[0]){
    Write-Host("Skladnia: TAGs_commands.ps1 <plik CMDB w formie csv oddzielanych srednikami>")
    exit
}else {
    Write-Host("Przetwarzany plik: ") -NoNewline
    Write-Host($args[0]) -ForegroundColor Blue
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
    Kategorie tagow do utworzenia:"
    $i=1
    foreach ($tagCategory in $tagsCategories){
        if($tagCategory -eq "Customer" -or $tagCategory -eq "Uwagi"){ # wstawiamy w tym przypadku CustomAttributes zamiast TAGów dla pol 'Customer' i 'Uwagi'
            Write-Host("    $i. $tagCategory (custom attribute)") -ForegroundColor Yellow
        }else{
            Write-Host("    $i. $tagCategory")
        }
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
#skript pro prohledani vsech souboru xxx.txt, vypise vsechny pc na kterych byl prihlaseni konkretni uzivatel + vypise poslednich 5 zaznamu z kazdehou .txt souboru + otestuje konektivitu pingem
#spousteni skriptu: spustit powershell -> .\getComputers.ps1
#Jakub Mlynek, 15.02.2024

Set-Location "\\f-server-v\profily\prihlaseni"
$username = Read-Host "Zadej jmeno uzivatele"
$computers_paths = Get-ChildItem -Recurse | Select-String $username -List | Select-Object -ExpandProperty Path #ziska cesty ke vsem souborum, ktere obsahuji $username
#                                                                           Select-Object -ExpandProperty...zajisti ze funkce vrati "String"

$computers_list = New-Object System.Collections.ArrayList; #definice pole

Write-Host "`n---Seznam PC (.txt souboru):---"
ForEach ($computer_path in $computers_paths)
{ 
    $computer_filename = $computer_path.Split("\")[-1] #rozdeli cestu k souboru podle "\", ulozi do pole a zvoli posledni objekt (tzn. vystup je napr. pocitac123.txt)
    $computer_name = $computer_filename.Split(".")[-2] #rozdeli nazev souboru podle ".", ulozi do pole a zvoli predposledni objekt (tzn. vystup je napr. pocitac123)
    
    $computers_list.Add($computer_name) | Out-Null #prida kazde pc do pole, pouzije se pozdeji pro ping

    #vypis na konzoli (nazev pocitace + poslednich 5 radku z kazdeho souboru)
    Write-Host $computer_name
    Get-Content -tail 5 $computer_path
}

#ping
Write-Host ("`nTest konektivity:")
Write-Host ("---------------------------------------------------------------------")  -NoNewline
ForEach ($computer in $computers_list | Select-Object -Unique)
{
    ping /4 /n 4 /w 1000 $computer
    Write-Host ("---------------------------------------------------------------------") -NoNewline
}

#$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") #aby se po dokonceni nezavrel; odkomentovat pokud chci skript spoustet v externim okne (napr. pri spousteni pres .bat)
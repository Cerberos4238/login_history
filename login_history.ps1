$UserName = whoami
$Computer = hostname

do {
    $prompt = Read-Host "`nQuel laps de temps (en j ou h) : "
    $format = $prompt -match '^(\d+)([hj])$'
    
    if (-not $format) {

        Write-Host "`nFormat de durée invalide. Veuillez utiliser un format de type 2h ou 3j par exemple" -ForegroundColor Red
    }
} while (-not $format)

    $valeur = [int]$matches[1]
    $unite = $matches[2]

    switch ($unite) {
        'h' { $StartTime = (Get-Date).AddHours(-$valeur) }
        'j' { $StartTime = (Get-Date).AddDays(-$valeur) }
    }

$events = Get-WinEvent -ComputerName $Computer -FilterHashtable @{
    logName = 'Security';
    ID = 4624;
    StartTime = $StartTime
} | Where-Object {
    $_.Properties[8].Value -eq "10" -and $_.Properties[5].Value -ne $UserName
}

$events | Select-Object TimeCreated,
    @{Name='User';Expression={$_.Properties[5].Value}},
    @{Name='Source IP';Expression={$_.Properties[18].Value}} | Sort-Object TimeCreated -Descending
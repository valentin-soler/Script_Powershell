# Alerte pour les connexions après certaines heures
$alertHour = 7 # Heure après laquelle les connexions sont surveillées
$currentHour = (Get-Date).Hour

if ($currentHour -gt $alertHour) {
    $recentLogons = Get-EventLog -LogName Security -InstanceId 4624 -After (Get-Date).AddHours(-1)
    if ($recentLogons) {
        Write-Host "Alerte : Connexion detectee après $alertHour heures !"
    }
}

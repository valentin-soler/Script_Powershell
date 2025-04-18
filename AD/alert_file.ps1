# Alerte pour les modifications fréquentes d'un fichier
$filePath = "C:\chemin\vers\le\fichier.txt"
$modificationThreshold = 3
$modificationCount = 0

$file = Get-Item $filePath
$lastWriteTime = $file.LastWriteTime

while ($true) {
    Start-Sleep -Seconds 60 # Vérifie toutes les 60 secondes
    $file = Get-Item $filePath
    if ($file.LastWriteTime -ne $lastWriteTime) {
        $modificationCount++
        $lastWriteTime = $file.LastWriteTime
        if ($modificationCount -ge $modificationThreshold) {
            Write-Host "Alerte : Plus de $modificationThreshold modifications detectees sur $filePath aujourd'hui."
            break
        }
    }
}

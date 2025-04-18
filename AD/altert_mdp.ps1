# Alerte pour l'expiration du mot de passe
$expirationThreshold = 15
$users = Get-ADUser -Filter * -Properties PasswordLastSet, PasswordNeverExpires, msDS-UserPasswordExpiryTimeComputed

foreach ($user in $users) {
    if ($user.PasswordNeverExpires -ne $true) {
        $passwordExpiryDate = [datetime]::FromFileTime($user.'msDS-UserPasswordExpiryTimeComputed')
        $daysUntilExpiry = ($passwordExpiryDate - (Get-Date)).Days
        if ($daysUntilExpiry -le $expirationThreshold) {
            Write-Host "Alerte : Le mot de passe de $($user.Name) expire dans $daysUntilExpiry jours."
        }
    }
}

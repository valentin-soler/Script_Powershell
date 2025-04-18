# Identification des doublons
$duplicateUsers = Get-ADUser -Filter * -Properties EmailAddress | Group-Object EmailAddress | Where-Object { $_.Count -gt 1 }

$duplicateUsers | ForEach-Object {
    $_.Group | Select-Object Name, EmailAddress | Format-Table -AutoSize
}
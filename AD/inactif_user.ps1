# Récupération des comptes inactifs pdt plus de 7j
$inactiveDays = 7
$inactiveUsers = Get-ADUser -Filter * -Properties LastLogonDate | Where-Object { $_.LastLogonDate -lt (Get-Date).AddDays(-$inactiveDays) }

$inactiveUsers | Select-Object Name, LastLogonDate | Format-Table -AutoSize

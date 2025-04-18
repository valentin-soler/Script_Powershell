# Importation du module Active Directory
Import-Module ActiveDirectory

# Chemin du fichier CSV
$csvPath = "E:\data.csv"

# Importation des données CSV
$users = Import-Csv -Path $csvPath -Delimiter ","

foreach ($user in $users) {
    # Génération du nom d'utilisateur (première lettre du prénom + nom)
    $username = (($user.PRENOM.Substring(0,1) + "." + $user.NOM).Replace(" ", "")).ToLower()
    
    # Configuration du mot de passe
    $password = ConvertTo-SecureString "Azerty06!" -AsPlainText -Force
    
    # Construction du DN de l'OU cible
    $ouPath = "OU=Utilisateurs,OU=$($user.ETABLISSEMENT),DC=pourlesvieux,DC=local"
    
    # Création de l'utilisateur dans Active Directory
    New-ADUser -Name "$($user.PRENOM) $($user.NOM)" `
        -GivenName $user.PRENOM `
        -Surname $user.NOM `
        -SamAccountName $username `
        -UserPrincipalName "$username@pourlesvieux.local" `
        -AccountPassword $password `
        -Enabled $true `
        -PasswordNeverExpires $false `
        -ChangePasswordAtLogon $true `
        -HomeDrive "U:" `
        -HomeDirectory "\\SRV-AD01\Utilisateurs\$username" `
        -Path $ouPath `
        -PassThru
}

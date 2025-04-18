# Script d'assignation aux groupes AD avec gestion des accents
Import-Module ActiveDirectory

# Configuration
$csvPath = "E:\data.csv"
$domain = "pourlesvieux.local"

# Règles de nommage par établissement
$etablissementRules = @{
    "Gabres"     = @{ Type = "Suffixe"; Valeur = "06" }
    "Hermitage"  = @{ Type = "Suffixe"; Valeur = "83" }
    "Cascade"    = @{ Type = "Suffixe"; Valeur = "94" }
    "Siege"      = @{ Type = "Prefixe"; Valeur = "06" }
}

# Mappage des fonctions vers les groupes (sans accents)
$functionMappings = @{
    "Animation"             = @("Animation")
    "AS"                    = @("AS", "Medical")
    "ASH"                   = @("ASH", "Technique")
    "cadre de sante"        = @("Medical", "Cadres")
    "Comptable"             = @("Compta", "Administratif")
    "Directeur"             = @("Administratif")
    "Directeur General"     = @("Administratif")
    "Maitresse de Maison"   = @("Cadres")
    "Medecin"               = @("Cadres", "Medical")
    "Psychologue"           = @("Cadres", "Medical")
    "service technique"     = @("Technique")
    "IDE"                   = @("IDE", "Medical")
    "responsable animation" = @("Cadres", "Animation")
}

# Fonction pour supprimer les accents
function Remove-Accents {
    param ([string]$input)
    $normalized = $input.Normalize([Text.NormalizationForm]::FormD)
    $sb = New-Object -TypeName System.Text.StringBuilder
    foreach ($c in $normalized.ToCharArray()) {
        if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    return $sb.ToString().Normalize([Text.NormalizationForm]::FormC)
}

# Importation et traitement du CSV
$users = Import-Csv -Path $csvPath -Delimiter "," | ForEach-Object {
    [PSCustomObject]@{
        NOM = $_.NOM
        PRENOM = $_.PRENOM
        ETABLISSEMENT = $_.ETABLISSEMENT
        FONCTION = (($_.FONCTION -replace "-.*$", "") -replace "é","e").Trim()
    }
}
foreach ($user in $users) {
    # Génération du nom d'utilisateur
    Write-Host "$user"
    $username = (($user.PRENOM.Substring(0,1) + "." + $user.NOM).Replace(" ", "")).ToLower()
    Write-Host "$username"

    try {
        # Récupération des règles de l'établissement
        $rule = $etablissementRules[$user.ETABLISSEMENT]
        Write-Host "$rule"
        if ($functionMappings.ContainsKey($user.FONCTION)) {
            foreach ($groupe in $functionMappings[$user.FONCTION]) {
                # Construction du nom du groupe
                if ($rule.Type -eq "Prefixe") {
                    $groupName = "$($rule.Valeur)$groupe"
                } else {
                    $groupName = "$groupe$($rule.Valeur)"
                }

                # Chemin de l'OU cible
                $ouPath = "OU=Groupes,OU=$($user.ETABLISSEMENT),DC=$($domain.Split('.')[0]),DC=$($domain.Split('.')[1])"

                # Création du groupe si inexistant
                if (-not (Get-ADGroup -Filter { Name -eq $groupName } -SearchBase $ouPath -ErrorAction Stop)) {
                    New-ADGroup -Name $groupName `
                        -SamAccountName $groupName `
                        -GroupCategory Security `
                        -GroupScope Global `
                        -DisplayName $groupName `
                        -Path $ouPath
                }

                # Ajout de l'utilisateur au groupe
                Add-ADGroupMember -Identity $groupName -Members $username -ErrorAction Stop
                Write-Host "[SUCCÈS] $username ajouté à $groupName" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "[ERREUR] Problème avec $username : $_" -ForegroundColor Red
    }
}

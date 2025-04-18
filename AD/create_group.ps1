## Script de création des groupes AD
Import-Module ActiveDirectory

# Configuration
$domain = "pourlesvieux.local"

# Règles de nommage par établissement
$etablissementRules = @{
    "Gabres"     = @{ Type = "Suffixe"; Valeur = "06" }
    "Hermitage"  = @{ Type = "Suffixe"; Valeur = "83" }
    "Cascade"    = @{ Type = "Suffixe"; Valeur = "94" }
    "Siege"      = @{ Type = "Prefixe"; Valeur = "06" }
}

# Mappage des fonctions vers les groupes
$functionMappings = @{
    "Animation"             = @("Animation")
    "AS"                    = @("AS", "Medical")
    "ASH"                   = @("ASH", "Medical")
    "cadre de santé"        = @("Medical", "Cadres")
    "Comptable"             = @("Compta", "Administratif")
    "Directeur"             = @("Administratif")
    "Maîtresse de Maison"   = @("Cadres")
    "Médecin"               = @("Cadres", "Medical")
    "Psychologue"           = @("Cadres", "Medical")
    "service technique"     = @("Technique")
    "IDE"                   = @("IDE", "Medical")
    "responsable animation" = @("Cadres", "Animation")
}

# Liste des établissements
$etablissements = @("Gabres", "Hermitage", "Cascade", "Siege")

# Création des groupes pour chaque établissement et fonction
foreach ($etablissement in $etablissements) {
    $rule = $etablissementRules[$etablissement]

    foreach ($fonction in $functionMappings.Keys) {
        foreach ($groupe in $functionMappings[$fonction]) {
            # Construction du nom du groupe
            if ($rule.Type -eq "Prefixe") {
                $groupName = "$($rule.Valeur)$groupe"
            } else {
                $groupName = "$groupe$($rule.Valeur)"
            }

            # Construction du chemin OU (à adapter selon votre structure AD)
            $ouPath = "OU=Groupes,OU=$etablissement,DC=$($domain.Split('.')[0]),DC=$($domain.Split('.')[1])"

            try {
                # Vérification et création du groupe si inexistant
                if (-not (Get-ADGroup -Filter { Name -eq $groupName } -SearchBase $ouPath -ErrorAction Stop)) {
                    New-ADGroup -Name $groupName `
                        -SamAccountName $groupName `
                        -GroupCategory Security `
                        -GroupScope Global `
                        -DisplayName "$groupName ($etablissement)" `
                        -Path $ouPath `
                        -Description "Groupe $groupName pour l'etablissement : $etablissement"

                    Write-Host "[CRÉÉ] Groupe : $groupName dans OU : $ouPath" -ForegroundColor Green
                } else {
                    Write-Host "[EXISTANT] Groupe : $groupName deja présent dans OU : $ouPath" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "[ERREUR] Échec création groupe : $_" -ForegroundColor Red
            }
        }
    }
}

# Importeer de Active Directory-module
Import-Module ActiveDirectory

# CSV bestand locatie
$csvPath = "D:\Scripts\users.csv"

# Basis OU pad
$baseOuPath = "OU=DTA,DC=DataTransferAnalog,DC=com"
$domein = "DataTransferAnalog"

# Importeer CSV bestand
$users = Import-Csv -Path $csvPath

# Loop door elke gebruiker in het CSV bestand
foreach ($user in $users) {
    # Parameters voor de nieuwe gebruiker
    $firstName = $user.Voornaam
    $lastName = $user.Achternaam
    $department = $user.Afdeling
    $title = $user.Functie
    $phoneNumber = $user.Telefoonnummer
    $address = $user.Adres
    $postalCode = $user.Postcode
    $city = $user.Plaatsnaam

    # Maak een gebruikersnaam (bijv. voornaam.achternaam)
    $username = "$firstName.$lastName"
    $email = "$username@$domein.com"

    # Bepaal de OU voor de gebruiker op basis van de afdeling
    $ouPath = "OU=$department,$baseOuPath"

    # Controleer of de OU voor de afdeling bestaat
    if (-not (Get-ADOrganizationalUnit -Filter { DistinguishedName -eq $ouPath })) {
        Write-Host "Fout: De OU '$ouPath' bestaat niet. Gebruiker $username zal niet worden aangemaakt."
        continue  # Sla deze gebruiker over en ga verder met de volgende
    }

    # Creëer de nieuwe gebruiker
    try {
        New-ADUser -Name "$firstName $lastName" `
                   -GivenName $firstName `
                   -Surname $lastName `
                   -UserPrincipalName "$username@$domein.local" `
                   -SamAccountName $username `
                   -EmailAddress $email `
                   -Department $department `
                   -Title $title `
                   -OfficePhone $phoneNumber `
                   -StreetAddress $address `
                   -PostalCode $postalCode `
                   -City $city `
                   -Path $ouPath `  # Gebruiker wordt in de afdeling-OU geplaatst
                   -AccountPassword (ConvertTo-SecureString "Wachtwoord1" -AsPlainText -Force) `
                   -ChangePasswordAtLogon $true `
                   -Enabled $true

        Write-Host "Gebruiker $username succesvol aangemaakt."

    } catch {
        Write-Host "Fout bij het aanmaken van gebruiker $username. Fout: $($_.Exception.Message)"
        # Extra foutafhandeling of logging kan hier worden toegevoegd
    }
}

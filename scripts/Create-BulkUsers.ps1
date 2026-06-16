# ============================================================
# Create-BulkUsers.ps1
# Bulk-creates AD users from a CSV file into the CORP Users OU
# Author: Daniel Barua | corp.lab home lab
# ============================================================

Import-Module ActiveDirectory

# Path to the source CSV and the target OU
$CsvPath  = "C:\ADLab\users.csv"
$TargetOU = "OU=Users,OU=CORP,DC=corp,DC=lab"
$Domain   = "corp.lab"

# Default password for all new accounts (must change at first logon)
$DefaultPassword = ConvertTo-SecureString "Welcome.2026!" -AsPlainText -Force

# Import the CSV and loop through each row
Import-Csv $CsvPath | ForEach-Object {

    # Build a username: first initial + surname, all lowercase (e.g. awalker)
    $sam = ($_.FirstName.Substring(0,1) + $_.LastName).ToLower()
    $upn = "$sam@$Domain"
    $displayName = "$($_.FirstName) $($_.LastName)"

    # Skip if the user already exists (makes the script safe to re-run)
    if (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue) {
        Write-Host "SKIPPED (already exists): $sam" -ForegroundColor Yellow
    }
    else {
        New-ADUser `
            -Name              $displayName `
            -GivenName         $_.FirstName `
            -Surname           $_.LastName `
            -SamAccountName    $sam `
            -UserPrincipalName $upn `
            -Department        $_.Department `
            -Title             $_.Title `
            -Path              $TargetOU `
            -AccountPassword   $DefaultPassword `
            -ChangePasswordAtLogon $true `
            -Enabled           $true

        Write-Host "CREATED: $displayName ($sam) - $($_.Department)" -ForegroundColor Green
    }
}

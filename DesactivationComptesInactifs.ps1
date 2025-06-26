# Désactive les comptes utilisateurs inactifs depuis 30 jours
$InactiveDays = 30
$Time = (Get-Date).AddDays(-$InactiveDays)

Import-Module ActiveDirectory

$inactiveUsers = Search-ADAccount -UsersOnly -AccountInactive -TimeSpan "$InactiveDays.00:00:00"

foreach ($user in $inactiveUsers) {
    Disable-ADAccount -Identity $user.SamAccountName
    Write-Output "Compte désactivé : $($user.SamAccountName)"
}
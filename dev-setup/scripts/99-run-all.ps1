# This script is experimental and may not work as expected. Please use with caution.

Write-Host "Checking for Administrator rights..."
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as Administrator."
    exit 1
}

# Prompt user confirmation
$confirmation = Read-Host "This script is untested and may cause unexpected changes. Press 'A' to continue or any other key to exit."
if ($confirmation -ne 'A') {
    Write-Host "Exiting script."
    exit 0
}

Write-Host "Script started at: $(Get-Date)"
$startTime = Get-Date

Write-Host "Stopping services..."
.\01-stop-services.ps1

Write-Host "Importing SQL..."
.\02-import-sql.ps1

Write-Host "Modifying AxDB..."
sqlcmd -S localhost -i .\03-modify-new-axdb.sql

Write-Host "Replacing old DB..."
sqlcmd -S localhost -i .\04-replace-old-db.sql

Write-Host "Enabling users..."
sqlcmd -S localhost -i .\05-enable-users.sql

Write-Host "Starting services..."
.\06-start-services.ps1

Write-Host "All scripts completed!"

$endTime = Get-Date
Write-Host "Script finished at: $endTime"

$totalTime = $endTime - $startTime
Write-Host "Total time: $($totalTime.ToString())"
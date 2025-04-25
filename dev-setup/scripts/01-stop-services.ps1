# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Error: Script must be run with administrative privileges." -ForegroundColor Red
    Write-Host "Exiting script." -ForegroundColor Red
    exit 1
}

Write-Host "Attempting to stop services..."

# Define the services to stop
$servicesToStop = @(
    "W3SVC"
    "DynamicsAxBatch"
    "Microsoft.Dynamics.AX.Framework.Tools.DMF.SSISHelperService"
    "LCSDiagnosticClientService"
    "MR2012ProcessService"
    "MSSQLFDLauncher"
    "ReportServer"
    "MsDtsServer130"
    "MSSQLServerOLAPService"
    "SSISTELEMETRY130"
    "SSASTELEMETRY"
    "SQLTELEMETRY"
)

# Stop the services
foreach ($serviceName in $servicesToStop) {
    Write-Host "Attempting to stop service: $serviceName"
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service) {
        if ($service.Status -eq "Running") {
            try {
                Stop-Service -InputObject $service -Force -ErrorAction Stop
                Write-Host "Successfully stopped service: $serviceName" -ForegroundColor Green
            }
            catch {
                Write-Host "Error stopping service '$serviceName': $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "Service '$serviceName' is not running."
        }
    } else {
        Write-Host "Service '$serviceName' not found." -ForegroundColor Yellow
    }
}

Write-Host "Finished attempting to stop services."
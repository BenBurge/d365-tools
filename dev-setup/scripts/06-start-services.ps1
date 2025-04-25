# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Error: Script must be run with administrative privileges." -ForegroundColor Red
    Write-Host "Exiting script." -ForegroundColor Red
    exit 1
}

Write-Host "Attempting to start services..."

# Define the services to start
$servicesToStart = @(
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

# Start the services
foreach ($serviceName in $servicesToStart) {
    Write-Host "Attempting to start service: $serviceName"
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($service) {
        if ($service.Status -eq "Stopped" -or $service.Status -eq "StopPending") {
            try {
                Start-Service -InputObject $service -ErrorAction Stop
                Write-Host "Successfully started service: $serviceName" -ForegroundColor Green
            }
            catch {
                Write-Host "Error starting service '$serviceName': $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        elseif ($service.Status -eq "Running") {
            Write-Host "Service '$serviceName' is already running."
        }
        else {
            Write-Host "Service '$serviceName' is in an unknown state: $($service.Status)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Service '$serviceName' not found." -ForegroundColor Yellow
    }
}

Write-Host "Finished attempting to start services."

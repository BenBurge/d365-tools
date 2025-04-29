# Check for administrative privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Error: This script must be run with administrative privileges." -ForegroundColor Red
    exit 1
}

# Define the sqlpackage path
$sqlPackageCommand = "sqlpackage"

# Check if sqlpackage is available
$foundSqlPackage = Get-Command $sqlPackageCommand -ErrorAction SilentlyContinue
if (-not $foundSqlPackage) {
    Write-Host "`"$sqlPackageCommand`" not found. Attempting to install using .NET CLI..." -ForegroundColor Yellow
    $installSqlPackage = Read-Host "Do you want to attempt to install sqlpackage using the .NET CLI? (y/N)"

    if ($installSqlPackage -ceq "y") {
        Write-Host "Attempting to install sqlpackage globally using .NET CLI..."
        try {
            dotnet tool install -g microsoft.sqlpackage | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "sqlpackage successfully installed." -ForegroundColor Green
                $sqlPackageCommand = "$env:USERPROFILE\.dotnet\tools\sqlpackage.exe"
            } else {
                Write-Host "Error: sqlpackage installation failed." -ForegroundColor Red
                exit 1
            }
        } catch {
            Write-Host "Exception during install: $($_.Exception.Message)" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Please install sqlpackage and try again." -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "`"$sqlPackageCommand`" is available." -ForegroundColor Green
}

# Ask for the .bacpac file path
$bacpacFile = Read-Host "Enter the full path to your .bacpac file"

# Validate the file path
if (-not (Test-Path $bacpacFile)) {
    Write-Host "Error: The file '$bacpacFile' does not exist." -ForegroundColor Red
    exit 1
}

$targetServerName = "Server=localhost;TrustServerCertificate=True"
$targetDatabaseName = "AxDB_New"

$sqlPackageArgs = @(
    "/Action:Import"
    "/SourceFile:$bacpacFile"
    "/TargetServerName:`"$targetServerName`""
    "/TargetDatabaseName:`"$targetDatabaseName`""
    "/p:CommandTimeout=1200"
)


# Display the command for transparency
Write-Host "`nExecuting:" -ForegroundColor Cyan
Write-Host "$sqlPackageCommand $($sqlPackageArgs -join ' ')" -ForegroundColor Gray

# Run sqlpackage
try {
    & $sqlPackageCommand @sqlPackageArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nBacpac import completed successfully." -ForegroundColor Green
    } else {
        Write-Host "`nBacpac import failed. Exit code: $LASTEXITCODE" -ForegroundColor Red
    }
} catch {
    Write-Host "Error executing sqlpackage: $($_.Exception.Message)" -ForegroundColor Red
}

# Check if running as administrator (required for potential download)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Error: This script may need to download components and must be run with administrative privileges." -ForegroundColor Red
    exit 1
}

# Define the expected sqlpackage.exe path
$sqlPackagePath = "C:\tools\sqlpackage\sqlpackage.exe"

# Check if sqlpackage.exe exists
if (-not (Test-Path $sqlPackagePath)) {
    Write-Host "sqlpackage.exe not found at '$sqlPackagePath'." -ForegroundColor Yellow
    $installSqlPackage = Read-Host "Do you want to attempt to download and install sqlpackage? (y/N)"

    if ($installSqlPackage -ceq "y") {
        Write-Host "Attempting to download and install sqlpackage..."
        $packageSource = "https://go.microsoft.com/fwlink/?linkid=873014" # Link to the latest DAC Framework MSI

        $tempFile = Join-Path $env:TEMP "SqlPackage.msi"

        try {
            Invoke-WebRequest -Uri $packageSource -OutFile $tempFile

            # Create the tools directory if it doesn't exist
            $toolsDir = Split-Path $sqlPackagePath
            if (-not (Test-Path $toolsDir)) {
                Write-Host "Creating directory: '$toolsDir'"
                New-Item -Path $toolsDir -ItemType Directory -Force | Out-Null
            }

            # Attempt silent installation
            Write-Host "Installing sqlpackage. This may take a few minutes..."
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", "`"$tempFile`"", "/qn", "TARGETDIR=`"$toolsDir`"" -Wait -PassThru | Out-Null
            Remove-Item $tempFile -Force

            if (Test-Path $sqlPackagePath) {
                Write-Host "sqlpackage.exe successfully installed at '$sqlPackagePath'." -ForegroundColor Green
            } else {
                Write-Host "Error: sqlpackage.exe installation failed. Please check the output for errors." -ForegroundColor Red
                exit 1
            }
        }
        catch {
            Write-Host "Error downloading or installing sqlpackage: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Please ensure you have internet connectivity and try running the script again as an administrator." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Please ensure sqlpackage.exe is available at '$sqlPackagePath' and run the script again." -ForegroundColor Yellow
        exit 1
    }
}

# Prompt the user for the location of the .bacpac file
$bacpacFile = Read-Host "Enter the full path to your .bacpac file"

# Validate the provided bacpac file path
if (-not (Test-Path $bacpacFile)) {
    Write-Host "Error: The specified bacpac file '$bacpacFile' does not exist." -ForegroundColor Red
    exit 1
}

# Define the parameters for sqlpackage.exe
$sqlPackageParameters = @{
    'a'              = 'import'
    'sf'             = $bacpacFile
    'tsn'            = 'localhost'
    'tdn'            = 'AxDB_New'
    'p:CommandTimeout' = '1200'
    'ttsc'           = 'True'
}

# Build the argument list for Start-Process
$arguments = foreach ($key in $sqlPackageParameters.Keys) {
    "/$key:`"$($sqlPackageParameters[$key])`""
}

# Execute sqlpackage.exe
Write-Host "Executing: '$sqlPackagePath' $($arguments -join ' ')"
try {
    Start-Process -FilePath $sqlPackagePath -ArgumentList $arguments -Wait -PassThru
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Bacpac import completed successfully." -ForegroundColor Green
    } else {
        Write-Host "Bacpac import failed. Exit code: $($LASTEXITCODE)" -ForegroundColor Red
    }
}
catch {
    Write-Host "Error running sqlpackage: $($_.Exception.Message)" -ForegroundColor Red
}
# PowerShell script to create and setup Microsoft Access database for Stack Overflow Clone
# This script creates the Access database and executes the SQL setup script

param(
    [string]$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflow.accdb"
)

Write-Host "Setting up Microsoft Access database for Stack Overflow Clone..." -ForegroundColor Green

# Ensure the Database directory exists
$DatabaseDir = Split-Path $DatabasePath -Parent
if (!(Test-Path $DatabaseDir)) {
    New-Item -ItemType Directory -Path $DatabaseDir -Force
    Write-Host "Created database directory: $DatabaseDir" -ForegroundColor Yellow
}

# Check if Access database already exists
if (Test-Path $DatabasePath) {
    $response = Read-Host "Database already exists at $DatabasePath. Do you want to recreate it? (y/N)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Remove-Item $DatabasePath -Force
        Write-Host "Existing database removed." -ForegroundColor Yellow
    } else {
        Write-Host "Using existing database." -ForegroundColor Yellow
        exit 0
    }
}

try {
    # Create new Access database using COM object
    $access = New-Object -ComObject Access.Application
    $access.Visible = $false
    
    # Create new database
    $access.NewCurrentDatabase($DatabasePath)
    Write-Host "Created new Access database: $DatabasePath" -ForegroundColor Green
    
    # Read and execute SQL script
    $sqlScript = Get-Content -Path "$PSScriptRoot\CreateAccessTables.sql" -Raw
    
    # Split the script into individual statements
    $statements = $sqlScript -split ';' | Where-Object { $_.Trim() -ne '' -and !$_.Trim().StartsWith('--') }
    
    foreach ($statement in $statements) {
        $cleanStatement = $statement.Trim()
        if ($cleanStatement -ne '') {
            try {
                $access.DoCmd.RunSQL($cleanStatement)
                Write-Host "Executed: $($cleanStatement.Substring(0, [Math]::Min(50, $cleanStatement.Length)))..." -ForegroundColor Gray
            }
            catch {
                Write-Host "Warning: Could not execute statement: $($cleanStatement.Substring(0, [Math]::Min(50, $cleanStatement.Length)))..." -ForegroundColor Yellow
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
    
    # Close Access
    $access.CloseCurrentDatabase()
    $access.Quit()
    
    # Release COM object
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($access) | Out-Null
    
    Write-Host "Database setup completed successfully!" -ForegroundColor Green
    Write-Host "Database location: $DatabasePath" -ForegroundColor Cyan
    
    # Test connection
    Write-Host "Testing database connection..." -ForegroundColor Yellow
    
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath;Persist Security Info=False;"
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    
    try {
        $connection.Open()
        $command = New-Object System.Data.OleDb.OleDbCommand("SELECT COUNT(*) FROM Tags", $connection)
        $tagCount = $command.ExecuteScalar()
        Write-Host "Connection test successful! Found $tagCount sample tags in database." -ForegroundColor Green
        $connection.Close()
    }
    catch {
        Write-Host "Connection test failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please ensure Microsoft Access Database Engine is installed." -ForegroundColor Yellow
    }
    finally {
        if ($connection.State -eq 'Open') {
            $connection.Close()
        }
        $connection.Dispose()
    }
}
catch {
    Write-Host "Error setting up database: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please ensure Microsoft Access is installed and accessible." -ForegroundColor Yellow
    
    if ($access) {
        try {
            $access.Quit()
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($access) | Out-Null
        }
        catch {
            # Ignore cleanup errors
        }
    }
    
    exit 1
}

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Update the connection string in appsettings.json if needed" -ForegroundColor White
Write-Host "2. Run 'dotnet ef database update' to create Identity tables" -ForegroundColor White
Write-Host "3. Run 'dotnet run' to start the application" -ForegroundColor White

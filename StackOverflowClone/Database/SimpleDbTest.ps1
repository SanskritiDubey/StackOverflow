# Simple PowerShell script to test Access database connection
$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflowComplete.accdb"

Write-Host "Testing Access Database Connection" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host "Database: $DatabasePath" -ForegroundColor Cyan

# Check if file exists
if (!(Test-Path $DatabasePath)) {
    Write-Host "❌ Database file does not exist!" -ForegroundColor Red
    Write-Host "Available files:" -ForegroundColor Yellow
    Get-ChildItem -Path (Split-Path $DatabasePath -Parent) | Select-Object Name, Length
    exit 1
}

$fileSize = (Get-Item $DatabasePath).Length
Write-Host "✓ Database file exists ($fileSize bytes)" -ForegroundColor Green

# Test connection
$connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath;Persist Security Info=False;"
Write-Host "Connection string: $connectionString" -ForegroundColor Gray

try {
    # Load System.Data assembly
    Add-Type -AssemblyName System.Data
    
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()
    
    Write-Host "✓ Successfully connected!" -ForegroundColor Green
    
    # Get tables
    Write-Host "`nRetrieving tables..." -ForegroundColor Yellow
    $tables = $connection.GetSchema("Tables")
    
    Write-Host "`nTABLES FOUND:" -ForegroundColor Green
    Write-Host "=============" -ForegroundColor Green
    
    $tableCount = 0
    foreach ($row in $tables.Rows) {
        if ($row["TABLE_TYPE"] -eq "TABLE") {
            $tableCount++
            $tableName = $row["TABLE_NAME"]
            Write-Host "$tableCount. $tableName" -ForegroundColor White
        }
    }
    
    if ($tableCount -eq 0) {
        Write-Host "❌ NO TABLES FOUND!" -ForegroundColor Red
    } else {
        Write-Host "`nTotal: $tableCount tables" -ForegroundColor Cyan
        
        # Test a few specific tables
        Write-Host "`nTesting table queries:" -ForegroundColor Yellow
        $testTables = @("AspNetUsers", "Questions", "Tags")
        
        foreach ($tableName in $testTables) {
            try {
                $command = New-Object System.Data.OleDb.OleDbCommand("SELECT COUNT(*) FROM [$tableName]", $connection)
                $count = $command.ExecuteScalar()
                Write-Host "✓ $tableName : $count records" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ $tableName : Not found or error" -ForegroundColor Red
            }
        }
    }
    
    $connection.Close()
    Write-Host "`n✅ Database test completed!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Connection failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    Write-Host "`nTroubleshooting:" -ForegroundColor Cyan
    Write-Host "1. Install Microsoft Access Database Engine" -ForegroundColor White
    Write-Host "2. Check if database file is corrupted" -ForegroundColor White
    Write-Host "3. Try different Access versions" -ForegroundColor White
}

# Simple script to verify what tables exist in the Access database
$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflowManual.accdb"

Write-Host "Checking Access Database Tables..." -ForegroundColor Green
Write-Host "Database: $DatabasePath" -ForegroundColor Cyan

if (!(Test-Path $DatabasePath)) {
    Write-Host "❌ Database file does not exist!" -ForegroundColor Red
    Write-Host "Available .accdb files:" -ForegroundColor Yellow
    Get-ChildItem -Path "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\*.accdb" | ForEach-Object {
        Write-Host "  - $($_.Name) ($($_.Length) bytes)" -ForegroundColor Gray
    }
    exit 1
}

try {
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath;Persist Security Info=False;"
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()
    
    Write-Host "✓ Connected to database" -ForegroundColor Green
    
    # Get all tables
    $schema = $connection.GetSchema("Tables")
    
    Write-Host "`nTables found:" -ForegroundColor Yellow
    $tableCount = 0
    foreach ($row in $schema.Rows) {
        if ($row["TABLE_TYPE"] -eq "TABLE") {
            $tableCount++
            $tableName = $row["TABLE_NAME"]
            Write-Host "  $tableCount. $tableName" -ForegroundColor White
        }
    }
    
    if ($tableCount -eq 0) {
        Write-Host "❌ NO TABLES FOUND!" -ForegroundColor Red
        Write-Host "The database exists but is empty." -ForegroundColor Yellow
    } else {
        Write-Host "`nTotal tables: $tableCount" -ForegroundColor Cyan
        
        # Check specifically for Questions table
        $hasQuestions = $false
        foreach ($row in $schema.Rows) {
            if ($row["TABLE_TYPE"] -eq "TABLE" -and $row["TABLE_NAME"] -eq "Questions") {
                $hasQuestions = $true
                break
            }
        }
        
        if ($hasQuestions) {
            Write-Host "✓ Questions table exists" -ForegroundColor Green
        } else {
            Write-Host "❌ Questions table NOT found" -ForegroundColor Red
        }
    }
    
    $connection.Close()
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# PowerShell script to verify Microsoft Access database and list all tables
param(
    [string]$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflowComplete.accdb"
)

Write-Host "Verifying Microsoft Access database..." -ForegroundColor Green
Write-Host "Database path: $DatabasePath" -ForegroundColor Cyan

# Check if database file exists
if (!(Test-Path $DatabasePath)) {
    Write-Host "ERROR: Database file does not exist at: $DatabasePath" -ForegroundColor Red
    Write-Host "Available files in Database directory:" -ForegroundColor Yellow
    Get-ChildItem -Path (Split-Path $DatabasePath -Parent) | ForEach-Object {
        Write-Host "  - $($_.Name) ($($_.Length) bytes)" -ForegroundColor Gray
    }
    exit 1
}

Write-Host "✓ Database file exists ($((Get-Item $DatabasePath).Length) bytes)" -ForegroundColor Green

# Test OLEDB connection
Write-Host "`nTesting OLEDB connection..." -ForegroundColor Yellow

$connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath;Persist Security Info=False;"
Write-Host "Connection string: $connectionString" -ForegroundColor Gray

try {
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()
    Write-Host "✓ Successfully connected to database" -ForegroundColor Green
    
    # Get database schema to list all tables
    Write-Host "`nRetrieving table list..." -ForegroundColor Yellow
    
    $tables = $connection.GetSchema("Tables")
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "TABLES FOUND IN DATABASE:" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
    $tableCount = 0
    $identityTables = @()
    $applicationTables = @()
    $systemTables = @()
    
    foreach ($row in $tables.Rows) {
        $tableName = $row["TABLE_NAME"]
        $tableType = $row["TABLE_TYPE"]
        
        # Only show user tables, not system tables
        if ($tableType -eq "TABLE") {
            $tableCount++
            Write-Host "$tableCount. $tableName" -ForegroundColor White
            
            # Categorize tables
            if ($tableName.StartsWith("AspNet")) {
                $identityTables += $tableName
            } elseif ($tableName -in @("Questions", "Answers", "Comments", "Tags", "QuestionTags", "Votes", "Flags")) {
                $applicationTables += $tableName
            } else {
                $systemTables += $tableName
            }
        }
    }
    
    if ($tableCount -eq 0) {
        Write-Host "❌ NO TABLES FOUND!" -ForegroundColor Red
        Write-Host "This indicates the database creation failed." -ForegroundColor Yellow
    } else {
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "TABLE SUMMARY:" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Total tables found: $tableCount" -ForegroundColor White
        
        if ($identityTables.Count -gt 0) {
            Write-Host "`nIDENTITY TABLES ($($identityTables.Count)):" -ForegroundColor Yellow
            $identityTables | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
        }
        
        if ($applicationTables.Count -gt 0) {
            Write-Host "`nAPPLICATION TABLES ($($applicationTables.Count)):" -ForegroundColor Yellow
            $applicationTables | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
        }
        
        if ($systemTables.Count -gt 0) {
            Write-Host "`nOTHER TABLES ($($systemTables.Count)):" -ForegroundColor Yellow
            $systemTables | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
        }
    }
    
    # Test specific table queries
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "TESTING TABLE QUERIES:" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
    $testTables = @("AspNetUsers", "AspNetRoles", "Questions", "Tags")
    
    foreach ($tableName in $testTables) {
        try {
            $command = New-Object System.Data.OleDb.OleDbCommand("SELECT COUNT(*) FROM [$tableName]", $connection)
            $count = $command.ExecuteScalar()
            Write-Host "✓ $tableName : $count records" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ $tableName : Table not found or query failed" -ForegroundColor Red
            Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
        }
    }
    
    # Test sample data
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "SAMPLE DATA VERIFICATION:" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
    try {
        $command = New-Object System.Data.OleDb.OleDbCommand("SELECT UserName, Email, DisplayName FROM AspNetUsers", $connection)
        $reader = $command.ExecuteReader()
        
        Write-Host "USERS FOUND:" -ForegroundColor Yellow
        $userCount = 0
        while ($reader.Read()) {
            $userCount++
            Write-Host "  $userCount. $($reader["DisplayName"]) ($($reader["Email"]))" -ForegroundColor White
        }
        $reader.Close()
        
        if ($userCount -eq 0) {
            Write-Host "  No users found in database" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "❌ Could not retrieve user data: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    try {
        $command = New-Object System.Data.OleDb.OleDbCommand("SELECT Name, Description FROM Tags", $connection)
        $reader = $command.ExecuteReader()
        
        Write-Host "`nTAGS FOUND:" -ForegroundColor Yellow
        $tagCount = 0
        while ($reader.Read()) {
            $tagCount++
            Write-Host "  $tagCount. $($reader["Name"]) - $($reader["Description"])" -ForegroundColor White
        }
        $reader.Close()
        
        if ($tagCount -eq 0) {
            Write-Host "  No tags found in database" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "❌ Could not retrieve tag data: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    $connection.Close()
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "VERIFICATION COMPLETE" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
    if ($tableCount -gt 0) {
        Write-Host "✅ Database verification SUCCESSFUL!" -ForegroundColor Green
        Write-Host "The database contains $tableCount tables and appears to be working correctly." -ForegroundColor White
        Write-Host "`nIf you can't see tables in Microsoft Access:" -ForegroundColor Yellow
        Write-Host "1. Make sure you're opening the correct file: $DatabasePath" -ForegroundColor White
        Write-Host "2. Try refreshing the view in Access (F5)" -ForegroundColor White
        Write-Host "3. Check if tables are hidden (View > Navigation Pane > Object Type)" -ForegroundColor White
        Write-Host "4. Try closing and reopening the database file" -ForegroundColor White
    } else {
        Write-Host "❌ Database verification FAILED!" -ForegroundColor Red
        Write-Host "The database exists but contains no tables. The creation script may have failed." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "❌ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPossible causes:" -ForegroundColor Yellow
    Write-Host "1. Microsoft Access Database Engine not installed" -ForegroundColor White
    Write-Host "2. Database file is corrupted" -ForegroundColor White
    Write-Host "3. Insufficient permissions" -ForegroundColor White
    Write-Host "4. Database file is locked by another process" -ForegroundColor White
    
    Write-Host "`nTrying alternative connection methods..." -ForegroundColor Yellow
    
    # Try with different connection strings
    $altConnectionStrings = @(
        "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=$DatabasePath;",
        "Provider=Microsoft.ACE.OLEDB.15.0;Data Source=$DatabasePath;",
        "Provider=Microsoft.ACE.OLEDB.16.0;Data Source=$DatabasePath;"
    )
    
    foreach ($altConnString in $altConnectionStrings) {
        try {
            Write-Host "Trying: $altConnString" -ForegroundColor Gray
            $altConnection = New-Object System.Data.OleDb.OleDbConnection($altConnString)
            $altConnection.Open()
            Write-Host "✓ Alternative connection successful!" -ForegroundColor Green
            $altConnection.Close()
            break
        }
        catch {
            Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
    if ($connection) {
        $connection.Dispose()
    }
}

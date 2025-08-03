# Reliable PowerShell script to create Access database
$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflowWorking.accdb"

Write-Host "Creating Access Database (Reliable Method)..." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Remove existing database
if (Test-Path $DatabasePath) {
    Remove-Item $DatabasePath -Force
    Write-Host "✓ Removed existing database" -ForegroundColor Yellow
}

try {
    # Load required assemblies
    Add-Type -AssemblyName System.Data
    
    # Create database using ADOX
    $adox = New-Object -ComObject ADOX.Catalog
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath"
    $adox.Create($connectionString)
    Write-Host "✓ Database file created" -ForegroundColor Green
    
    # Release ADOX
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($adox) | Out-Null
    
    # Connect with OleDb
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()
    Write-Host "✓ Connected to database" -ForegroundColor Green
    
    # Create tables with simple, working SQL
    $tables = @{
        "AspNetUsers" = "CREATE TABLE AspNetUsers (Id TEXT(450) PRIMARY KEY, UserName TEXT(256), Email TEXT(256), DisplayName TEXT(100), Reputation LONG, CreatedAt DATETIME)"
        "AspNetRoles" = "CREATE TABLE AspNetRoles (Id TEXT(450) PRIMARY KEY, Name TEXT(256))"
        "Questions" = "CREATE TABLE Questions (Id AUTOINCREMENT PRIMARY KEY, Title TEXT(300), Body MEMO, Views LONG, Score LONG, CreatedAt DATETIME, UserId TEXT(450))"
        "Answers" = "CREATE TABLE Answers (Id AUTOINCREMENT PRIMARY KEY, QuestionId LONG, Body MEMO, Score LONG, CreatedAt DATETIME, UserId TEXT(450))"
        "Tags" = "CREATE TABLE Tags (Id AUTOINCREMENT PRIMARY KEY, Name TEXT(50), Description TEXT(500), CreatedAt DATETIME)"
        "Votes" = "CREATE TABLE Votes (Id AUTOINCREMENT PRIMARY KEY, VoteType LONG, QuestionId LONG, AnswerId LONG, UserId TEXT(450), CreatedAt DATETIME)"
    }
    
    # Create each table
    foreach ($tableName in $tables.Keys) {
        try {
            $command = New-Object System.Data.OleDb.OleDbCommand($tables[$tableName], $connection)
            $command.ExecuteNonQuery()
            Write-Host "✓ Created table: $tableName" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Failed to create $tableName" -ForegroundColor Red
        }
    }
    
    # Insert sample data
    Write-Host "`nInserting sample data..." -ForegroundColor Yellow
    
    $sampleData = @(
        "INSERT INTO AspNetRoles (Id, Name) VALUES ('admin', 'Admin')",
        "INSERT INTO AspNetRoles (Id, Name) VALUES ('user', 'User')",
        "INSERT INTO AspNetUsers (Id, UserName, Email, DisplayName, Reputation, CreatedAt) VALUES ('admin1', 'admin@test.com', 'admin@test.com', 'Administrator', 1000, Now())",
        "INSERT INTO AspNetUsers (Id, UserName, Email, DisplayName, Reputation, CreatedAt) VALUES ('user1', 'user@test.com', 'user@test.com', 'Test User', 100, Now())",
        "INSERT INTO Tags (Name, Description, CreatedAt) VALUES ('javascript', 'JavaScript programming', Now())",
        "INSERT INTO Tags (Name, Description, CreatedAt) VALUES ('csharp', 'C# programming', Now())",
        "INSERT INTO Tags (Name, Description, CreatedAt) VALUES ('html', 'HTML markup', Now())",
        "INSERT INTO Questions (Title, Body, Views, Score, CreatedAt, UserId) VALUES ('Welcome Question', 'This is a test question for our Stack Overflow clone.', 1, 0, Now(), 'user1')"
    )
    
    foreach ($sql in $sampleData) {
        try {
            $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
            $command.ExecuteNonQuery()
        }
        catch {
            Write-Host "Warning: Could not insert some sample data" -ForegroundColor Yellow
        }
    }
    
    Write-Host "✓ Sample data inserted" -ForegroundColor Green
    
    # Verify database
    Write-Host "`nVerifying database..." -ForegroundColor Yellow
    $schema = $connection.GetSchema("Tables")
    $tableCount = 0
    
    Write-Host "`nTables created:" -ForegroundColor Cyan
    foreach ($row in $schema.Rows) {
        if ($row["TABLE_TYPE"] -eq "TABLE") {
            $tableCount++
            $tableName = $row["TABLE_NAME"]
            Write-Host "  $tableCount. $tableName" -ForegroundColor White
            
            # Count records
            try {
                $countCmd = New-Object System.Data.OleDb.OleDbCommand("SELECT COUNT(*) FROM [$tableName]", $connection)
                $count = $countCmd.ExecuteScalar()
                Write-Host "     → $count records" -ForegroundColor Gray
            }
            catch {
                Write-Host "     → Could not count records" -ForegroundColor Gray
            }
        }
    }
    
    $connection.Close()
    
    Write-Host "`n🎉 SUCCESS!" -ForegroundColor Green
    Write-Host "Database created successfully!" -ForegroundColor White
    Write-Host "Location: $DatabasePath" -ForegroundColor Cyan
    Write-Host "Tables: $tableCount" -ForegroundColor White
    Write-Host "`nYou can now:" -ForegroundColor Yellow
    Write-Host "1. Open the .accdb file in Microsoft Access" -ForegroundColor White
    Write-Host "2. Update your appsettings.json connection string" -ForegroundColor White
    Write-Host "3. Run your ASP.NET Core application" -ForegroundColor White
    
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Make sure Microsoft Access Database Engine is installed" -ForegroundColor White
    Write-Host "2. Check if you have permissions to create files in the directory" -ForegroundColor White
    Write-Host "3. Ensure no other process is using a database file with the same name" -ForegroundColor White
}
finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}

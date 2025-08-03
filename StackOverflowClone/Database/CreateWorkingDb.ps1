# Create a working Access database with the Questions table
$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflowWorking.accdb"

Write-Host "Creating Working Access Database..." -ForegroundColor Green

# Remove existing database
if (Test-Path $DatabasePath) {
    Remove-Item $DatabasePath -Force
    Write-Host "Removed existing database" -ForegroundColor Yellow
}

try {
    # Create database using ADOX
    $adox = New-Object -ComObject ADOX.Catalog
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath"
    $adox.Create($connectionString)
    Write-Host "✓ Database created" -ForegroundColor Green
    
    # Release ADOX
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($adox) | Out-Null
    
    # Connect and create tables
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()
    Write-Host "✓ Connected" -ForegroundColor Green
    
    # Create Questions table (this is the one causing the error)
    $sql = "CREATE TABLE Questions (Id AUTOINCREMENT PRIMARY KEY, Title TEXT(300), Body MEMO, Views LONG, Score LONG, CreatedAt DATETIME, UserId TEXT(450))"
    $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $command.ExecuteNonQuery()
    Write-Host "✓ Created Questions table" -ForegroundColor Green
    
    # Create other essential tables
    $sql = "CREATE TABLE AspNetUsers (Id TEXT(450) PRIMARY KEY, UserName TEXT(256), Email TEXT(256), DisplayName TEXT(100), Reputation LONG, CreatedAt DATETIME)"
    $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $command.ExecuteNonQuery()
    Write-Host "✓ Created AspNetUsers table" -ForegroundColor Green
    
    $sql = "CREATE TABLE Tags (Id AUTOINCREMENT PRIMARY KEY, Name TEXT(50), Description TEXT(500), CreatedAt DATETIME)"
    $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $command.ExecuteNonQuery()
    Write-Host "✓ Created Tags table" -ForegroundColor Green
    
    $sql = "CREATE TABLE Answers (Id AUTOINCREMENT PRIMARY KEY, QuestionId LONG, Body MEMO, Score LONG, CreatedAt DATETIME, UserId TEXT(450))"
    $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $command.ExecuteNonQuery()
    Write-Host "✓ Created Answers table" -ForegroundColor Green
    
    # Insert sample data
    Write-Host "Inserting sample data..." -ForegroundColor Yellow
    
    # Insert sample user
    $sql = "INSERT INTO AspNetUsers (Id, UserName, Email, DisplayName, Reputation, CreatedAt) VALUES ('user1', 'test@example.com', 'test@example.com', 'Test User', 100, Now())"
    $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $command.ExecuteNonQuery()
    
    # Insert sample question
    $sql = "INSERT INTO Questions (Title, Body, Views, Score, CreatedAt, UserId) VALUES ('Sample Question', 'This is a test question to verify the database works.', 1, 0, Now(), 'user1')"
    $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $command.ExecuteNonQuery()
    
    # Insert sample tags
    $sql = "INSERT INTO Tags (Name, Description, CreatedAt) VALUES ('test', 'Test tag', Now())"
    $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $command.ExecuteNonQuery()
    
    Write-Host "✓ Sample data inserted" -ForegroundColor Green
    
    # Verify tables
    $schema = $connection.GetSchema("Tables")
    Write-Host "`nTables created:" -ForegroundColor Cyan
    $tableCount = 0
    foreach ($row in $schema.Rows) {
        if ($row["TABLE_TYPE"] -eq "TABLE") {
            $tableCount++
            Write-Host "  $($row["TABLE_NAME"])" -ForegroundColor White
        }
    }
    
    $connection.Close()
    
    Write-Host "`n🎉 SUCCESS!" -ForegroundColor Green
    Write-Host "Database: $DatabasePath" -ForegroundColor Cyan
    Write-Host "Tables: $tableCount" -ForegroundColor White
    Write-Host "`nNow update appsettings.json to use this database!" -ForegroundColor Yellow
    
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}

# Fixed script to create StackOverflowApp.accdb with correct field sizes
$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflowApp.accdb"

Write-Host "Creating StackOverflowApp.accdb with correct field sizes..." -ForegroundColor Green

# Remove existing file if it exists
if (Test-Path $DatabasePath) {
    Remove-Item $DatabasePath -Force
    Write-Host "Removed existing database" -ForegroundColor Yellow
}

try {
    # Create database using ADOX
    $adox = New-Object -ComObject ADOX.Catalog
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath"
    $adox.Create($connectionString)
    Write-Host "✓ Database file created" -ForegroundColor Green
    
    # Release ADOX
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($adox) | Out-Null
    
    # Connect and create tables with correct field sizes
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()
    Write-Host "✓ Connected to database" -ForegroundColor Green
    
    # Create Questions table with smaller field sizes
    $command = New-Object System.Data.OleDb.OleDbCommand("CREATE TABLE Questions (Id AUTOINCREMENT PRIMARY KEY, Title TEXT(255), Body MEMO, Views LONG, Score LONG, CreatedAt DATETIME, UserId TEXT(255))", $connection)
    $command.ExecuteNonQuery()
    Write-Host "✓ Questions table created" -ForegroundColor Green
    
    # Create Tags table
    $command = New-Object System.Data.OleDb.OleDbCommand("CREATE TABLE Tags (Id AUTOINCREMENT PRIMARY KEY, Name TEXT(50), Description TEXT(255), CreatedAt DATETIME)", $connection)
    $command.ExecuteNonQuery()
    Write-Host "✓ Tags table created" -ForegroundColor Green
    
    # Create Answers table
    $command = New-Object System.Data.OleDb.OleDbCommand("CREATE TABLE Answers (Id AUTOINCREMENT PRIMARY KEY, QuestionId LONG, Body MEMO, Score LONG, CreatedAt DATETIME, UserId TEXT(255))", $connection)
    $command.ExecuteNonQuery()
    Write-Host "✓ Answers table created" -ForegroundColor Green
    
    # Insert test data with shorter text
    $command = New-Object System.Data.OleDb.OleDbCommand("INSERT INTO Questions (Title, Body, Views, Score, CreatedAt, UserId) VALUES ('Welcome to Stack Overflow Clone', 'This is a test question.', 1, 0, Now(), 'test-user')", $connection)
    $command.ExecuteNonQuery()
    Write-Host "✓ Sample question inserted" -ForegroundColor Green
    
    $command = New-Object System.Data.OleDb.OleDbCommand("INSERT INTO Tags (Name, Description, CreatedAt) VALUES ('test', 'Test tag', Now())", $connection)
    $command.ExecuteNonQuery()
    Write-Host "✓ Sample tag inserted" -ForegroundColor Green
    
    $connection.Close()
    
    Write-Host "`n🎉 SUCCESS!" -ForegroundColor Green
    Write-Host "Database created at: $DatabasePath" -ForegroundColor Cyan
    Write-Host "Ready to run the application!" -ForegroundColor White
    
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}

# Create a fresh Access database without file locking issues
$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflowApp.accdb"

Write-Host "Creating fresh Access database..." -ForegroundColor Green

# Remove existing database and lock files
if (Test-Path $DatabasePath) {
    Remove-Item $DatabasePath -Force
    Write-Host "Removed existing database" -ForegroundColor Yellow
}

$lockFile = $DatabasePath.Replace(".accdb", ".laccdb")
if (Test-Path $lockFile) {
    Remove-Item $lockFile -Force
    Write-Host "Removed lock file" -ForegroundColor Yellow
}

try {
    # Create database using ADOX
    $adox = New-Object -ComObject ADOX.Catalog
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath"
    $adox.Create($connectionString)
    Write-Host "✓ Database created" -ForegroundColor Green
    
    # Release ADOX immediately
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($adox) | Out-Null
    
    # Connect and create essential tables
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()
    Write-Host "✓ Connected" -ForegroundColor Green
    
    # Create Questions table (essential for the app)
    $sql = "CREATE TABLE Questions (Id AUTOINCREMENT PRIMARY KEY, Title TEXT(300), Body MEMO, Views LONG, Score LONG, CreatedAt DATETIME, UserId TEXT(450))"
    $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $command.ExecuteNonQuery()
    Write-Host "✓ Created Questions table" -ForegroundColor Green
    
    # Create Tags table
    $sql = "CREATE TABLE Tags (Id AUTOINCREMENT PRIMARY KEY, Name TEXT(50), Description TEXT(500), CreatedAt DATETIME)"
    $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $command.ExecuteNonQuery()
    Write-Host "✓ Created Tags table" -ForegroundColor Green
    
    # Create Answers table
    $sql = "CREATE TABLE Answers (Id AUTOINCREMENT PRIMARY KEY, QuestionId LONG, Body MEMO, Score LONG, CreatedAt DATETIME, UserId TEXT(450))"
    $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $command.ExecuteNonQuery()
    Write-Host "✓ Created Answers table" -ForegroundColor Green
    
    # Insert minimal test data
    $sql = "INSERT INTO Questions (Title, Body, Views, Score, CreatedAt, UserId) VALUES ('Test Question', 'This is a test question to verify the database works.', 1, 0, Now(), 'test-user')"
    $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $command.ExecuteNonQuery()
    
    $sql = "INSERT INTO Tags (Name, Description, CreatedAt) VALUES ('test', 'Test tag', Now())"
    $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
    $command.ExecuteNonQuery()
    
    Write-Host "✓ Sample data inserted" -ForegroundColor Green
    
    $connection.Close()
    
    Write-Host "`n🎉 SUCCESS!" -ForegroundColor Green
    Write-Host "Fresh database created: $DatabasePath" -ForegroundColor Cyan
    Write-Host "No file locking issues!" -ForegroundColor White
    
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}

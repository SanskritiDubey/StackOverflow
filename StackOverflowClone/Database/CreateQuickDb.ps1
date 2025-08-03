# Quick script to create the missing StackOverflowApp.accdb database
$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflowApp.accdb"

Write-Host "Creating StackOverflowApp.accdb database..." -ForegroundColor Green

try {
    # Create database using ADOX
    $adox = New-Object -ComObject ADOX.Catalog
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath"
    $adox.Create($connectionString)
    Write-Host "Database file created" -ForegroundColor Green
    
    # Release ADOX
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($adox) | Out-Null
    
    # Connect and create tables
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()
    
    # Create Questions table
    $command = New-Object System.Data.OleDb.OleDbCommand("CREATE TABLE Questions (Id AUTOINCREMENT PRIMARY KEY, Title TEXT(300), Body MEMO, Views LONG, Score LONG, CreatedAt DATETIME, UserId TEXT(450))", $connection)
    $command.ExecuteNonQuery()
    Write-Host "Questions table created" -ForegroundColor Green
    
    # Create Tags table
    $command = New-Object System.Data.OleDb.OleDbCommand("CREATE TABLE Tags (Id AUTOINCREMENT PRIMARY KEY, Name TEXT(50), Description TEXT(500), CreatedAt DATETIME)", $connection)
    $command.ExecuteNonQuery()
    Write-Host "Tags table created" -ForegroundColor Green
    
    # Create Answers table
    $command = New-Object System.Data.OleDb.OleDbCommand("CREATE TABLE Answers (Id AUTOINCREMENT PRIMARY KEY, QuestionId LONG, Body MEMO, Score LONG, CreatedAt DATETIME, UserId TEXT(450))", $connection)
    $command.ExecuteNonQuery()
    Write-Host "Answers table created" -ForegroundColor Green
    
    # Insert test data
    $command = New-Object System.Data.OleDb.OleDbCommand("INSERT INTO Questions (Title, Body, Views, Score, CreatedAt, UserId) VALUES ('Welcome Question', 'This is a test question for the Stack Overflow clone.', 1, 0, Now(), 'test-user')", $connection)
    $command.ExecuteNonQuery()
    
    $command = New-Object System.Data.OleDb.OleDbCommand("INSERT INTO Tags (Name, Description, CreatedAt) VALUES ('test', 'Test tag', Now())", $connection)
    $command.ExecuteNonQuery()
    
    Write-Host "Sample data inserted" -ForegroundColor Green
    
    $connection.Close()
    
    Write-Host "SUCCESS! Database created at: $DatabasePath" -ForegroundColor Green
    
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}

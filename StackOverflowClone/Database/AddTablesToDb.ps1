# Add essential tables to the existing StackOverflowApp.accdb database
$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflowApp.accdb"

Write-Host "Adding tables to existing database..." -ForegroundColor Green

try {
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath"
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()
    Write-Host "Connected to database" -ForegroundColor Green
    
    # Create Questions table
    try {
        $sql = "CREATE TABLE Questions (Id AUTOINCREMENT PRIMARY KEY, Title TEXT(255), Body MEMO, Views LONG, Score LONG, CreatedAt DATETIME, UserId TEXT(255))"
        $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
        $command.ExecuteNonQuery()
        Write-Host "Questions table created" -ForegroundColor Green
    }
    catch {
        Write-Host "Questions table may already exist" -ForegroundColor Yellow
    }
    
    # Create Tags table
    try {
        $sql = "CREATE TABLE Tags (Id AUTOINCREMENT PRIMARY KEY, Name TEXT(50), Description TEXT(255), CreatedAt DATETIME)"
        $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
        $command.ExecuteNonQuery()
        Write-Host "Tags table created" -ForegroundColor Green
    }
    catch {
        Write-Host "Tags table may already exist" -ForegroundColor Yellow
    }
    
    # Create Answers table
    try {
        $sql = "CREATE TABLE Answers (Id AUTOINCREMENT PRIMARY KEY, QuestionId LONG, Body MEMO, Score LONG, CreatedAt DATETIME, UserId TEXT(255))"
        $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
        $command.ExecuteNonQuery()
        Write-Host "Answers table created" -ForegroundColor Green
    }
    catch {
        Write-Host "Answers table may already exist" -ForegroundColor Yellow
    }
    
    $connection.Close()
    Write-Host "SUCCESS! Tables added to database" -ForegroundColor Green
    
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}

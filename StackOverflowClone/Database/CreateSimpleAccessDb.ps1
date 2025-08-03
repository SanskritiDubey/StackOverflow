# Simple PowerShell script to create a basic Access database
param(
    [string]$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflow.accdb"
)

Write-Host "Creating simple Access database..." -ForegroundColor Green

# Ensure the Database directory exists
$DatabaseDir = Split-Path $DatabasePath -Parent
if (!(Test-Path $DatabaseDir)) {
    New-Item -ItemType Directory -Path $DatabaseDir -Force
}

try {
    # Try to create using ADOX (ActiveX Data Objects Extensions)
    $adox = New-Object -ComObject ADOX.Catalog
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath"
    $adox.Create($connectionString)
    
    Write-Host "Access database created successfully at: $DatabasePath" -ForegroundColor Green
    
    # Create basic tables using OleDb
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()
    
    # Create Questions table
    $command = New-Object System.Data.OleDb.OleDbCommand
    $command.Connection = $connection
    $command.CommandText = @"
CREATE TABLE Questions (
    Id AUTOINCREMENT PRIMARY KEY,
    Title TEXT(300) NOT NULL,
    Body MEMO NOT NULL,
    Views INTEGER DEFAULT 0,
    Score INTEGER DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    UpdatedAt DATETIME,
    IsAnswered YESNO DEFAULT No,
    AcceptedAnswerId INTEGER,
    IsClosed YESNO DEFAULT No,
    CloseReason TEXT(500),
    UserId TEXT(450) NOT NULL
)
"@
    $command.ExecuteNonQuery()
    Write-Host "Created Questions table" -ForegroundColor Gray
    
    # Create Answers table
    $command.CommandText = @"
CREATE TABLE Answers (
    Id AUTOINCREMENT PRIMARY KEY,
    QuestionId INTEGER NOT NULL,
    Body MEMO NOT NULL,
    Score INTEGER DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    UpdatedAt DATETIME,
    IsAccepted YESNO DEFAULT No,
    UserId TEXT(450) NOT NULL
)
"@
    $command.ExecuteNonQuery()
    Write-Host "Created Answers table" -ForegroundColor Gray
    
    # Create Tags table
    $command.CommandText = @"
CREATE TABLE Tags (
    Id AUTOINCREMENT PRIMARY KEY,
    Name TEXT(50) NOT NULL,
    Description TEXT(500),
    UsageCount INTEGER DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    WikiExcerpt MEMO
)
"@
    $command.ExecuteNonQuery()
    Write-Host "Created Tags table" -ForegroundColor Gray
    
    # Create QuestionTags table
    $command.CommandText = @"
CREATE TABLE QuestionTags (
    QuestionId INTEGER NOT NULL,
    TagId INTEGER NOT NULL
)
"@
    $command.ExecuteNonQuery()
    Write-Host "Created QuestionTags table" -ForegroundColor Gray
    
    # Create Votes table
    $command.CommandText = @"
CREATE TABLE Votes (
    Id AUTOINCREMENT PRIMARY KEY,
    VoteType INTEGER NOT NULL,
    CreatedAt DATETIME NOT NULL,
    QuestionId INTEGER,
    AnswerId INTEGER,
    CommentId INTEGER,
    UserId TEXT(450) NOT NULL
)
"@
    $command.ExecuteNonQuery()
    Write-Host "Created Votes table" -ForegroundColor Gray
    
    # Insert sample tags
    $command.CommandText = "INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) VALUES ('javascript', 'JavaScript programming language', 0, Now())"
    $command.ExecuteNonQuery()
    
    $command.CommandText = "INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) VALUES ('csharp', 'C# programming language', 0, Now())"
    $command.ExecuteNonQuery()
    
    $command.CommandText = "INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) VALUES ('asp.net', 'ASP.NET framework', 0, Now())"
    $command.ExecuteNonQuery()
    
    Write-Host "Inserted sample tags" -ForegroundColor Gray
    
    $connection.Close()
    $connection.Dispose()
    
    Write-Host "Database setup completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Error creating database: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Trying alternative method..." -ForegroundColor Yellow
    
    # Alternative: Create empty file and let the application handle it
    if (!(Test-Path $DatabasePath)) {
        New-Item -ItemType File -Path $DatabasePath -Force
        Write-Host "Created empty database file. Application will initialize it." -ForegroundColor Yellow
    }
}

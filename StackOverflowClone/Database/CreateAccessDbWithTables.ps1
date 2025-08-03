# PowerShell script to create Microsoft Access database with visible tables
param(
    [string]$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflow.accdb"
)

Write-Host "Creating Microsoft Access database with visible tables..." -ForegroundColor Green

# Ensure the Database directory exists
$DatabaseDir = Split-Path $DatabasePath -Parent
if (!(Test-Path $DatabaseDir)) {
    New-Item -ItemType Directory -Path $DatabaseDir -Force
}

# Remove existing database if it exists
if (Test-Path $DatabasePath) {
    Remove-Item $DatabasePath -Force
    Write-Host "Removed existing database" -ForegroundColor Yellow
}

try {
    # Create new Access database using DAO (Data Access Objects)
    $access = New-Object -ComObject Access.Application
    $access.Visible = $false
    
    # Create new database
    $db = $access.DBEngine.CreateDatabase($DatabasePath, ";LANGID=0x0409;CP=1252;COUNTRY=0")
    
    Write-Host "Created new Access database: $DatabasePath" -ForegroundColor Green
    
    # Create Questions table
    $sql = @"
CREATE TABLE Questions (
    Id COUNTER PRIMARY KEY,
    Title TEXT(300) NOT NULL,
    Body MEMO NOT NULL,
    Views LONG DEFAULT 0,
    Score LONG DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    UpdatedAt DATETIME,
    IsAnswered YESNO DEFAULT No,
    AcceptedAnswerId LONG,
    IsClosed YESNO DEFAULT No,
    CloseReason TEXT(500),
    UserId TEXT(450) NOT NULL
)
"@
    $db.Execute($sql)
    Write-Host "Created Questions table" -ForegroundColor Gray
    
    # Create Answers table
    $sql = @"
CREATE TABLE Answers (
    Id COUNTER PRIMARY KEY,
    QuestionId LONG NOT NULL,
    Body MEMO NOT NULL,
    Score LONG DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    UpdatedAt DATETIME,
    IsAccepted YESNO DEFAULT No,
    UserId TEXT(450) NOT NULL
)
"@
    $db.Execute($sql)
    Write-Host "Created Answers table" -ForegroundColor Gray
    
    # Create Comments table
    $sql = @"
CREATE TABLE Comments (
    Id COUNTER PRIMARY KEY,
    Body TEXT(600) NOT NULL,
    Score LONG DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    UpdatedAt DATETIME,
    QuestionId LONG,
    AnswerId LONG,
    UserId TEXT(450) NOT NULL
)
"@
    $db.Execute($sql)
    Write-Host "Created Comments table" -ForegroundColor Gray
    
    # Create Tags table
    $sql = @"
CREATE TABLE Tags (
    Id COUNTER PRIMARY KEY,
    Name TEXT(50) NOT NULL,
    Description TEXT(500),
    UsageCount LONG DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    WikiExcerpt MEMO
)
"@
    $db.Execute($sql)
    Write-Host "Created Tags table" -ForegroundColor Gray
    
    # Create QuestionTags table
    $sql = @"
CREATE TABLE QuestionTags (
    QuestionId LONG NOT NULL,
    TagId LONG NOT NULL
)
"@
    $db.Execute($sql)
    Write-Host "Created QuestionTags table" -ForegroundColor Gray
    
    # Create Votes table
    $sql = @"
CREATE TABLE Votes (
    Id COUNTER PRIMARY KEY,
    VoteType LONG NOT NULL,
    CreatedAt DATETIME NOT NULL,
    QuestionId LONG,
    AnswerId LONG,
    CommentId LONG,
    UserId TEXT(450) NOT NULL
)
"@
    $db.Execute($sql)
    Write-Host "Created Votes table" -ForegroundColor Gray
    
    # Create Flags table
    $sql = @"
CREATE TABLE Flags (
    Id COUNTER PRIMARY KEY,
    FlagType LONG NOT NULL,
    Status LONG DEFAULT 0,
    Reason TEXT(500),
    CreatedAt DATETIME NOT NULL,
    ResolvedAt DATETIME,
    ResolvedByUserId TEXT(450),
    QuestionId LONG,
    AnswerId LONG,
    CommentId LONG,
    UserId TEXT(450) NOT NULL
)
"@
    $db.Execute($sql)
    Write-Host "Created Flags table" -ForegroundColor Gray
    
    # Insert sample tags
    $sql = "INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) VALUES ('javascript', 'JavaScript programming language', 0, Now())"
    $db.Execute($sql)
    
    $sql = "INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) VALUES ('csharp', 'C# programming language', 0, Now())"
    $db.Execute($sql)
    
    $sql = "INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) VALUES ('asp.net', 'ASP.NET framework', 0, Now())"
    $db.Execute($sql)
    
    $sql = "INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) VALUES ('html', 'HTML markup language', 0, Now())"
    $db.Execute($sql)
    
    $sql = "INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) VALUES ('css', 'CSS styling', 0, Now())"
    $db.Execute($sql)
    
    Write-Host "Inserted sample tags" -ForegroundColor Gray
    
    # Insert a sample question for testing
    $sql = @"
INSERT INTO Questions (Title, Body, Views, Score, CreatedAt, IsAnswered, IsClosed, UserId) 
VALUES ('Welcome to Stack Overflow Clone!', 'This is a sample question to test the application. You can ask your programming questions here and get answers from the community.', 1, 0, Now(), No, No, 'sample-user-id')
"@
    $db.Execute($sql)
    Write-Host "Inserted sample question" -ForegroundColor Gray
    
    # Close database and Access
    $db.Close()
    $access.Quit()
    
    # Release COM objects
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($db) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($access) | Out-Null
    
    Write-Host "Database setup completed successfully!" -ForegroundColor Green
    Write-Host "Database location: $DatabasePath" -ForegroundColor Cyan
    Write-Host "You can now open this file in Microsoft Access to see the tables." -ForegroundColor Cyan
    
    # Test connection
    Write-Host "Testing database connection..." -ForegroundColor Yellow
    
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath;Persist Security Info=False;"
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    
    try {
        $connection.Open()
        $command = New-Object System.Data.OleDb.OleDbCommand("SELECT COUNT(*) FROM Tags", $connection)
        $tagCount = $command.ExecuteScalar()
        Write-Host "Connection test successful! Found $tagCount tags in database." -ForegroundColor Green
        
        $command = New-Object System.Data.OleDb.OleDbCommand("SELECT COUNT(*) FROM Questions", $connection)
        $questionCount = $command.ExecuteScalar()
        Write-Host "Found $questionCount questions in database." -ForegroundColor Green
        
        $connection.Close()
    }
    catch {
        Write-Host "Connection test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        if ($connection.State -eq 'Open') {
            $connection.Close()
        }
        $connection.Dispose()
    }
}
catch {
    Write-Host "Error setting up database: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please ensure Microsoft Access is installed." -ForegroundColor Yellow
    
    if ($access) {
        try {
            $access.Quit()
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($access) | Out-Null
        }
        catch {
            # Ignore cleanup errors
        }
    }
    
    exit 1
}

Write-Host "`nDatabase created successfully!" -ForegroundColor Green
Write-Host "You can now:" -ForegroundColor Cyan
Write-Host "1. Open '$DatabasePath' in Microsoft Access to view tables" -ForegroundColor White
Write-Host "2. Run 'dotnet run' to start the web application" -ForegroundColor White

# Create a working Access database using ADOX (more reliable than Access COM)
$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\WorkingStackOverflow.accdb"

Write-Host "Creating working Access database..." -ForegroundColor Green

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
    Write-Host "✓ Database file created" -ForegroundColor Green
    
    # Now connect with OLEDB to create tables
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    $connection.Open()
    Write-Host "✓ Connected to database" -ForegroundColor Green
    
    # Create tables one by one with error handling
    $tables = @{
        "AspNetUsers" = @"
CREATE TABLE AspNetUsers (
    Id TEXT(450) PRIMARY KEY,
    UserName TEXT(256),
    NormalizedUserName TEXT(256),
    Email TEXT(256),
    NormalizedEmail TEXT(256),
    EmailConfirmed YESNO DEFAULT No,
    PasswordHash MEMO,
    SecurityStamp MEMO,
    ConcurrencyStamp MEMO,
    PhoneNumber TEXT(50),
    PhoneNumberConfirmed YESNO DEFAULT No,
    TwoFactorEnabled YESNO DEFAULT No,
    LockoutEnd DATETIME,
    LockoutEnabled YESNO DEFAULT No,
    AccessFailedCount LONG DEFAULT 0,
    DisplayName TEXT(100),
    Bio TEXT(500),
    Reputation LONG DEFAULT 1,
    CreatedAt DATETIME,
    ProfileImageUrl TEXT(500),
    Location TEXT(100),
    Website TEXT(200)
)
"@
        "AspNetRoles" = @"
CREATE TABLE AspNetRoles (
    Id TEXT(450) PRIMARY KEY,
    Name TEXT(256),
    NormalizedName TEXT(256),
    ConcurrencyStamp MEMO
)
"@
        "Questions" = @"
CREATE TABLE Questions (
    Id AUTOINCREMENT PRIMARY KEY,
    Title TEXT(300),
    Body MEMO,
    Views LONG DEFAULT 0,
    Score LONG DEFAULT 0,
    CreatedAt DATETIME,
    UpdatedAt DATETIME,
    IsAnswered YESNO DEFAULT No,
    AcceptedAnswerId LONG,
    IsClosed YESNO DEFAULT No,
    CloseReason TEXT(500),
    UserId TEXT(450)
)
"@
        "Answers" = @"
CREATE TABLE Answers (
    Id AUTOINCREMENT PRIMARY KEY,
    QuestionId LONG,
    Body MEMO,
    Score LONG DEFAULT 0,
    CreatedAt DATETIME,
    UpdatedAt DATETIME,
    IsAccepted YESNO DEFAULT No,
    UserId TEXT(450)
)
"@
        "Tags" = @"
CREATE TABLE Tags (
    Id AUTOINCREMENT PRIMARY KEY,
    Name TEXT(50),
    Description TEXT(500),
    UsageCount LONG DEFAULT 0,
    CreatedAt DATETIME,
    WikiExcerpt MEMO
)
"@
    }
    
    # Create each table
    foreach ($tableName in $tables.Keys) {
        try {
            $command = New-Object System.Data.OleDb.OleDbCommand($tables[$tableName], $connection)
            $command.ExecuteNonQuery()
            Write-Host "✓ Created table: $tableName" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Failed to create $tableName : $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Insert sample data
    Write-Host "`nInserting sample data..." -ForegroundColor Yellow
    
    # Insert roles
    try {
        $sql = "INSERT INTO AspNetRoles (Id, Name, NormalizedName) VALUES ('admin-role', 'Admin', 'ADMIN')"
        $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
        $command.ExecuteNonQuery()
        Write-Host "✓ Inserted Admin role" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to insert role: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Insert sample user
    try {
        $sql = "INSERT INTO AspNetUsers (Id, UserName, Email, DisplayName, Reputation, CreatedAt) VALUES ('user1', 'admin@test.com', 'admin@test.com', 'Administrator', 1000, Now())"
        $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
        $command.ExecuteNonQuery()
        Write-Host "✓ Inserted sample user" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to insert user: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Insert sample tags
    $sampleTags = @("javascript", "csharp", "html", "css", "asp.net")
    foreach ($tag in $sampleTags) {
        try {
            $sql = "INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) VALUES ('$tag', '$tag programming', 0, Now())"
            $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
            $command.ExecuteNonQuery()
        }
        catch {
            Write-Host "Warning: Could not insert tag $tag" -ForegroundColor Yellow
        }
    }
    Write-Host "✓ Inserted sample tags" -ForegroundColor Green
    
    # Insert sample question
    try {
        $sql = "INSERT INTO Questions (Title, Body, Views, Score, CreatedAt, IsAnswered, IsClosed, UserId) VALUES ('Welcome Question', 'This is a test question to verify the database works correctly.', 1, 0, Now(), No, No, 'user1')"
        $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
        $command.ExecuteNonQuery()
        Write-Host "✓ Inserted sample question" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to insert question: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    $connection.Close()
    
    # Verify the database
    Write-Host "`nVerifying database..." -ForegroundColor Yellow
    $connection.Open()
    
    # List all tables
    $schema = $connection.GetSchema("Tables")
    Write-Host "`nTables created:" -ForegroundColor Cyan
    $tableCount = 0
    foreach ($row in $schema.Rows) {
        if ($row["TABLE_TYPE"] -eq "TABLE") {
            $tableCount++
            $tableName = $row["TABLE_NAME"]
            Write-Host "$tableCount. $tableName" -ForegroundColor White
            
            # Count records in each table
            try {
                $countCmd = New-Object System.Data.OleDb.OleDbCommand("SELECT COUNT(*) FROM [$tableName]", $connection)
                $count = $countCmd.ExecuteScalar()
                Write-Host "   → $count records" -ForegroundColor Gray
            }
            catch {
                Write-Host "   → Could not count records" -ForegroundColor Gray
            }
        }
    }
    
    $connection.Close()
    
    Write-Host "`n✅ SUCCESS!" -ForegroundColor Green
    Write-Host "Database created at: $DatabasePath" -ForegroundColor Cyan
    Write-Host "Total tables: $tableCount" -ForegroundColor White
    Write-Host "`nYou can now open this file in Microsoft Access to see the tables!" -ForegroundColor Yellow
    
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
    if ($adox) {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($adox) | Out-Null
    }
}

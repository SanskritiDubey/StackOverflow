# PowerShell script to create complete Microsoft Access database with Identity tables
# This includes all ASP.NET Core Identity tables for registration/login functionality
param(
    [string]$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflowComplete.accdb"
)

Write-Host "Creating complete Microsoft Access database with Identity and application tables..." -ForegroundColor Green

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
    
    # ========== ASP.NET CORE IDENTITY TABLES ==========
    
    # Create AspNetUsers table (Main user table)
    $sql = @"
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
    DisplayName TEXT(100) NOT NULL,
    Bio TEXT(500),
    Reputation LONG DEFAULT 1,
    CreatedAt DATETIME DEFAULT Now(),
    ProfileImageUrl TEXT(500),
    Location TEXT(100),
    Website TEXT(200)
)
"@
    $db.Execute($sql)
    Write-Host "Created AspNetUsers table" -ForegroundColor Gray
    
    # Create AspNetRoles table
    $sql = @"
CREATE TABLE AspNetRoles (
    Id TEXT(450) PRIMARY KEY,
    Name TEXT(256),
    NormalizedName TEXT(256),
    ConcurrencyStamp MEMO
)
"@
    $db.Execute($sql)
    Write-Host "Created AspNetRoles table" -ForegroundColor Gray
    
    # Create AspNetUserRoles table (Many-to-many between Users and Roles)
    $sql = @"
CREATE TABLE AspNetUserRoles (
    UserId TEXT(450) NOT NULL,
    RoleId TEXT(450) NOT NULL,
    PRIMARY KEY (UserId, RoleId)
)
"@
    $db.Execute($sql)
    Write-Host "Created AspNetUserRoles table" -ForegroundColor Gray
    
    # Create AspNetUserClaims table
    $sql = @"
CREATE TABLE AspNetUserClaims (
    Id COUNTER PRIMARY KEY,
    UserId TEXT(450) NOT NULL,
    ClaimType MEMO,
    ClaimValue MEMO
)
"@
    $db.Execute($sql)
    Write-Host "Created AspNetUserClaims table" -ForegroundColor Gray
    
    # Create AspNetUserLogins table (for external logins like Google, Facebook)
    $sql = @"
CREATE TABLE AspNetUserLogins (
    LoginProvider TEXT(450) NOT NULL,
    ProviderKey TEXT(450) NOT NULL,
    ProviderDisplayName MEMO,
    UserId TEXT(450) NOT NULL,
    PRIMARY KEY (LoginProvider, ProviderKey)
)
"@
    $db.Execute($sql)
    Write-Host "Created AspNetUserLogins table" -ForegroundColor Gray
    
    # Create AspNetUserTokens table
    $sql = @"
CREATE TABLE AspNetUserTokens (
    UserId TEXT(450) NOT NULL,
    LoginProvider TEXT(450) NOT NULL,
    Name TEXT(450) NOT NULL,
    Value MEMO,
    PRIMARY KEY (UserId, LoginProvider, Name)
)
"@
    $db.Execute($sql)
    Write-Host "Created AspNetUserTokens table" -ForegroundColor Gray
    
    # Create AspNetRoleClaims table
    $sql = @"
CREATE TABLE AspNetRoleClaims (
    Id COUNTER PRIMARY KEY,
    RoleId TEXT(450) NOT NULL,
    ClaimType MEMO,
    ClaimValue MEMO
)
"@
    $db.Execute($sql)
    Write-Host "Created AspNetRoleClaims table" -ForegroundColor Gray
    
    # ========== APPLICATION BUSINESS TABLES ==========
    
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
    
    # ========== INSERT SAMPLE DATA ==========
    
    # Insert default roles
    $adminRoleId = [System.Guid]::NewGuid().ToString()
    $moderatorRoleId = [System.Guid]::NewGuid().ToString()
    $userRoleId = [System.Guid]::NewGuid().ToString()
    
    $sql = "INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp) VALUES ('$adminRoleId', 'Admin', 'ADMIN', '$([System.Guid]::NewGuid().ToString())')"
    $db.Execute($sql)
    
    $sql = "INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp) VALUES ('$moderatorRoleId', 'Moderator', 'MODERATOR', '$([System.Guid]::NewGuid().ToString())')"
    $db.Execute($sql)
    
    $sql = "INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp) VALUES ('$userRoleId', 'User', 'USER', '$([System.Guid]::NewGuid().ToString())')"
    $db.Execute($sql)
    
    Write-Host "Inserted default roles (Admin, Moderator, User)" -ForegroundColor Gray
    
    # Insert sample admin user
    $adminUserId = [System.Guid]::NewGuid().ToString()
    $sql = @"
INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, 
                        PasswordHash, SecurityStamp, ConcurrencyStamp, DisplayName, Bio, Reputation, CreatedAt) 
VALUES ('$adminUserId', 'admin@stackoverflow.com', 'ADMIN@STACKOVERFLOW.COM', 'admin@stackoverflow.com', 
        'ADMIN@STACKOVERFLOW.COM', Yes, 'AQAAAAEAACcQAAAAEDummyHashForDemo123456789', 
        '$([System.Guid]::NewGuid().ToString())', '$([System.Guid]::NewGuid().ToString())', 
        'Administrator', 'Site Administrator', 10000, Now())
"@
    $db.Execute($sql)
    
    # Assign admin role to admin user
    $sql = "INSERT INTO AspNetUserRoles (UserId, RoleId) VALUES ('$adminUserId', '$adminRoleId')"
    $db.Execute($sql)
    
    Write-Host "Created sample admin user: admin@stackoverflow.com" -ForegroundColor Gray
    
    # Insert sample regular user
    $regularUserId = [System.Guid]::NewGuid().ToString()
    $sql = @"
INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, 
                        PasswordHash, SecurityStamp, ConcurrencyStamp, DisplayName, Bio, Reputation, CreatedAt) 
VALUES ('$regularUserId', 'user@stackoverflow.com', 'USER@STACKOVERFLOW.COM', 'user@stackoverflow.com', 
        'USER@STACKOVERFLOW.COM', Yes, 'AQAAAAEAACcQAAAAEDummyHashForDemo123456789', 
        '$([System.Guid]::NewGuid().ToString())', '$([System.Guid]::NewGuid().ToString())', 
        'Sample User', 'Just a regular user', 100, Now())
"@
    $db.Execute($sql)
    
    # Assign user role to regular user
    $sql = "INSERT INTO AspNetUserRoles (UserId, RoleId) VALUES ('$regularUserId', '$userRoleId')"
    $db.Execute($sql)
    
    Write-Host "Created sample regular user: user@stackoverflow.com" -ForegroundColor Gray
    
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
    
    # Insert a sample question
    $sql = @"
INSERT INTO Questions (Title, Body, Views, Score, CreatedAt, IsAnswered, IsClosed, UserId) 
VALUES ('Welcome to Stack Overflow Clone!', 'This is a sample question to test the application. You can ask your programming questions here and get answers from the community. This question demonstrates the full functionality of our Stack Overflow clone with Microsoft Access database integration.', 5, 2, Now(), No, No, '$regularUserId')
"@
    $db.Execute($sql)
    Write-Host "Inserted sample question" -ForegroundColor Gray
    
    # Create indexes for better performance
    try {
        $db.Execute("CREATE INDEX IX_AspNetUsers_NormalizedUserName ON AspNetUsers(NormalizedUserName)")
        $db.Execute("CREATE INDEX IX_AspNetUsers_NormalizedEmail ON AspNetUsers(NormalizedEmail)")
        $db.Execute("CREATE INDEX IX_Questions_UserId ON Questions(UserId)")
        $db.Execute("CREATE INDEX IX_Questions_CreatedAt ON Questions(CreatedAt)")
        $db.Execute("CREATE INDEX IX_Answers_QuestionId ON Answers(QuestionId)")
        $db.Execute("CREATE INDEX IX_Votes_QuestionId ON Votes(QuestionId)")
        $db.Execute("CREATE INDEX IX_Votes_AnswerId ON Votes(AnswerId)")
        Write-Host "Created database indexes" -ForegroundColor Gray
    }
    catch {
        Write-Host "Warning: Some indexes could not be created (this is normal)" -ForegroundColor Yellow
    }
    
    # Close database and Access
    $db.Close()
    $access.Quit()
    
    # Release COM objects
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($db) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($access) | Out-Null
    
    Write-Host "Database setup completed successfully!" -ForegroundColor Green
    Write-Host "Database location: $DatabasePath" -ForegroundColor Cyan
    
    # Test connection
    Write-Host "Testing database connection..." -ForegroundColor Yellow
    
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath;Persist Security Info=False;"
    $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
    
    try {
        $connection.Open()
        
        # Test Identity tables
        $command = New-Object System.Data.OleDb.OleDbCommand("SELECT COUNT(*) FROM AspNetUsers", $connection)
        $userCount = $command.ExecuteScalar()
        Write-Host "Found $userCount users in AspNetUsers table" -ForegroundColor Green
        
        $command = New-Object System.Data.OleDb.OleDbCommand("SELECT COUNT(*) FROM AspNetRoles", $connection)
        $roleCount = $command.ExecuteScalar()
        Write-Host "Found $roleCount roles in AspNetRoles table" -ForegroundColor Green
        
        # Test application tables
        $command = New-Object System.Data.OleDb.OleDbCommand("SELECT COUNT(*) FROM Tags", $connection)
        $tagCount = $command.ExecuteScalar()
        Write-Host "Found $tagCount tags in Tags table" -ForegroundColor Green
        
        $command = New-Object System.Data.OleDb.OleDbCommand("SELECT COUNT(*) FROM Questions", $connection)
        $questionCount = $command.ExecuteScalar()
        Write-Host "Found $questionCount questions in Questions table" -ForegroundColor Green
        
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

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "COMPLETE ACCESS DATABASE CREATED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Database file: $DatabasePath" -ForegroundColor White
Write-Host "`nTables created:" -ForegroundColor Yellow
Write-Host "IDENTITY TABLES:" -ForegroundColor Cyan
Write-Host "- AspNetUsers (user accounts)" -ForegroundColor White
Write-Host "- AspNetRoles (user roles)" -ForegroundColor White
Write-Host "- AspNetUserRoles (user-role assignments)" -ForegroundColor White
Write-Host "- AspNetUserClaims, AspNetUserLogins, AspNetUserTokens" -ForegroundColor White
Write-Host "- AspNetRoleClaims" -ForegroundColor White
Write-Host "`nAPPLICATION TABLES:" -ForegroundColor Cyan
Write-Host "- Questions, Answers, Comments" -ForegroundColor White
Write-Host "- Tags, QuestionTags" -ForegroundColor White
Write-Host "- Votes, Flags" -ForegroundColor White
Write-Host "`nSample data created:" -ForegroundColor Yellow
Write-Host "- Admin user: admin@stackoverflow.com" -ForegroundColor White
Write-Host "- Regular user: user@stackoverflow.com" -ForegroundColor White
Write-Host "- 5 sample tags" -ForegroundColor White
Write-Host "- 1 sample question" -ForegroundColor White
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Open the .accdb file in Microsoft Access to view tables" -ForegroundColor White
Write-Host "2. Update appsettings.json to use this database" -ForegroundColor White
Write-Host "3. Run the web application" -ForegroundColor White

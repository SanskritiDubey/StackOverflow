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
);

CREATE TABLE AspNetRoles (
    Id TEXT(450) PRIMARY KEY,
    Name TEXT(256),
    NormalizedName TEXT(256),
    ConcurrencyStamp MEMO
);

CREATE TABLE AspNetUserRoles (
    UserId TEXT(450) NOT NULL,
    RoleId TEXT(450) NOT NULL
);

CREATE TABLE Questions (
    Id AUTOINCREMENT PRIMARY KEY,
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
);

CREATE TABLE Answers (
    Id AUTOINCREMENT PRIMARY KEY,
    QuestionId LONG NOT NULL,
    Body MEMO NOT NULL,
    Score LONG DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    UpdatedAt DATETIME,
    IsAccepted YESNO DEFAULT No,
    UserId TEXT(450) NOT NULL
);

CREATE TABLE Tags (
    Id AUTOINCREMENT PRIMARY KEY,
    Name TEXT(50) NOT NULL,
    Description TEXT(500),
    UsageCount LONG DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    WikiExcerpt MEMO
);

CREATE TABLE QuestionTags (
    QuestionId LONG NOT NULL,
    TagId LONG NOT NULL
);

CREATE TABLE Votes (
    Id AUTOINCREMENT PRIMARY KEY,
    VoteType LONG NOT NULL,
    CreatedAt DATETIME NOT NULL,
    QuestionId LONG,
    AnswerId LONG,
    CommentId LONG,
    UserId TEXT(450) NOT NULL
);

CREATE TABLE Comments (
    Id AUTOINCREMENT PRIMARY KEY,
    Body TEXT(600) NOT NULL,
    Score LONG DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    UpdatedAt DATETIME,
    QuestionId LONG,
    AnswerId LONG,
    UserId TEXT(450) NOT NULL
);

INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp) 
VALUES ('admin-role-id', 'Admin', 'ADMIN', 'admin-stamp');

INSERT INTO AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp) 
VALUES ('user-role-id', 'User', 'USER', 'user-stamp');

INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, 
                        EmailConfirmed, DisplayName, Reputation, CreatedAt) 
VALUES ('admin-user-id', 'admin@test.com', 'ADMIN@TEST.COM', 'admin@test.com', 
        'ADMIN@TEST.COM', Yes, 'Administrator', 1000, Now());

INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, 
                        EmailConfirmed, DisplayName, Reputation, CreatedAt) 
VALUES ('user-1-id', 'user@test.com', 'USER@TEST.COM', 'user@test.com', 
        'USER@TEST.COM', Yes, 'Test User', 100, Now());

INSERT INTO AspNetUserRoles (UserId, RoleId) VALUES ('admin-user-id', 'admin-role-id');
INSERT INTO AspNetUserRoles (UserId, RoleId) VALUES ('user-1-id', 'user-role-id');

INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) 
VALUES ('javascript', 'JavaScript programming language', 0, Now());

INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) 
VALUES ('csharp', 'C# programming language', 0, Now());

INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) 
VALUES ('asp.net', 'ASP.NET framework', 0, Now());

INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) 
VALUES ('html', 'HTML markup language', 0, Now());

INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) 
VALUES ('css', 'CSS styling', 0, Now());

INSERT INTO Questions (Title, Body, Views, Score, CreatedAt, IsAnswered, IsClosed, UserId) 
VALUES ('Welcome to Stack Overflow Clone!', 
        'This is a sample question to test our Stack Overflow clone application. You can ask programming questions here and get answers from the community.', 
        5, 2, Now(), No, No, 'user-1-id');

INSERT INTO Answers (QuestionId, Body, Score, CreatedAt, IsAccepted, UserId) 
VALUES (1, 'Welcome! This is a great platform for asking programming questions. Make sure to provide clear details and code examples when asking questions.', 
        1, Now(), Yes, 'admin-user-id');

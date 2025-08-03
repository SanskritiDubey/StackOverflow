-- Microsoft Access Database Setup Script for Stack Overflow Clone
-- Run this script in Microsoft Access to create the necessary tables

-- Questions Table
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
);

-- Answers Table
CREATE TABLE Answers (
    Id AUTOINCREMENT PRIMARY KEY,
    QuestionId INTEGER NOT NULL,
    Body MEMO NOT NULL,
    Score INTEGER DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    UpdatedAt DATETIME,
    IsAccepted YESNO DEFAULT No,
    UserId TEXT(450) NOT NULL
);

-- Comments Table
CREATE TABLE Comments (
    Id AUTOINCREMENT PRIMARY KEY,
    Body TEXT(600) NOT NULL,
    Score INTEGER DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    UpdatedAt DATETIME,
    QuestionId INTEGER,
    AnswerId INTEGER,
    UserId TEXT(450) NOT NULL
);

-- Tags Table
CREATE TABLE Tags (
    Id AUTOINCREMENT PRIMARY KEY,
    Name TEXT(50) NOT NULL,
    Description TEXT(500),
    UsageCount INTEGER DEFAULT 0,
    CreatedAt DATETIME NOT NULL,
    WikiExcerpt MEMO
);

-- QuestionTags Junction Table
CREATE TABLE QuestionTags (
    QuestionId INTEGER NOT NULL,
    TagId INTEGER NOT NULL,
    PRIMARY KEY (QuestionId, TagId)
);

-- Votes Table
CREATE TABLE Votes (
    Id AUTOINCREMENT PRIMARY KEY,
    VoteType INTEGER NOT NULL, -- 1 for upvote, -1 for downvote
    CreatedAt DATETIME NOT NULL,
    QuestionId INTEGER,
    AnswerId INTEGER,
    CommentId INTEGER,
    UserId TEXT(450) NOT NULL
);

-- Flags Table
CREATE TABLE Flags (
    Id AUTOINCREMENT PRIMARY KEY,
    FlagType INTEGER NOT NULL, -- 0=Spam, 1=Offensive, 2=LowQuality, 3=Duplicate, 4=OffTopic, 5=Other
    Status INTEGER DEFAULT 0, -- 0=Pending, 1=Approved, 2=Rejected, 3=Dismissed
    Reason TEXT(500),
    CreatedAt DATETIME NOT NULL,
    ResolvedAt DATETIME,
    ResolvedByUserId TEXT(450),
    QuestionId INTEGER,
    AnswerId INTEGER,
    CommentId INTEGER,
    UserId TEXT(450) NOT NULL
);

-- Create Indexes for better performance
CREATE INDEX IX_Questions_UserId ON Questions(UserId);
CREATE INDEX IX_Questions_CreatedAt ON Questions(CreatedAt);
CREATE INDEX IX_Questions_Score ON Questions(Score);
CREATE INDEX IX_Answers_QuestionId ON Answers(QuestionId);
CREATE INDEX IX_Answers_UserId ON Answers(UserId);
CREATE INDEX IX_Comments_QuestionId ON Comments(QuestionId);
CREATE INDEX IX_Comments_AnswerId ON Comments(AnswerId);
CREATE INDEX IX_Votes_QuestionId ON Votes(QuestionId);
CREATE INDEX IX_Votes_AnswerId ON Votes(AnswerId);
CREATE INDEX IX_Votes_UserId ON Votes(UserId);
CREATE INDEX IX_Tags_Name ON Tags(Name);
CREATE UNIQUE INDEX IX_Tags_Name_Unique ON Tags(Name);

-- Insert sample data
INSERT INTO Tags (Name, Description, UsageCount, CreatedAt) VALUES
('javascript', 'For questions about JavaScript programming language', 0, Now()),
('python', 'For questions about Python programming language', 0, Now()),
('csharp', 'For questions about C# programming language', 0, Now()),
('html', 'For questions about HTML markup language', 0, Now()),
('css', 'For questions about CSS styling', 0, Now()),
('sql', 'For questions about SQL database queries', 0, Now()),
('asp.net', 'For questions about ASP.NET framework', 0, Now()),
('entity-framework', 'For questions about Entity Framework ORM', 0, Now()),
('bootstrap', 'For questions about Bootstrap CSS framework', 0, Now()),
('jquery', 'For questions about jQuery JavaScript library', 0, Now());

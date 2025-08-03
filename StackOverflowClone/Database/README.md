# Stack Overflow Clone - Microsoft Access Database Setup

## 📋 Overview
This Stack Overflow clone uses **Microsoft Access** as the complete database solution for both user authentication (Identity) and application data.

## 🗄️ Database File
**Location:** `C:\Users\2125513\StackOverflow\StackOverflowClone\Database\StackOverflowComplete.accdb`

## 📊 Database Tables

### Identity Tables (User Registration/Login)
- **AspNetUsers** - User accounts with extended profile information
- **AspNetRoles** - User roles (Admin, Moderator, User)
- **AspNetUserRoles** - Many-to-many relationship between users and roles
- **AspNetUserClaims** - User claims for authorization
- **AspNetUserLogins** - External login providers (Google, Facebook, etc.)
- **AspNetUserTokens** - Security tokens for users
- **AspNetRoleClaims** - Role-based claims

### Application Tables (Stack Overflow Functionality)
- **Questions** - All questions posted by users
- **Answers** - Answers to questions
- **Comments** - Comments on questions and answers
- **Tags** - Available tags for categorizing questions
- **QuestionTags** - Many-to-many relationship between questions and tags
- **Votes** - Upvotes and downvotes on questions/answers
- **Flags** - Flagged content for moderation

## 👥 Sample Data

### Users Created
1. **Administrator**
   - Email: `admin@stackoverflow.com`
   - Role: Admin
   - Reputation: 10,000

2. **Regular User**
   - Email: `user@stackoverflow.com`
   - Role: User
   - Reputation: 100

### Sample Tags
- javascript
- csharp
- asp.net
- html
- css

### Sample Content
- 1 welcome question for testing

## 🔧 Configuration

### Connection Strings (appsettings.json)
```json
{
  "ConnectionStrings": {
    "AccessConnection": "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=C:\\Users\\2125513\\StackOverflow\\StackOverflowClone\\Database\\StackOverflowComplete.accdb;Persist Security Info=False;",
    "DefaultConnection": "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=C:\\Users\\2125513\\StackOverflow\\StackOverflowClone\\Database\\StackOverflowComplete.accdb;Persist Security Info=False;"
  }
}
```

## 🚀 How to Use

### 1. View Database in Microsoft Access
1. Open Microsoft Access
2. Open the file: `StackOverflowComplete.accdb`
3. You'll see all tables in the navigation panel
4. You can view, edit, and manage data directly

### 2. Run the Web Application
```bash
cd C:\Users\2125513\StackOverflow\StackOverflowClone
dotnet run
```

### 3. Access the Application
- URL: `http://localhost:5000`
- Login with sample accounts or register new users

## 🔑 Login Credentials

**Note:** The sample users have dummy password hashes. For testing, you'll need to:
1. Register new accounts through the web interface, OR
2. Update the password hashes in the database with properly hashed passwords

## 🛠️ Database Maintenance

### Backup
Simply copy the `StackOverflowComplete.accdb` file to create a backup.

### Reset Database
Run the PowerShell script again:
```powershell
powershell -ExecutionPolicy Bypass -File "Database\CreateCompleteAccessDb.ps1"
```

## 📝 Features Supported

✅ **User Registration & Login**
✅ **Role-based Authorization** (Admin, Moderator, User)
✅ **Ask Questions** with tags
✅ **Post Answers**
✅ **Voting System** (upvote/downvote)
✅ **Accept Answers**
✅ **Search Questions**
✅ **User Profiles** with reputation
✅ **Tagging System**
✅ **Comment System**
✅ **Moderation Tools** (flagging)

## 🔍 Troubleshooting

### Database Connection Issues
1. Ensure Microsoft Access Database Engine is installed
2. Check file permissions on the .accdb file
3. Verify the connection string path is correct

### Application Startup Issues
1. Check that all NuGet packages are installed
2. Ensure the database file exists
3. Run `dotnet clean` and `dotnet build` if needed

## 📚 Technical Details

- **Framework:** ASP.NET Core MVC 8.0
- **Database:** Microsoft Access (.accdb)
- **ORM:** Entity Framework Core + OLEDB
- **Authentication:** ASP.NET Core Identity
- **UI:** Bootstrap 5 + Font Awesome

This setup provides a complete Stack Overflow clone with all functionality running on Microsoft Access database!

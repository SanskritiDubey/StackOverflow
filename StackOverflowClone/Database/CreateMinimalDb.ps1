# Create minimal Access database with basic verification
$DatabasePath = "C:\Users\2125513\StackOverflow\StackOverflowClone\Database\MinimalTest.accdb"

Write-Host "Creating minimal Access database for testing..." -ForegroundColor Green
Write-Host "Database path: $DatabasePath" -ForegroundColor Cyan

# Remove existing file
if (Test-Path $DatabasePath) {
    Remove-Item $DatabasePath -Force
    Write-Host "Removed existing database" -ForegroundColor Yellow
}

try {
    # Try to create database using ADOX
    Write-Host "Attempting to create database..." -ForegroundColor Yellow
    
    $adox = New-Object -ComObject ADOX.Catalog
    $connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$DatabasePath"
    
    Write-Host "Connection string: $connectionString" -ForegroundColor Gray
    $adox.Create($connectionString)
    
    Write-Host "✓ Database file created successfully!" -ForegroundColor Green
    
    # Release COM object
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($adox) | Out-Null
    
    # Verify file was created
    if (Test-Path $DatabasePath) {
        $fileSize = (Get-Item $DatabasePath).Length
        Write-Host "✓ Database file exists ($fileSize bytes)" -ForegroundColor Green
        
        # Try to connect and create a simple table
        Write-Host "Testing database connection..." -ForegroundColor Yellow
        
        $connection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
        $connection.Open()
        
        Write-Host "✓ Successfully connected to database!" -ForegroundColor Green
        
        # Create a simple test table
        $sql = "CREATE TABLE TestTable (Id AUTOINCREMENT PRIMARY KEY, Name TEXT(50), CreatedAt DATETIME)"
        $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
        $command.ExecuteNonQuery()
        
        Write-Host "✓ Created test table" -ForegroundColor Green
        
        # Insert test data
        $sql = "INSERT INTO TestTable (Name, CreatedAt) VALUES ('Test Record', Now())"
        $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
        $command.ExecuteNonQuery()
        
        Write-Host "✓ Inserted test data" -ForegroundColor Green
        
        # Verify data
        $sql = "SELECT COUNT(*) FROM TestTable"
        $command = New-Object System.Data.OleDb.OleDbCommand($sql, $connection)
        $count = $command.ExecuteScalar()
        
        Write-Host "✓ Test table contains $count records" -ForegroundColor Green
        
        # List tables to verify
        $schema = $connection.GetSchema("Tables")
        Write-Host "`nTables in database:" -ForegroundColor Cyan
        foreach ($row in $schema.Rows) {
            if ($row["TABLE_TYPE"] -eq "TABLE") {
                Write-Host "  - $($row["TABLE_NAME"])" -ForegroundColor White
            }
        }
        
        $connection.Close()
        
        Write-Host "`n🎉 SUCCESS!" -ForegroundColor Green
        Write-Host "Minimal Access database created and verified!" -ForegroundColor White
        Write-Host "File: $DatabasePath" -ForegroundColor Cyan
        Write-Host "`nYou can now open this file in Microsoft Access to see the TestTable!" -ForegroundColor Yellow
        
    } else {
        Write-Host "❌ Database file was not created" -ForegroundColor Red
    }
    
}
catch {
    Write-Host "❌ Error creating database: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPossible issues:" -ForegroundColor Yellow
    Write-Host "1. Microsoft Access Database Engine not installed" -ForegroundColor White
    Write-Host "2. Insufficient permissions" -ForegroundColor White
    Write-Host "3. Path issues" -ForegroundColor White
    
    # Try alternative providers
    Write-Host "`nTrying alternative database providers..." -ForegroundColor Yellow
    
    $alternativeProviders = @(
        "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=$($DatabasePath.Replace('.accdb', '.mdb'))",
        "Provider=Microsoft.ACE.OLEDB.15.0;Data Source=$DatabasePath",
        "Provider=Microsoft.ACE.OLEDB.16.0;Data Source=$DatabasePath"
    )
    
    foreach ($provider in $alternativeProviders) {
        try {
            Write-Host "Trying: $provider" -ForegroundColor Gray
            $testAdox = New-Object -ComObject ADOX.Catalog
            $testAdox.Create($provider)
            Write-Host "✓ Success with alternative provider!" -ForegroundColor Green
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($testAdox) | Out-Null
            break
        }
        catch {
            Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
finally {
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
}

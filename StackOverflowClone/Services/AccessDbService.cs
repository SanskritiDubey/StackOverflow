using System.Data.OleDb;
using System.Data;

namespace StackOverflowClone.Services
{
    public class AccessDbService
    {
        private readonly string _connectionString;

        public AccessDbService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("AccessConnection") 
                ?? throw new ArgumentNullException("AccessConnection string not found");
        }

        public async Task<DataTable> ExecuteQueryAsync(string query, params OleDbParameter[] parameters)
        {
            using var connection = new OleDbConnection(_connectionString);
            using var command = new OleDbCommand(query, connection);
            
            if (parameters != null)
            {
                command.Parameters.AddRange(parameters);
            }

            var dataTable = new DataTable();
            await connection.OpenAsync();
            
            using var adapter = new OleDbDataAdapter(command);
            adapter.Fill(dataTable);
            
            return dataTable;
        }

        public async Task<int> ExecuteNonQueryAsync(string query, params OleDbParameter[] parameters)
        {
            using var connection = new OleDbConnection(_connectionString);
            using var command = new OleDbCommand(query, connection);
            
            if (parameters != null)
            {
                command.Parameters.AddRange(parameters);
            }

            await connection.OpenAsync();
            return await command.ExecuteNonQueryAsync();
        }

        public async Task<object?> ExecuteScalarAsync(string query, params OleDbParameter[] parameters)
        {
            using var connection = new OleDbConnection(_connectionString);
            using var command = new OleDbCommand(query, connection);
            
            if (parameters != null)
            {
                command.Parameters.AddRange(parameters);
            }

            await connection.OpenAsync();
            return await command.ExecuteScalarAsync();
        }

        public async Task<bool> TestConnectionAsync()
        {
            try
            {
                using var connection = new OleDbConnection(_connectionString);
                await connection.OpenAsync();
                return connection.State == ConnectionState.Open;
            }
            catch
            {
                return false;
            }
        }

        // CRUD Operations Examples
        public async Task<int> CreateQuestionAsync(string title, string body, string userId)
        {
            var query = @"INSERT INTO Questions (Title, Body, UserId, CreatedAt, Views, Score) 
                         VALUES (?, ?, ?, ?, 0, 0)";
            
            var parameters = new[]
            {
                new OleDbParameter("@title", title),
                new OleDbParameter("@body", body),
                new OleDbParameter("@userId", userId),
                new OleDbParameter("@createdAt", DateTime.UtcNow)
            };

            await ExecuteNonQueryAsync(query, parameters);
            
            // Get the last inserted ID
            var lastIdQuery = "SELECT @@IDENTITY";
            var result = await ExecuteScalarAsync(lastIdQuery);
            return Convert.ToInt32(result);
        }

        public async Task<DataTable> GetQuestionsAsync(int page = 1, int pageSize = 10)
        {
            // Microsoft Access doesn't support OFFSET, so we'll use a simpler approach
            // For now, just get all questions and handle pagination in the controller if needed
            var query = @"SELECT TOP " + (page * pageSize) + @" q.Id, q.Title, q.Body, q.Views, q.Score, q.CreatedAt, 
                         q.UserId
                         FROM Questions q 
                         ORDER BY q.CreatedAt DESC";
            
            return await ExecuteQueryAsync(query);
        }

        public async Task<DataTable> SearchQuestionsAsync(string searchTerm)
        {
            var query = @"SELECT q.Id, q.Title, q.Body, q.Views, q.Score, q.CreatedAt, 
                         q.UserId
                         FROM Questions q 
                         WHERE q.Title LIKE ? OR q.Body LIKE ?
                         ORDER BY q.CreatedAt DESC";
            
            var searchPattern = $"%{searchTerm}%";
            var parameters = new[]
            {
                new OleDbParameter("@search1", searchPattern),
                new OleDbParameter("@search2", searchPattern)
            };

            return await ExecuteQueryAsync(query, parameters);
        }
    }
}

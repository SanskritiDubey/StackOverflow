using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using StackOverflowClone.Models;
using StackOverflowClone.Services;
using StackOverflowClone.ViewModels;
using System.Data;

namespace StackOverflowClone.Controllers
{
    public class QuestionsController : Controller
    {
        private readonly AccessDbService _accessDbService;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IConfiguration _configuration;

        public QuestionsController(AccessDbService accessDbService, 
            UserManager<ApplicationUser> userManager,
            IConfiguration configuration)
        {
            _accessDbService = accessDbService;
            _userManager = userManager;
            _configuration = configuration;
        }

        // GET: Questions
        public async Task<IActionResult> Index(int page = 1, string sortBy = "newest", string search = "")
        {
            var pageSize = _configuration.GetValue<int>("ApplicationSettings:PageSize", 15);
            
            DataTable questionsData;
            
            if (!string.IsNullOrEmpty(search))
            {
                questionsData = await _accessDbService.SearchQuestionsAsync(search);
            }
            else
            {
                questionsData = await _accessDbService.GetQuestionsAsync(page, pageSize);
            }

            var questions = new List<QuestionViewModel>();
            
            foreach (DataRow row in questionsData.Rows)
            {
                var userId = row["UserId"].ToString() ?? "";
                var user = await _userManager.FindByIdAsync(userId);
                var userName = user?.DisplayName ?? "Unknown User";
                
                questions.Add(new QuestionViewModel
                {
                    Id = Convert.ToInt32(row["Id"]),
                    Title = row["Title"].ToString() ?? "",
                    Body = row["Body"].ToString() ?? "",
                    Views = Convert.ToInt32(row["Views"]),
                    Score = Convert.ToInt32(row["Score"]),
                    CreatedAt = Convert.ToDateTime(row["CreatedAt"]),
                    IsAnswered = Convert.ToBoolean(row["IsAnswered"]),
                    UserName = userName
                });
            }

            var viewModel = new QuestionsIndexViewModel
            {
                Questions = questions,
                CurrentPage = page,
                PageSize = pageSize,
                SortBy = sortBy,
                SearchTerm = search
            };

            return View(viewModel);
        }

        // GET: Questions/Details/5
        public async Task<IActionResult> Details(int id)
        {
            var query = @"SELECT q.Id, q.Title, q.Body, q.Views, q.Score, q.CreatedAt, q.UpdatedAt,
                         q.IsAnswered, q.AcceptedAnswerId, q.UserId
                         FROM Questions q 
                         WHERE q.Id = ?";
            
            var questionData = await _accessDbService.ExecuteQueryAsync(query, 
                new System.Data.OleDb.OleDbParameter("@id", id));

            if (questionData.Rows.Count == 0)
            {
                return NotFound();
            }

            var row = questionData.Rows[0];
            var userId = row["UserId"].ToString() ?? "";
            var user = await _userManager.FindByIdAsync(userId);
            var userName = user?.DisplayName ?? "Unknown User";
            var userReputation = user?.Reputation ?? 0;
            
            var question = new QuestionDetailsViewModel
            {
                Id = Convert.ToInt32(row["Id"]),
                Title = row["Title"].ToString() ?? "",
                Body = row["Body"].ToString() ?? "",
                Views = Convert.ToInt32(row["Views"]),
                Score = Convert.ToInt32(row["Score"]),
                CreatedAt = Convert.ToDateTime(row["CreatedAt"]),
                UpdatedAt = row["UpdatedAt"] != DBNull.Value ? Convert.ToDateTime(row["UpdatedAt"]) : null,
                IsAnswered = Convert.ToBoolean(row["IsAnswered"]),
                AcceptedAnswerId = row["AcceptedAnswerId"] != DBNull.Value ? Convert.ToInt32(row["AcceptedAnswerId"]) : null,
                UserName = userName,
                UserReputation = userReputation
            };

            // Update view count
            await _accessDbService.ExecuteNonQueryAsync(
                "UPDATE Questions SET Views = Views + 1 WHERE Id = ?",
                new System.Data.OleDb.OleDbParameter("@id", id));

            // Get answers
            var answersQuery = @"SELECT a.Id, a.Body, a.Score, a.CreatedAt, a.UpdatedAt, a.IsAccepted, a.UserId
                               FROM Answers a
                               WHERE a.QuestionId = ?
                               ORDER BY a.IsAccepted DESC, a.Score DESC, a.CreatedAt ASC";
            
            var answersData = await _accessDbService.ExecuteQueryAsync(answersQuery,
                new System.Data.OleDb.OleDbParameter("@questionId", id));

            question.Answers = new List<AnswerViewModel>();
            foreach (DataRow answerRow in answersData.Rows)
            {
                var answerUserId = answerRow["UserId"].ToString() ?? "";
                var answerUser = await _userManager.FindByIdAsync(answerUserId);
                var answerUserName = answerUser?.DisplayName ?? "Unknown User";
                var answerUserReputation = answerUser?.Reputation ?? 0;
                
                question.Answers.Add(new AnswerViewModel
                {
                    Id = Convert.ToInt32(answerRow["Id"]),
                    Body = answerRow["Body"].ToString() ?? "",
                    Score = Convert.ToInt32(answerRow["Score"]),
                    CreatedAt = Convert.ToDateTime(answerRow["CreatedAt"]),
                    UpdatedAt = answerRow["UpdatedAt"] != DBNull.Value ? Convert.ToDateTime(answerRow["UpdatedAt"]) : null,
                    IsAccepted = Convert.ToBoolean(answerRow["IsAccepted"]),
                    UserName = answerUserName,
                    UserReputation = answerUserReputation
                });
            }

            return View(question);
        }

        // GET: Questions/Ask
        [Authorize]
        public IActionResult Ask()
        {
            return View(new AskQuestionViewModel());
        }

        // POST: Questions/Ask
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Ask(AskQuestionViewModel model)
        {
            if (ModelState.IsValid)
            {
                var user = await _userManager.GetUserAsync(User);
                if (user != null)
                {
                    var questionId = await _accessDbService.CreateQuestionAsync(model.Title, model.Body, user.Id);
                    
                    // Handle tags if provided
                    if (!string.IsNullOrEmpty(model.Tags))
                    {
                        var tags = model.Tags.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                           .Select(t => t.Trim().ToLower())
                                           .Distinct()
                                           .Take(5); // Limit to 5 tags

                        foreach (var tagName in tags)
                        {
                            await CreateOrUpdateTagAsync(tagName, questionId);
                        }
                    }

                    return RedirectToAction(nameof(Details), new { id = questionId });
                }
            }

            return View(model);
        }

        // POST: Questions/Vote
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Vote(int questionId, int voteType)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            // Check if user has already voted on this question
            var existingVoteQuery = "SELECT Id FROM Votes WHERE UserId = ? AND QuestionId = ?";
            var existingVote = await _accessDbService.ExecuteQueryAsync(existingVoteQuery,
                new System.Data.OleDb.OleDbParameter("@userId", user.Id),
                new System.Data.OleDb.OleDbParameter("@questionId", questionId));

            if (existingVote.Rows.Count > 0)
            {
                return Json(new { success = false, message = "You have already voted on this question." });
            }

            // Insert vote
            var insertVoteQuery = "INSERT INTO Votes (UserId, QuestionId, VoteType, CreatedAt) VALUES (?, ?, ?, ?)";
            await _accessDbService.ExecuteNonQueryAsync(insertVoteQuery,
                new System.Data.OleDb.OleDbParameter("@userId", user.Id),
                new System.Data.OleDb.OleDbParameter("@questionId", questionId),
                new System.Data.OleDb.OleDbParameter("@voteType", voteType),
                new System.Data.OleDb.OleDbParameter("@createdAt", DateTime.UtcNow));

            // Update question score
            var updateScoreQuery = "UPDATE Questions SET Score = Score + ? WHERE Id = ?";
            await _accessDbService.ExecuteNonQueryAsync(updateScoreQuery,
                new System.Data.OleDb.OleDbParameter("@voteValue", voteType),
                new System.Data.OleDb.OleDbParameter("@questionId", questionId));

            return Json(new { success = true });
        }

        private async Task CreateOrUpdateTagAsync(string tagName, int questionId)
        {
            // Check if tag exists
            var tagQuery = "SELECT Id FROM Tags WHERE Name = ?";
            var tagData = await _accessDbService.ExecuteQueryAsync(tagQuery,
                new System.Data.OleDb.OleDbParameter("@name", tagName));

            int tagId;
            if (tagData.Rows.Count == 0)
            {
                // Create new tag
                var createTagQuery = "INSERT INTO Tags (Name, UsageCount, CreatedAt) VALUES (?, 1, ?)";
                await _accessDbService.ExecuteNonQueryAsync(createTagQuery,
                    new System.Data.OleDb.OleDbParameter("@name", tagName),
                    new System.Data.OleDb.OleDbParameter("@createdAt", DateTime.UtcNow));

                var lastIdQuery = "SELECT @@IDENTITY";
                var result = await _accessDbService.ExecuteScalarAsync(lastIdQuery);
                tagId = Convert.ToInt32(result);
            }
            else
            {
                tagId = Convert.ToInt32(tagData.Rows[0]["Id"]);
                
                // Update usage count
                var updateUsageQuery = "UPDATE Tags SET UsageCount = UsageCount + 1 WHERE Id = ?";
                await _accessDbService.ExecuteNonQueryAsync(updateUsageQuery,
                    new System.Data.OleDb.OleDbParameter("@id", tagId));
            }

            // Link tag to question
            var linkQuery = "INSERT INTO QuestionTags (QuestionId, TagId) VALUES (?, ?)";
            await _accessDbService.ExecuteNonQueryAsync(linkQuery,
                new System.Data.OleDb.OleDbParameter("@questionId", questionId),
                new System.Data.OleDb.OleDbParameter("@tagId", tagId));
        }
    }
}

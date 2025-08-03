using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using StackOverflowClone.Models;
using StackOverflowClone.Services;
using StackOverflowClone.ViewModels;
using System.Data.OleDb;

namespace StackOverflowClone.Controllers
{
    public class AnswersController : Controller
    {
        private readonly AccessDbService _accessDbService;
        private readonly UserManager<ApplicationUser> _userManager;

        public AnswersController(AccessDbService accessDbService, UserManager<ApplicationUser> userManager)
        {
            _accessDbService = accessDbService;
            _userManager = userManager;
        }

        // POST: Answers/Create
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(int questionId, string body)
        {
            if (string.IsNullOrWhiteSpace(body) || body.Length < 30)
            {
                TempData["Error"] = "Answer must be at least 30 characters long.";
                return RedirectToAction("Details", "Questions", new { id = questionId });
            }

            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return Unauthorized();
            }

            var query = @"INSERT INTO Answers (QuestionId, UserId, Body, Score, CreatedAt, IsAccepted) 
                         VALUES (?, ?, ?, 0, ?, False)";
            
            await _accessDbService.ExecuteNonQueryAsync(query,
                new OleDbParameter("@questionId", questionId),
                new OleDbParameter("@userId", user.Id),
                new OleDbParameter("@body", body),
                new OleDbParameter("@createdAt", DateTime.UtcNow));

            // Update question's IsAnswered status
            var updateQuestionQuery = "UPDATE Questions SET IsAnswered = True WHERE Id = ?";
            await _accessDbService.ExecuteNonQueryAsync(updateQuestionQuery,
                new OleDbParameter("@questionId", questionId));

            TempData["Success"] = "Your answer has been posted successfully!";
            return RedirectToAction("Details", "Questions", new { id = questionId });
        }

        // POST: Answers/Vote
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Vote(int answerId, int voteType)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            // Check if user has already voted on this answer
            var existingVoteQuery = "SELECT Id FROM Votes WHERE UserId = ? AND AnswerId = ?";
            var existingVote = await _accessDbService.ExecuteQueryAsync(existingVoteQuery,
                new OleDbParameter("@userId", user.Id),
                new OleDbParameter("@answerId", answerId));

            if (existingVote.Rows.Count > 0)
            {
                return Json(new { success = false, message = "You have already voted on this answer." });
            }

            // Insert vote
            var insertVoteQuery = "INSERT INTO Votes (UserId, AnswerId, VoteType, CreatedAt) VALUES (?, ?, ?, ?)";
            await _accessDbService.ExecuteNonQueryAsync(insertVoteQuery,
                new OleDbParameter("@userId", user.Id),
                new OleDbParameter("@answerId", answerId),
                new OleDbParameter("@voteType", voteType),
                new OleDbParameter("@createdAt", DateTime.UtcNow));

            // Update answer score
            var updateScoreQuery = "UPDATE Answers SET Score = Score + ? WHERE Id = ?";
            await _accessDbService.ExecuteNonQueryAsync(updateScoreQuery,
                new OleDbParameter("@voteValue", voteType),
                new OleDbParameter("@answerId", answerId));

            // Get updated score
            var getScoreQuery = "SELECT Score FROM Answers WHERE Id = ?";
            var scoreResult = await _accessDbService.ExecuteScalarAsync(getScoreQuery,
                new OleDbParameter("@answerId", answerId));

            return Json(new { success = true, newScore = Convert.ToInt32(scoreResult) });
        }

        // POST: Answers/Accept
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Accept(int answerId, int questionId)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            // Check if the current user is the question owner
            var questionOwnerQuery = "SELECT UserId FROM Questions WHERE Id = ?";
            var questionOwnerResult = await _accessDbService.ExecuteScalarAsync(questionOwnerQuery,
                new OleDbParameter("@questionId", questionId));

            if (questionOwnerResult?.ToString() != user.Id)
            {
                return Json(new { success = false, message = "Only the question owner can accept answers." });
            }

            // Unaccept any previously accepted answer for this question
            var unacceptQuery = "UPDATE Answers SET IsAccepted = False WHERE QuestionId = ?";
            await _accessDbService.ExecuteNonQueryAsync(unacceptQuery,
                new OleDbParameter("@questionId", questionId));

            // Accept the selected answer
            var acceptQuery = "UPDATE Answers SET IsAccepted = True WHERE Id = ?";
            await _accessDbService.ExecuteNonQueryAsync(acceptQuery,
                new OleDbParameter("@answerId", answerId));

            // Update question's accepted answer ID
            var updateQuestionQuery = "UPDATE Questions SET AcceptedAnswerId = ? WHERE Id = ?";
            await _accessDbService.ExecuteNonQueryAsync(updateQuestionQuery,
                new OleDbParameter("@answerId", answerId),
                new OleDbParameter("@questionId", questionId));

            return Json(new { success = true });
        }

        // POST: Answers/Edit
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int answerId, string body, int questionId)
        {
            if (string.IsNullOrWhiteSpace(body) || body.Length < 30)
            {
                TempData["Error"] = "Answer must be at least 30 characters long.";
                return RedirectToAction("Details", "Questions", new { id = questionId });
            }

            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            // Check if the current user is the answer owner or has moderator/admin role
            var answerOwnerQuery = "SELECT UserId FROM Answers WHERE Id = ?";
            var answerOwnerResult = await _accessDbService.ExecuteScalarAsync(answerOwnerQuery,
                new OleDbParameter("@answerId", answerId));

            var isOwner = answerOwnerResult?.ToString() == user.Id;
            var isModerator = User.IsInRole("Moderator") || User.IsInRole("Admin");

            if (!isOwner && !isModerator)
            {
                TempData["Error"] = "You can only edit your own answers.";
                return RedirectToAction("Details", "Questions", new { id = questionId });
            }

            // Update the answer
            var updateQuery = "UPDATE Answers SET Body = ?, UpdatedAt = ? WHERE Id = ?";
            await _accessDbService.ExecuteNonQueryAsync(updateQuery,
                new OleDbParameter("@body", body),
                new OleDbParameter("@updatedAt", DateTime.UtcNow),
                new OleDbParameter("@answerId", answerId));

            TempData["Success"] = "Answer updated successfully!";
            return RedirectToAction("Details", "Questions", new { id = questionId });
        }

        // POST: Answers/Delete
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Delete(int answerId, int questionId)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            // Check if the current user is the answer owner or has moderator/admin role
            var answerOwnerQuery = "SELECT UserId FROM Answers WHERE Id = ?";
            var answerOwnerResult = await _accessDbService.ExecuteScalarAsync(answerOwnerQuery,
                new OleDbParameter("@answerId", answerId));

            var isOwner = answerOwnerResult?.ToString() == user.Id;
            var isModerator = User.IsInRole("Moderator") || User.IsInRole("Admin");

            if (!isOwner && !isModerator)
            {
                return Json(new { success = false, message = "You can only delete your own answers." });
            }

            // Delete related votes first
            var deleteVotesQuery = "DELETE FROM Votes WHERE AnswerId = ?";
            await _accessDbService.ExecuteNonQueryAsync(deleteVotesQuery,
                new OleDbParameter("@answerId", answerId));

            // Delete related comments
            var deleteCommentsQuery = "DELETE FROM Comments WHERE AnswerId = ?";
            await _accessDbService.ExecuteNonQueryAsync(deleteCommentsQuery,
                new OleDbParameter("@answerId", answerId));

            // Delete the answer
            var deleteAnswerQuery = "DELETE FROM Answers WHERE Id = ?";
            await _accessDbService.ExecuteNonQueryAsync(deleteAnswerQuery,
                new OleDbParameter("@answerId", answerId));

            // Check if question still has answers
            var remainingAnswersQuery = "SELECT COUNT(*) FROM Answers WHERE QuestionId = ?";
            var remainingCount = await _accessDbService.ExecuteScalarAsync(remainingAnswersQuery,
                new OleDbParameter("@questionId", questionId));

            if (Convert.ToInt32(remainingCount) == 0)
            {
                // Update question's IsAnswered status
                var updateQuestionQuery = "UPDATE Questions SET IsAnswered = False, AcceptedAnswerId = NULL WHERE Id = ?";
                await _accessDbService.ExecuteNonQueryAsync(updateQuestionQuery,
                    new OleDbParameter("@questionId", questionId));
            }

            return Json(new { success = true });
        }
    }
}

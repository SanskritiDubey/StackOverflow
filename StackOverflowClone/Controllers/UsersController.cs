using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using StackOverflowClone.Models;
using StackOverflowClone.Services;
using StackOverflowClone.ViewModels;
using System.Data;

namespace StackOverflowClone.Controllers
{
    public class UsersController : Controller
    {
        private readonly AccessDbService _accessDbService;
        private readonly UserManager<ApplicationUser> _userManager;

        public UsersController(AccessDbService accessDbService, UserManager<ApplicationUser> userManager)
        {
            _accessDbService = accessDbService;
            _userManager = userManager;
        }

        // GET: Users
        public async Task<IActionResult> Index(int page = 1, string search = "")
        {
            var users = await _userManager.Users.ToListAsync();
            
            if (!string.IsNullOrEmpty(search))
            {
                users = users.Where(u => u.DisplayName.Contains(search, StringComparison.OrdinalIgnoreCase) ||
                                        u.UserName.Contains(search, StringComparison.OrdinalIgnoreCase))
                            .ToList();
            }

            var userViewModels = users.Select(u => new UserViewModel
            {
                Id = u.Id,
                DisplayName = u.DisplayName,
                UserName = u.UserName ?? "",
                Reputation = u.Reputation,
                Location = u.Location,
                CreatedAt = u.CreatedAt
            }).OrderByDescending(u => u.Reputation).ToList();

            var viewModel = new UsersIndexViewModel
            {
                Users = userViewModels,
                SearchTerm = search,
                CurrentPage = page
            };

            return View(viewModel);
        }

        // GET: Users/Profile/5
        public async Task<IActionResult> Profile(string id)
        {
            if (string.IsNullOrEmpty(id))
            {
                var currentUser = await _userManager.GetUserAsync(User);
                if (currentUser == null)
                {
                    return RedirectToAction("Index");
                }
                id = currentUser.Id;
            }

            var user = await _userManager.FindByIdAsync(id);
            if (user == null)
            {
                return NotFound();
            }

            // Get user's questions
            var questionsQuery = @"SELECT Id, Title, Score, Views, CreatedAt, IsAnswered 
                                  FROM Questions WHERE UserId = ? 
                                  ORDER BY CreatedAt DESC";
            var questionsData = await _accessDbService.ExecuteQueryAsync(questionsQuery,
                new System.Data.OleDb.OleDbParameter("@userId", id));

            var questions = new List<UserQuestionViewModel>();
            foreach (DataRow row in questionsData.Rows)
            {
                questions.Add(new UserQuestionViewModel
                {
                    Id = Convert.ToInt32(row["Id"]),
                    Title = row["Title"].ToString() ?? "",
                    Score = Convert.ToInt32(row["Score"]),
                    Views = Convert.ToInt32(row["Views"]),
                    CreatedAt = Convert.ToDateTime(row["CreatedAt"]),
                    IsAnswered = Convert.ToBoolean(row["IsAnswered"])
                });
            }

            // Get user's answers
            var answersQuery = @"SELECT a.Id, a.Score, a.CreatedAt, a.IsAccepted, q.Title as QuestionTitle, q.Id as QuestionId
                               FROM Answers a
                               INNER JOIN Questions q ON a.QuestionId = q.Id
                               WHERE a.UserId = ?
                               ORDER BY a.CreatedAt DESC";
            var answersData = await _accessDbService.ExecuteQueryAsync(answersQuery,
                new System.Data.OleDb.OleDbParameter("@userId", id));

            var answers = new List<UserAnswerViewModel>();
            foreach (DataRow row in answersData.Rows)
            {
                answers.Add(new UserAnswerViewModel
                {
                    Id = Convert.ToInt32(row["Id"]),
                    Score = Convert.ToInt32(row["Score"]),
                    CreatedAt = Convert.ToDateTime(row["CreatedAt"]),
                    IsAccepted = Convert.ToBoolean(row["IsAccepted"]),
                    QuestionTitle = row["QuestionTitle"].ToString() ?? "",
                    QuestionId = Convert.ToInt32(row["QuestionId"])
                });
            }

            var profileViewModel = new UserProfileViewModel
            {
                User = new UserViewModel
                {
                    Id = user.Id,
                    DisplayName = user.DisplayName,
                    UserName = user.UserName ?? "",
                    Email = user.Email ?? "",
                    Reputation = user.Reputation,
                    Bio = user.Bio,
                    Location = user.Location,
                    Website = user.Website,
                    CreatedAt = user.CreatedAt,
                    ProfileImageUrl = user.ProfileImageUrl
                },
                Questions = questions,
                Answers = answers,
                TotalQuestions = questions.Count,
                TotalAnswers = answers.Count,
                AcceptedAnswers = answers.Count(a => a.IsAccepted)
            };

            return View(profileViewModel);
        }

        // GET: Users/Settings
        [Authorize]
        public async Task<IActionResult> Settings()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return NotFound();
            }

            var viewModel = new UserSettingsViewModel
            {
                DisplayName = user.DisplayName,
                Bio = user.Bio,
                Location = user.Location,
                Website = user.Website
            };

            return View(viewModel);
        }

        // POST: Users/Settings
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Settings(UserSettingsViewModel model)
        {
            if (ModelState.IsValid)
            {
                var user = await _userManager.GetUserAsync(User);
                if (user == null)
                {
                    return NotFound();
                }

                user.DisplayName = model.DisplayName;
                user.Bio = model.Bio;
                user.Location = model.Location;
                user.Website = model.Website;

                var result = await _userManager.UpdateAsync(user);
                if (result.Succeeded)
                {
                    TempData["Success"] = "Profile updated successfully!";
                    return RedirectToAction(nameof(Profile));
                }

                foreach (var error in result.Errors)
                {
                    ModelState.AddModelError(string.Empty, error.Description);
                }
            }

            return View(model);
        }
    }
}

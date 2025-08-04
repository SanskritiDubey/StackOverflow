using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using StackOverflowClone.Models;
using StackOverflowClone.Services;
using StackOverflowClone.ViewModels;

namespace StackOverflowClone.Controllers
{
    public class QuestionsController : Controller
    {
        private readonly QuestionService _questionService;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IConfiguration _configuration;

        public QuestionsController(
            QuestionService questionService,
            UserManager<ApplicationUser> userManager,
            IConfiguration configuration)
        {
            _questionService = questionService;
            _userManager = userManager;
            _configuration = configuration;
        }

        // GET: Questions
        public async Task<IActionResult> Index(int page = 1, string sortBy = "newest", string search = "")
        {
            var pageSize = _configuration.GetValue<int>("ApplicationSettings:PageSize", 15);
            
            List<Question> questionsData;
            
            if (!string.IsNullOrEmpty(search))
            {
                questionsData = await _questionService.SearchQuestionsAsync(search);
            }
            else
            {
                questionsData = await _questionService.GetQuestionsAsync(page, pageSize);
            }

            var questions = new List<QuestionViewModel>();
            
            foreach (var question in questionsData)
            {
                var userName = question.User?.DisplayName ?? "Unknown User";
                
                questions.Add(new QuestionViewModel
                {
                    Id = question.Id,
                    Title = question.Title,
                    Body = question.Body,
                    Views = question.Views,
                    Score = question.Score,
                    CreatedAt = question.CreatedAt,
                    IsAnswered = question.Answers?.Any() ?? false,
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
            var question = await _questionService.GetQuestionByIdAsync(id);
            
            if (question == null)
            {
                return NotFound();
            }

            // Increment view count
            await _questionService.IncrementViewsAsync(id);

            var viewModel = new QuestionDetailsViewModel
            {
                Id = question.Id,
                Title = question.Title,
                Body = question.Body,
                Views = question.Views,
                Score = question.Score,
                CreatedAt = question.CreatedAt,
                UserName = question.User?.DisplayName ?? "Unknown User",
                UserReputation = question.User?.Reputation ?? 0,
                Answers = question.Answers?.Select(a => new AnswerViewModel
                {
                    Id = a.Id,
                    Body = a.Body,
                    Score = a.Score,
                    CreatedAt = a.CreatedAt,
                    UserName = a.User?.DisplayName ?? "Unknown User",
                    UserReputation = a.User?.Reputation ?? 0
                }).ToList() ?? new List<AnswerViewModel>(),
                Tags = question.QuestionTags?.Select(qt => qt.Tag.Name).ToList() ?? new List<string>()
            };

            return View(viewModel);
        }

        // GET: Questions/Create
        public IActionResult Create()
        {
            return View();
        }

        // GET: Questions/Ask (alias for Create)
        public IActionResult Ask()
        {
            return View("Create");
        }

        // POST: Questions/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(CreateQuestionViewModel model)
        {
            if (ModelState.IsValid)
            {
                var user = await _userManager.GetUserAsync(User);
                if (user == null)
                {
                    return RedirectToAction("Login", "Account");
                }

                var tagNames = model.Tags?.Split(',', StringSplitOptions.RemoveEmptyEntries)
                    .Select(t => t.Trim())
                    .Where(t => !string.IsNullOrEmpty(t))
                    .ToList() ?? new List<string>();

                var question = await _questionService.CreateQuestionAsync(
                    model.Title, 
                    model.Body, 
                    user.Id, 
                    tagNames);

                return RedirectToAction(nameof(Details), new { id = question.Id });
            }

            return View(model);
        }
    }
}

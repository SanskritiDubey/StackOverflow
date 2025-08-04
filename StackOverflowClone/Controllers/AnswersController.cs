using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using StackOverflowClone.Models;
using StackOverflowClone.Services;
using StackOverflowClone.ViewModels;

namespace StackOverflowClone.Controllers
{
    public class AnswersController : Controller
    {
        private readonly QuestionService _questionService;
        private readonly UserManager<ApplicationUser> _userManager;

        public AnswersController(QuestionService questionService, UserManager<ApplicationUser> userManager)
        {
            _questionService = questionService;
            _userManager = userManager;
        }

        // GET: Answers/Create?questionId=5
        public async Task<IActionResult> Create(int questionId)
        {
            var question = await _questionService.GetQuestionByIdAsync(questionId);
            if (question == null)
            {
                return NotFound();
            }

            var viewModel = new CreateAnswerViewModel
            {
                QuestionId = questionId,
                QuestionTitle = question.Title
            };

            return View(viewModel);
        }

        // POST: Answers/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(CreateAnswerViewModel model)
        {
            if (ModelState.IsValid)
            {
                var user = await _userManager.GetUserAsync(User);
                if (user == null)
                {
                    return RedirectToAction("Login", "Account");
                }

                await _questionService.CreateAnswerAsync(model.QuestionId, model.Body, user.Id);
                return RedirectToAction("Details", "Questions", new { id = model.QuestionId });
            }

            // If we got this far, something failed, redisplay form
            var question = await _questionService.GetQuestionByIdAsync(model.QuestionId);
            if (question != null)
            {
                model.QuestionTitle = question.Title;
            }
            return View(model);
        }
    }
}

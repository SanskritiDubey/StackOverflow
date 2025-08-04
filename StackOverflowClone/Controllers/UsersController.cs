using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using StackOverflowClone.Models;
using StackOverflowClone.Services;
using StackOverflowClone.ViewModels;

namespace StackOverflowClone.Controllers
{
    public class UsersController : Controller
    {
        private readonly UserManager<ApplicationUser> _userManager;

        public UsersController(UserManager<ApplicationUser> userManager)
        {
            _userManager = userManager;
        }

        // Temporarily disabled - will be reimplemented with Entity Framework
        public IActionResult Index()
        {
            return View("ComingSoon");
        }

        // TODO: Reimplement with Entity Framework and SQLite
        // All methods temporarily disabled during migration from Access to SQLite
    }
}

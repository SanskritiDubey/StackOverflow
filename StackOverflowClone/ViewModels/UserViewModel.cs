using System.ComponentModel.DataAnnotations;

namespace StackOverflowClone.ViewModels
{
    public class UserViewModel
    {
        public string Id { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public int Reputation { get; set; }
        public string? Bio { get; set; }
        public string? Location { get; set; }
        public string? Website { get; set; }
        public DateTime CreatedAt { get; set; }
        public string? ProfileImageUrl { get; set; }
    }

    public class UsersIndexViewModel
    {
        public List<UserViewModel> Users { get; set; } = new List<UserViewModel>();
        public string SearchTerm { get; set; } = string.Empty;
        public int CurrentPage { get; set; }
        public int PageSize { get; set; } = 20;
        public int TotalPages { get; set; }
    }

    public class UserProfileViewModel
    {
        public UserViewModel User { get; set; } = new UserViewModel();
        public List<UserQuestionViewModel> Questions { get; set; } = new List<UserQuestionViewModel>();
        public List<UserAnswerViewModel> Answers { get; set; } = new List<UserAnswerViewModel>();
        public int TotalQuestions { get; set; }
        public int TotalAnswers { get; set; }
        public int AcceptedAnswers { get; set; }
    }

    public class UserQuestionViewModel
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public int Score { get; set; }
        public int Views { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsAnswered { get; set; }
    }

    public class UserAnswerViewModel
    {
        public int Id { get; set; }
        public int Score { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsAccepted { get; set; }
        public string QuestionTitle { get; set; } = string.Empty;
        public int QuestionId { get; set; }
    }

    public class UserSettingsViewModel
    {
        [Required]
        [StringLength(100)]
        [Display(Name = "Display Name")]
        public string DisplayName { get; set; } = string.Empty;

        [StringLength(500)]
        [Display(Name = "About Me")]
        public string? Bio { get; set; }

        [StringLength(100)]
        public string? Location { get; set; }

        [Url]
        [StringLength(200)]
        public string? Website { get; set; }
    }
}

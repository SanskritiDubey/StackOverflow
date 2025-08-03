using System.ComponentModel.DataAnnotations;

namespace StackOverflowClone.ViewModels
{
    public class QuestionViewModel
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Body { get; set; } = string.Empty;
        public int Views { get; set; }
        public int Score { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public bool IsAnswered { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int AnswerCount { get; set; }
        public List<string> Tags { get; set; } = new List<string>();
    }

    public class QuestionsIndexViewModel
    {
        public List<QuestionViewModel> Questions { get; set; } = new List<QuestionViewModel>();
        public int CurrentPage { get; set; }
        public int PageSize { get; set; }
        public int TotalPages { get; set; }
        public string SortBy { get; set; } = "newest";
        public string SearchTerm { get; set; } = string.Empty;
    }

    public class QuestionDetailsViewModel
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Body { get; set; } = string.Empty;
        public int Views { get; set; }
        public int Score { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public bool IsAnswered { get; set; }
        public int? AcceptedAnswerId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int UserReputation { get; set; }
        public List<AnswerViewModel> Answers { get; set; } = new List<AnswerViewModel>();
        public List<CommentViewModel> Comments { get; set; } = new List<CommentViewModel>();
        public List<string> Tags { get; set; } = new List<string>();
    }

    public class AskQuestionViewModel
    {
        [Required]
        [StringLength(300, MinimumLength = 10)]
        [Display(Name = "Question Title")]
        public string Title { get; set; } = string.Empty;

        [Required]
        [MinLength(30)]
        [Display(Name = "Question Body")]
        public string Body { get; set; } = string.Empty;

        [Display(Name = "Tags (comma-separated, max 5)")]
        [StringLength(200)]
        public string Tags { get; set; } = string.Empty;
    }

    public class AnswerViewModel
    {
        public int Id { get; set; }
        public string Body { get; set; } = string.Empty;
        public int Score { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public bool IsAccepted { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int UserReputation { get; set; }
        public List<CommentViewModel> Comments { get; set; } = new List<CommentViewModel>();
    }

    public class CommentViewModel
    {
        public int Id { get; set; }
        public string Body { get; set; } = string.Empty;
        public int Score { get; set; }
        public DateTime CreatedAt { get; set; }
        public string UserName { get; set; } = string.Empty;
    }
}

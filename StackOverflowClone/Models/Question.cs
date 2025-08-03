using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace StackOverflowClone.Models
{
    public class Question
    {
        public int Id { get; set; }

        [Required]
        [StringLength(300)]
        public string Title { get; set; } = string.Empty;

        [Required]
        public string Body { get; set; } = string.Empty;

        public int Views { get; set; } = 0;

        public int Score { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        public bool IsAnswered { get; set; } = false;

        public int? AcceptedAnswerId { get; set; }

        public bool IsClosed { get; set; } = false;

        public string? CloseReason { get; set; }

        // Foreign Keys
        [Required]
        public string UserId { get; set; } = string.Empty;

        // Navigation properties
        [ForeignKey("UserId")]
        public virtual ApplicationUser User { get; set; } = null!;

        public virtual ICollection<Answer> Answers { get; set; } = new List<Answer>();
        public virtual ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public virtual ICollection<Vote> Votes { get; set; } = new List<Vote>();
        public virtual ICollection<QuestionTag> QuestionTags { get; set; } = new List<QuestionTag>();
        public virtual ICollection<Flag> Flags { get; set; } = new List<Flag>();
    }
}

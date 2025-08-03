using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace StackOverflowClone.Models
{
    public class Answer
    {
        public int Id { get; set; }

        [Required]
        public string Body { get; set; } = string.Empty;

        public int Score { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        public bool IsAccepted { get; set; } = false;

        // Foreign Keys
        [Required]
        public int QuestionId { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        // Navigation properties
        [ForeignKey("QuestionId")]
        public virtual Question Question { get; set; } = null!;

        [ForeignKey("UserId")]
        public virtual ApplicationUser User { get; set; } = null!;

        public virtual ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public virtual ICollection<Vote> Votes { get; set; } = new List<Vote>();
        public virtual ICollection<Flag> Flags { get; set; } = new List<Flag>();
    }
}

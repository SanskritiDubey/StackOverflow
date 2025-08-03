using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace StackOverflowClone.Models
{
    public class Comment
    {
        public int Id { get; set; }

        [Required]
        [StringLength(600)]
        public string Body { get; set; } = string.Empty;

        public int Score { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        // Foreign Keys
        public int? QuestionId { get; set; }
        public int? AnswerId { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        // Navigation properties
        [ForeignKey("QuestionId")]
        public virtual Question? Question { get; set; }

        [ForeignKey("AnswerId")]
        public virtual Answer? Answer { get; set; }

        [ForeignKey("UserId")]
        public virtual ApplicationUser User { get; set; } = null!;

        public virtual ICollection<Vote> Votes { get; set; } = new List<Vote>();
        public virtual ICollection<Flag> Flags { get; set; } = new List<Flag>();
    }
}

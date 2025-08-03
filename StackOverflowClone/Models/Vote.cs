using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace StackOverflowClone.Models
{
    public enum VoteType
    {
        UpVote = 1,
        DownVote = -1
    }

    public class Vote
    {
        public int Id { get; set; }

        [Required]
        public VoteType VoteType { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Foreign Keys
        public int? QuestionId { get; set; }
        public int? AnswerId { get; set; }
        public int? CommentId { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        // Navigation properties
        [ForeignKey("QuestionId")]
        public virtual Question? Question { get; set; }

        [ForeignKey("AnswerId")]
        public virtual Answer? Answer { get; set; }

        [ForeignKey("CommentId")]
        public virtual Comment? Comment { get; set; }

        [ForeignKey("UserId")]
        public virtual ApplicationUser User { get; set; } = null!;
    }
}

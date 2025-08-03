using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace StackOverflowClone.Models
{
    public enum FlagType
    {
        Spam,
        Offensive,
        LowQuality,
        Duplicate,
        OffTopic,
        Other
    }

    public enum FlagStatus
    {
        Pending,
        Approved,
        Rejected,
        Dismissed
    }

    public class Flag
    {
        public int Id { get; set; }

        [Required]
        public FlagType FlagType { get; set; }

        public FlagStatus Status { get; set; } = FlagStatus.Pending;

        [StringLength(500)]
        public string? Reason { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? ResolvedAt { get; set; }

        public string? ResolvedByUserId { get; set; }

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

        [ForeignKey("ResolvedByUserId")]
        public virtual ApplicationUser? ResolvedByUser { get; set; }
    }
}

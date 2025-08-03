using System.ComponentModel.DataAnnotations;

namespace StackOverflowClone.Models
{
    public class Tag
    {
        public int Id { get; set; }

        [Required]
        [StringLength(50)]
        public string Name { get; set; } = string.Empty;

        [StringLength(500)]
        public string? Description { get; set; }

        public int UsageCount { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public string? WikiExcerpt { get; set; }

        // Navigation properties
        public virtual ICollection<QuestionTag> QuestionTags { get; set; } = new List<QuestionTag>();
    }
}

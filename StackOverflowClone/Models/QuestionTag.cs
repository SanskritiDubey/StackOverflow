using System.ComponentModel.DataAnnotations.Schema;

namespace StackOverflowClone.Models
{
    public class QuestionTag
    {
        public int QuestionId { get; set; }
        public int TagId { get; set; }

        // Navigation properties
        [ForeignKey("QuestionId")]
        public virtual Question Question { get; set; } = null!;

        [ForeignKey("TagId")]
        public virtual Tag Tag { get; set; } = null!;
    }
}

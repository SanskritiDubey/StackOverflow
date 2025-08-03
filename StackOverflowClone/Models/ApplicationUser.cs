using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace StackOverflowClone.Models
{
    public class ApplicationUser : IdentityUser
    {
        [Required]
        [StringLength(100)]
        public string DisplayName { get; set; } = string.Empty;

        [StringLength(500)]
        public string? Bio { get; set; }

        public int Reputation { get; set; } = 1;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public string? ProfileImageUrl { get; set; }

        public string? Location { get; set; }

        public string? Website { get; set; }

        // Navigation properties
        public virtual ICollection<Question> Questions { get; set; } = new List<Question>();
        public virtual ICollection<Answer> Answers { get; set; } = new List<Answer>();
        public virtual ICollection<Comment> Comments { get; set; } = new List<Comment>();
        public virtual ICollection<Vote> Votes { get; set; } = new List<Vote>();
        public virtual ICollection<Flag> Flags { get; set; } = new List<Flag>();
    }
}

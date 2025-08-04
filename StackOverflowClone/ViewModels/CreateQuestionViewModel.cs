using System.ComponentModel.DataAnnotations;

namespace StackOverflowClone.ViewModels
{
    public class CreateQuestionViewModel
    {
        [Required]
        [StringLength(300, ErrorMessage = "Title cannot exceed 300 characters")]
        [Display(Name = "Question Title")]
        public string Title { get; set; } = "";

        [Required]
        [Display(Name = "Question Details")]
        public string Body { get; set; } = "";

        [Display(Name = "Tags (comma separated)")]
        public string Tags { get; set; } = "";
    }
}

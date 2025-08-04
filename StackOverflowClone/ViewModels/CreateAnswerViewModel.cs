using System.ComponentModel.DataAnnotations;

namespace StackOverflowClone.ViewModels
{
    public class CreateAnswerViewModel
    {
        public int QuestionId { get; set; }
        
        public string QuestionTitle { get; set; } = "";

        [Required]
        [Display(Name = "Your Answer")]
        public string Body { get; set; } = "";
    }
}

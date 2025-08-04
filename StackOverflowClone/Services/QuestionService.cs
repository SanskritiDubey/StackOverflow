using Microsoft.EntityFrameworkCore;
using StackOverflowClone.Data;
using StackOverflowClone.Models;

namespace StackOverflowClone.Services
{
    public class QuestionService
    {
        private readonly ApplicationDbContext _context;

        public QuestionService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<Question>> GetQuestionsAsync(int page = 1, int pageSize = 15)
        {
            return await _context.Questions
                .Include(q => q.User)
                .Include(q => q.QuestionTags)
                    .ThenInclude(qt => qt.Tag)
                .Include(q => q.Answers)
                .OrderByDescending(q => q.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }

        public async Task<Question?> GetQuestionByIdAsync(int id)
        {
            return await _context.Questions
                .Include(q => q.User)
                .Include(q => q.QuestionTags)
                    .ThenInclude(qt => qt.Tag)
                .Include(q => q.Answers)
                    .ThenInclude(a => a.User)
                .FirstOrDefaultAsync(q => q.Id == id);
        }

        public async Task<List<Question>> SearchQuestionsAsync(string searchTerm)
        {
            return await _context.Questions
                .Include(q => q.User)
                .Include(q => q.QuestionTags)
                    .ThenInclude(qt => qt.Tag)
                .Where(q => q.Title.Contains(searchTerm) || q.Body.Contains(searchTerm))
                .OrderByDescending(q => q.CreatedAt)
                .ToListAsync();
        }

        public async Task<Question> CreateQuestionAsync(string title, string body, string userId, List<string> tagNames)
        {
            var question = new Question
            {
                Title = title,
                Body = body,
                UserId = userId,
                CreatedAt = DateTime.UtcNow,
                Views = 0,
                Score = 0
            };

            // Handle tags through QuestionTag relationship
            var questionTags = new List<QuestionTag>();
            foreach (var tagName in tagNames)
            {
                var existingTag = await _context.Tags.FirstOrDefaultAsync(t => t.Name == tagName);
                if (existingTag == null)
                {
                    existingTag = new Tag
                    {
                        Name = tagName,
                        Description = $"Questions tagged with {tagName}",
                        CreatedAt = DateTime.UtcNow
                    };
                    _context.Tags.Add(existingTag);
                }
                
                questionTags.Add(new QuestionTag
                {
                    Question = question,
                    Tag = existingTag
                });
            }

            question.QuestionTags = questionTags;
            _context.Questions.Add(question);
            await _context.SaveChangesAsync();

            return question;
        }

        public async Task<Answer> CreateAnswerAsync(int questionId, string body, string userId)
        {
            var answer = new Answer
            {
                QuestionId = questionId,
                Body = body,
                UserId = userId,
                CreatedAt = DateTime.UtcNow,
                Score = 0
            };

            _context.Answers.Add(answer);
            await _context.SaveChangesAsync();

            return answer;
        }

        public async Task IncrementViewsAsync(int questionId)
        {
            var question = await _context.Questions.FindAsync(questionId);
            if (question != null)
            {
                question.Views++;
                await _context.SaveChangesAsync();
            }
        }
    }
}

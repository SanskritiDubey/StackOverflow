using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using StackOverflowClone.Models;

namespace StackOverflowClone.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Question> Questions { get; set; }
        public DbSet<Answer> Answers { get; set; }
        public DbSet<Comment> Comments { get; set; }
        public DbSet<Tag> Tags { get; set; }
        public DbSet<QuestionTag> QuestionTags { get; set; }
        public DbSet<Vote> Votes { get; set; }
        public DbSet<Flag> Flags { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Configure QuestionTag many-to-many relationship
            builder.Entity<QuestionTag>()
                .HasKey(qt => new { qt.QuestionId, qt.TagId });

            builder.Entity<QuestionTag>()
                .HasOne(qt => qt.Question)
                .WithMany(q => q.QuestionTags)
                .HasForeignKey(qt => qt.QuestionId);

            builder.Entity<QuestionTag>()
                .HasOne(qt => qt.Tag)
                .WithMany(t => t.QuestionTags)
                .HasForeignKey(qt => qt.TagId);

            // Configure User relationships
            builder.Entity<Question>()
                .HasOne(q => q.User)
                .WithMany(u => u.Questions)
                .HasForeignKey(q => q.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.Entity<Answer>()
                .HasOne(a => a.User)
                .WithMany(u => u.Answers)
                .HasForeignKey(a => a.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.Entity<Comment>()
                .HasOne(c => c.User)
                .WithMany(u => u.Comments)
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.Entity<Vote>()
                .HasOne(v => v.User)
                .WithMany(u => u.Votes)
                .HasForeignKey(v => v.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            builder.Entity<Flag>()
                .HasOne(f => f.User)
                .WithMany(u => u.Flags)
                .HasForeignKey(f => f.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Configure Vote constraints
            builder.Entity<Vote>()
                .HasIndex(v => new { v.UserId, v.QuestionId })
                .IsUnique()
                .HasFilter("[QuestionId] IS NOT NULL");

            builder.Entity<Vote>()
                .HasIndex(v => new { v.UserId, v.AnswerId })
                .IsUnique()
                .HasFilter("[AnswerId] IS NOT NULL");

            builder.Entity<Vote>()
                .HasIndex(v => new { v.UserId, v.CommentId })
                .IsUnique()
                .HasFilter("[CommentId] IS NOT NULL");

            // Configure Tag name uniqueness
            builder.Entity<Tag>()
                .HasIndex(t => t.Name)
                .IsUnique();

            // Configure ApplicationUser display name
            builder.Entity<ApplicationUser>()
                .HasIndex(u => u.DisplayName)
                .IsUnique();

            // Configure cascade delete behaviors
            builder.Entity<Question>()
                .HasMany(q => q.Answers)
                .WithOne(a => a.Question)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Question>()
                .HasMany(q => q.Comments)
                .WithOne(c => c.Question)
                .OnDelete(DeleteBehavior.Cascade);

            builder.Entity<Answer>()
                .HasMany(a => a.Comments)
                .WithOne(c => c.Answer)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}

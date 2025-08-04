using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using StackOverflowClone.Data;
using StackOverflowClone.Models;
using StackOverflowClone.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

// Configure Entity Framework with SQLite for both Identity and application data
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlite(connectionString));

// Configure Identity
builder.Services.AddDefaultIdentity<ApplicationUser>(options => {
    options.SignIn.RequireConfirmedAccount = false;
    options.Password.RequireDigit = false;
    options.Password.RequireLowercase = false;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequireUppercase = false;
    options.Password.RequiredLength = 3;
    options.User.RequireUniqueEmail = true;
})
.AddRoles<IdentityRole>()
.AddEntityFrameworkStores<ApplicationDbContext>();

// Add custom services
builder.Services.AddScoped<QuestionService>();

builder.Services.AddControllersWithViews();

// Add Razor Pages for Identity UI
builder.Services.AddRazorPages();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}
else
{
    app.UseDeveloperExceptionPage();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

// Map Razor Pages for Identity
app.MapRazorPages();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

// Create sample users and ensure SQLite database is created
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<ApplicationDbContext>();
        var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();
        var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();
        
        // Ensure SQLite database is created with all tables
        context.Database.EnsureCreated();
        
        // Create roles
        if (!await roleManager.RoleExistsAsync("Admin"))
        {
            await roleManager.CreateAsync(new IdentityRole("Admin"));
        }
        if (!await roleManager.RoleExistsAsync("User"))
        {
            await roleManager.CreateAsync(new IdentityRole("User"));
        }
        
        // Create sample admin user
        if (await userManager.FindByEmailAsync("admin@test.com") == null)
        {
            var adminUser = new ApplicationUser
            {
                UserName = "admin@test.com",
                Email = "admin@test.com",
                DisplayName = "Administrator",
                Reputation = 1000,
                CreatedAt = DateTime.Now
            };
            await userManager.CreateAsync(adminUser, "Admin123");
            await userManager.AddToRoleAsync(adminUser, "Admin");
        }
        
        // Create sample regular user
        if (await userManager.FindByEmailAsync("user@test.com") == null)
        {
            var regularUser = new ApplicationUser
            {
                UserName = "user@test.com",
                Email = "user@test.com",
                DisplayName = "Test User",
                Reputation = 100,
                CreatedAt = DateTime.Now
            };
            await userManager.CreateAsync(regularUser, "User123");
            await userManager.AddToRoleAsync(regularUser, "User");
        }
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred seeding the Identity database.");
    }
}

app.Run();

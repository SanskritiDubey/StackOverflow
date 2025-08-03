using Microsoft.AspNetCore.Identity;
using StackOverflowClone.Models;

namespace StackOverflowClone.Data
{
    public static class SeedData
    {
        public static async Task Initialize(IServiceProvider serviceProvider,
            UserManager<ApplicationUser> userManager,
            RoleManager<IdentityRole> roleManager)
        {
            // Create roles
            string[] roleNames = { "Admin", "Moderator", "User" };
            
            foreach (var roleName in roleNames)
            {
                var roleExist = await roleManager.RoleExistsAsync(roleName);
                if (!roleExist)
                {
                    await roleManager.CreateAsync(new IdentityRole(roleName));
                }
            }

            // Create admin user
            var adminEmail = "admin@stackoverflow.com";
            var adminUser = await userManager.FindByEmailAsync(adminEmail);
            
            if (adminUser == null)
            {
                var newAdminUser = new ApplicationUser
                {
                    UserName = adminEmail,
                    Email = adminEmail,
                    DisplayName = "Administrator",
                    Bio = "Site Administrator",
                    Reputation = 10000,
                    EmailConfirmed = true
                };

                var result = await userManager.CreateAsync(newAdminUser, "Admin123!");
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(newAdminUser, "Admin");
                }
            }

            // Create sample moderator user
            var modEmail = "moderator@stackoverflow.com";
            var modUser = await userManager.FindByEmailAsync(modEmail);
            
            if (modUser == null)
            {
                var newModUser = new ApplicationUser
                {
                    UserName = modEmail,
                    Email = modEmail,
                    DisplayName = "Moderator",
                    Bio = "Site Moderator",
                    Reputation = 5000,
                    EmailConfirmed = true
                };

                var result = await userManager.CreateAsync(newModUser, "Mod123!");
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(newModUser, "Moderator");
                }
            }

            // Create sample regular user
            var userEmail = "user@stackoverflow.com";
            var regularUser = await userManager.FindByEmailAsync(userEmail);
            
            if (regularUser == null)
            {
                var newUser = new ApplicationUser
                {
                    UserName = userEmail,
                    Email = userEmail,
                    DisplayName = "Sample User",
                    Bio = "Just a regular user",
                    Reputation = 100,
                    EmailConfirmed = true
                };

                var result = await userManager.CreateAsync(newUser, "User123!");
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(newUser, "User");
                }
            }
        }
    }
}

using API.Extensions;
using API.Middleware;
using API.SignalR;
using Domain;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.EntityFrameworkCore;
using Persistence;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers(opt =>
{
    var policy = new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build();
    opt.Filters.Add(new AuthorizeFilter(policy));
});
builder.Services.AddApplicationServices(builder.Configuration);
builder.Services.AddIdentityServices(builder.Configuration);

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseMiddleware<ExceptionMiddleware>();

app.UseXContentTypeOptions();
app.UseReferrerPolicy(opt => opt.NoReferrer());
app.UseXXssProtection(opt => opt.EnabledWithBlockMode());
app.UseXfo(opt => opt.Deny());
app.UseCsp(opt => opt
        .BlockAllMixedContent()
        .StyleSources(s => s.Self().CustomSources("https://fonts.googleapis.com", "sha256-u+xQazuaujE1ccR2ek6LyT8rZKSWcc3XcofzTqmjwGA="))
        .FontSources(s => s.Self().CustomSources("data:", "https://fonts.gstatic.com"))
        .FormActions(s => s.Self())
        .FrameAncestors(s => s.Self())
        .ImageSources(s => s.Self().CustomSources("blob:", "data:", "https://res.cloudinary.com", "https://platform-lookaside.fbsbx.com"))
        .ScriptSources(s => s.Self().CustomSources("https://connect.facebook.net"))
);

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
else
{
    app.Use(async (context, next) =>
    {
        context.Response.Headers.Append("Strict-Transport-Security", "max-age=31536000");
        await next.Invoke();
    });
}

app.UseCors("CorsPolicy");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<ChatHub>("/chat");

app.MapGet("/healthz", () => Results.Ok(new 
{ 
    status = "healthy", 
    timestamp = DateTime.UtcNow.ToString("o") 
})).AllowAnonymous();

app.MapGet("/metadata", () => Results.Ok(new
{
    build = new
    {
        image_digest = Environment.GetEnvironmentVariable("IMAGE_DIGEST") ?? "unknown",
        commit_sha = Environment.GetEnvironmentVariable("COMMIT_SHA") ?? "unknown",
        build_timestamp = Environment.GetEnvironmentVariable("BUILD_TIMESTAMP") ?? "unknown",
        slsa_level = Environment.GetEnvironmentVariable("SLSA_LEVEL") ?? "unknown"
    },
    attestations = new
    {
        signed = Environment.GetEnvironmentVariable("IMAGE_SIGNED") == "true",
        sbom_attached = Environment.GetEnvironmentVariable("SBOM_ATTACHED") == "true",
        provenance_attached = Environment.GetEnvironmentVariable("PROVENANCE_ATTACHED") == "true"
    }
})).AllowAnonymous();

using var scope = app.Services.CreateScope();
var services = scope.ServiceProvider;

try
{
    var context = services.GetRequiredService<DataContext>();
    var userManager = services.GetRequiredService<UserManager<AppUser>>();
    await context.Database.MigrateAsync();
    await Seed.SeedData(context, userManager);
}
catch (Exception ex)
{
    var logger = services.GetRequiredService<ILogger<Program>>();
    logger.LogError(ex, "An error occured during migration");
}

app.Run();
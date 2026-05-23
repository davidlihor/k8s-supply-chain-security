using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Persistence;

namespace Infrastructure.Security
{
    public class IsHostRequirement : IAuthorizationRequirement
    {
    }

    public class IsHostRequirementHandler(DataContext dbContext, IHttpContextAccessor httpContextAccessor)
        : AuthorizationHandler<IsHostRequirement>
    {
        protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, IsHostRequirement requirement)
        {
            var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId is null) return Task.CompletedTask;

            var activityId = httpContextAccessor.HttpContext?.Request.RouteValues
                .SingleOrDefault(x => x.Key == "id").Value?.ToString();

            if (Guid.TryParse(activityId, out var idGuid) && idGuid == Guid.Empty) return Task.CompletedTask;
            
            var attendee = dbContext.ActivityAttendees
                .AsNoTracking()
                .SingleOrDefaultAsync(x => x.AppUserId == userId && x.ActivityId == idGuid)
                .Result;

            if (attendee is { IsHost: true }) context.Succeed(requirement);
            return Task.CompletedTask;
        }
    }
}
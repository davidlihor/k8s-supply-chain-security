namespace Domain
{
    public class UserFollowing
    {
        public string UserId { get; set; }
        public AppUser User { get; set; }
        public string TargetId { get; set; }
        public AppUser Target { get; set; }
    }
}
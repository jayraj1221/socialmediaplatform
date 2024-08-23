class Follower {
  final String id;         // Unique identifier for the follower relationship
  final String userId;     // ID of the user being followed
  final String followerId; // ID of the user who is following

  Follower({
    required this.id,
    required this.userId,
    required this.followerId,
  });
}

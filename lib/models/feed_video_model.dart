class FeedVideoModel {
  final String authorName;
  final String handle;
  final String authorAvatar;
  final String videoUrl;

  FeedVideoModel({
    required this.authorName,
    required this.handle,
    required this.authorAvatar,
    required this.videoUrl,
  });

  factory FeedVideoModel.fromJson(Map<String, dynamic> map) {
    final author = map['author'] ?? {};
    final embed = map['embed'] ?? {};
    final playlistUrl = embed['playlist'] ?? '';
    return FeedVideoModel(
      authorName: author['displayName'] ?? '',
      handle: author['handle'] ?? '',
      authorAvatar: author['avatar'] ?? '',
      videoUrl: playlistUrl,
    );
  }
}

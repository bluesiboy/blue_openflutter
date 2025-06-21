class Chat {
  final String avatar;
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  bool isMuted;
  bool isPinned;

  Chat({
    required this.avatar,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    this.isMuted = false,
    this.isPinned = false,
  });
}

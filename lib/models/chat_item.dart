import 'message_model.dart';

class ChatItem {
  final String avatar;
  final String name;
  final Message lastMessage;
  String time;
  int unread;
  bool isMuted;
  bool isPinned;
  bool isGroup;
  bool isDraft;
  bool isOnline;
  bool highlight;

  ChatItem({
    required this.avatar,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    this.isMuted = false,
    this.isPinned = false,
    this.isGroup = false,
    this.isDraft = false,
    this.isOnline = false,
    this.highlight = false,
  });
}

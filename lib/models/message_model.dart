class Message {
  final bool fromMe;
  final String type;
  final String content;
  final String time;
  String status;
  final double? width;
  final double? height;

  Message({
    required this.fromMe,
    required this.type,
    required this.content,
    required this.time,
    required this.status,
    this.width,
    this.height,
  });
}

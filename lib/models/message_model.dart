class Message {
  final String type; // text, image, voice, file, emoji
  final String content;
  final bool fromMe;
  String time;
  String status; // 可选: 发送状态
  final double? width;
  final double? height;

  Message({
    required this.type,
    required this.content,
    required this.time,
    this.fromMe = false,
    this.status = '',
    this.width,
    this.height,
  });
}

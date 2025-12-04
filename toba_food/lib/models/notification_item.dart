class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String type; // 'order_in' atau 'order_update'
  final int? orderId; // ID Order terkait
  final bool isRead;
  final String createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.orderId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      orderId: json['order_id'], // Pastikan di Laravel toArray() menyertakan ini
      isRead: json['is_read'],
      createdAt: json['created_at_human'] ?? json['created_at'],
    );
  }
}
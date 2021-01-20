class NotificationItem {
  int id;
  int notificationType;
  String title;
  String body;

  NotificationItem(Map<String, dynamic> item) {
    this.id = item["id"];
    this.notificationType = item["type"];
    this.title = item["title"];
    this.body = item["body"];
  }
}
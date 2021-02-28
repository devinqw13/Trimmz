class NotificationItem {
  int id;
  int notificationType;
  String title;
  String body;
  String profilePicture;
  String fromUser;
  bool read;

  NotificationItem(Map<String, dynamic> item) {
    this.id = item["id"];
    this.notificationType = item["type"];
    this.title = item["title"];
    this.body = item["message"];
    this.profilePicture = item["profile_picture"];
    this.fromUser = item['from_username'];
    this.read = item['read'] == 1 ? true : false;
  }
}
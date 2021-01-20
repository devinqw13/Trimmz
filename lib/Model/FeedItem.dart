class FeedItem {
  int id;
  int userId;
  String url;
  String caption;
  String name;
  String username;
  String profilePicture;
  DateTime created;

  FeedItem(Map<String, dynamic> item) {
    this.id = item['id'];
    this.userId = int.parse(item['userid']);
    this.url = item['url'];
    this.caption = item['caption'];
    this.name = item['name'];
    this.username = item['username'];
    this.profilePicture = item['profile_picture'];
    this.created = DateTime.parse(item['created']);
  }
}
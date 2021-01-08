import 'package:trimmz/globals.dart' as globals;

class GalleryItem {
  int id;
  int userId;
  String imageName;
  String caption;
  DateTime created;
  String name;
  String username;
  String profilePicture;

  GalleryItem(Map<String, dynamic> input) {
    this.id = input['id'];
    this.imageName = globals.baseImageUrl + input['url'];
    this.userId = int.parse(input['userid']);
    this.caption = input['caption'];
    this.created = DateTime.parse(input['created']);
    this.name = input['name'];
    this.username = input['username'];
    this.profilePicture = input['profile_picture'];
  }
}
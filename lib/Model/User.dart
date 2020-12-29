class Users {
  List<User> list = [];

  Users(List input) {
    for(Map item in input) {
      User user = new User(item);
      list.add(user);
    }
  }

}

class User {
  int id;
  String username;
  String name;
  String email;
  String shopName;
  String shopAddress;
  String city;
  String state;
  int zipcode;
  String profilePicture;
  String headerImage;
  String phoneNumber;
  bool display;

  User(Map input) {
    this.id = input['id'];
    this.username = input['username'];
    this.name = input['name'];
    this.email = input['email'];
    this.shopName = input['shop_name'];
    this.shopAddress = input['shop_address'];
    this.city = input['city'];
    this.state = input['state'];
    this.zipcode = input['zipcode'];
    this.profilePicture = input['profile_picture'];
    this.headerImage = input['header_image'];
    this.phoneNumber = input['phone'];
    this.display = input['diplay'] == "1" ? true : false;
  }
}
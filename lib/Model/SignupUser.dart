class SignupUser {
  String name;
  String username;
  String email;
  int type = 1;
  String password;
  String address;
  String city;
  String state;
  String zipcode;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'type': type,
      'password': password,
      'address': address,
      'city': city, // NOT USED
      'state': state, // NOT USED
      'zipcode': zipcode
    };
  }
}
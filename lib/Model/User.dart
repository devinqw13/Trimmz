import 'package:trimmz/Model/Availability.dart';
import 'package:trimmz/Model/GalleryItem.dart';
import 'package:trimmz/Model/Service.dart';
import 'package:trimmz/Model/Appointment.dart';

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
  int type;
  String rating;
  int numOfReviews;
  String bio;
  bool cardPaymentOnly;
  List<Availability> availability = [];
  List<GalleryItem> gallery = [];
  List<Service> services = [];
  Appointments appointments;
  bool isFollowing;

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
    this.type = input['type'];
    this.rating = input['rating'] ?? "0";
    this.numOfReviews = input['num_of_reviews'];
    this.bio = input['biography'];
    this.cardPaymentOnly = input['client_payment_option'] == 0 ? false : true ?? false;
    this.isFollowing = input['is_following'] != null ? true : false;
    if(input['availability'] != null) {
      for(var item in input['availability']) {
        this.availability.add(new Availability(item));
      }
    }
    if(input['gallery'] != null) {
      for(var item in input['gallery']) {
        this.gallery.add(new GalleryItem(item));
      }
    }
    if(input['services'] != null) {
      for(var item in input['services']) {
        this.services.add(new Service(item));
      }
    }
    if(input['appointments'] != null) {
      this.appointments = new Appointments(input['appointments']);
    }
  }
}
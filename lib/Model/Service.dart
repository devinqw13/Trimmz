class Service {
  int id;
  String name;
  int duration;
  int price;

  Service(Map<String, dynamic> input) {
    this.id = input['id'];
    this.name = input['name'];
    this.duration = input['duration'];
    this.price = input['price'];
  }
}
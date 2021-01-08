class Availability {
  int id;
  DateTime date;
  String start;
  String end;
  bool closed;

  Availability(Map<String, dynamic> input, {DateTime otherDate}) {
    this.id = input['id'];
    this.date = input['date'] != null ? DateTime.parse(input['date']) : otherDate;
    this.start = input['start'];
    this.end = input['end'];
    this.closed = input['closed'] == 1 ? true : false;
  }
}
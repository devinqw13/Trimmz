import 'package:intl/intl.dart';
import 'package:trimmz/Model/Service.dart';
import 'dart:convert';
import 'package:trimmz/globals.dart' as globals;

class Appointments {
  List<Appointment> list = [];
  Map<DateTime, List<dynamic>> calendarFormat = {};
  List<Appointment> requests = [];

  Appointments(List input) {
    final df = new DateFormat('yyyy-MM-dd');
    for(var item in input) {
      var dateString = item['date'];
      DateTime date = DateTime.parse(df.format(DateTime.parse(dateString)));

      if(item['status'] == 3 && globals.user.userType == 2) {
        Appointment appointment = new Appointment(item);
        requests.add(appointment);
      }else {
        Appointment appointment = new Appointment(item);
        list.add(appointment);
      }

      if(!calendarFormat.containsKey(date)) {
        calendarFormat[date] = [Map.from(item)];
      }else {
        calendarFormat[date].add(Map.from(item));
      }
    }
  }

}

class Appointment {
  int id;
  int clientID;
  int barberID;
  String clientName;
  String userName;
  List<Service> services = [];
  String appointmentTime;
  String appointmentFullTime;
  int status;
  double subTotal;
  double tip;
  double processingFee;
  int duration;
  String updated;
  String stripePaymentID;
  String stripeCustomerID;
  String email;
  String manualClientName;
  String manualClientPhone;
  bool cashPayment;
  String clientProfilePicture;
  String userProfilePicture;

  Appointment(Map input) {
    final df = new DateFormat('hh:mm a');

    this.id = input['id'];
    this.clientID = input['client_id'];
    this.barberID = input['barber_id'];
    this.clientName = input['client_name'];
    this.userName = input['user_name'];
    this.appointmentTime = df.format(DateTime.parse(input['date']));
    this.appointmentFullTime = input['date'];
    this.status = input['status'];
    this.subTotal = input['subtotal'];
    this.tip = input['tip'];
    this.processingFee = input['processing_fee'];
    this.duration = input['duration'];
    this.updated = input['updated'];
    this.stripePaymentID = input['sp_paymentId'];
    this.stripeCustomerID = input['sp_customerId'];
    this.email = input['email'];
    this.manualClientName = input['manual_client_name'];
    this.manualClientPhone = input['manual_client_phone'];
    this.cashPayment = input['cash_payment'] == 1 ? true : false;
    this.clientProfilePicture = input['client_pp'];
    this.userProfilePicture = input['barber_pp'];
    
    Map servicesJson = json.decode(input['services']);
    servicesJson.forEach((key, value) {
      services.add(new Service(value));
    });
  }
}
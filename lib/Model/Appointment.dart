import 'package:intl/intl.dart';

class Appointments {
  List<Appointment> list = [];
  Map<DateTime, List<dynamic>> calendarFormat = {};
  List<Appointment> requests = [];

  Appointments(List input) {
    final df = new DateFormat('hh:mm a');
    final df2 = new DateFormat('yyyy-MM-dd');
    for(var item in input) {
      var dateString = item['date'];
      DateTime date = DateTime.parse(df2.format(DateTime.parse(dateString)));

      if(item['status'] == 3) {
        Appointment appointment = new Appointment();
        appointment.id = item['id'];
        appointment.clientID = item['client_id'];
        appointment.barberID = item['barber_id'];
        appointment.clientName = item['client_name'];
        appointment.packageName = item['package_name'];
        appointment.appointmentTime = df.format(DateTime.parse(item['date']));
        appointment.appointmentFullTime = item['date'];
        appointment.status = item['status'];
        appointment.price = item['price'];
        appointment.tip = item['tip'];
        appointment.duration = item['duration'];
        appointment.updated = item['updated'];
        appointment.stripePaymentID = item['sp_paymentid'];
        appointment.stripeCustomerID = item['sp_customerid'];
        appointment.email = item['email'];
        appointment.manualClientName = item['manual_client_name'];
        appointment.manualClientPhone = item['manual_client_phone'];
        appointment.cashPayment = item['cash_payment'];
        appointment.clientProfilePicture = item['client_pp'];
        appointment.barberProfilePicture = item['barber_pp'];
        requests.add(appointment);
      }else {
        Appointment appointment = new Appointment();
        appointment.id = item['id'];
        appointment.clientID = item['client_id'];
        appointment.barberID = item['barber_id'];
        appointment.clientName = item['client_name'];
        appointment.packageName = item['package_name'];
        appointment.appointmentTime = df.format(DateTime.parse(item['date']));
        appointment.appointmentFullTime = item['date'];
        appointment.status = item['status'];
        appointment.price = item['price'];
        appointment.tip = item['tip'];
        appointment.duration = item['duration'];
        appointment.updated = item['updated'];
        appointment.stripePaymentID = item['sp_paymentid'];
        appointment.stripeCustomerID = item['sp_customerid'];
        appointment.email = item['email'];
        appointment.manualClientName = item['manual_client_name'];
        appointment.manualClientPhone = item['manual_client_phone'];
        appointment.cashPayment = item['cash_payment'];
        appointment.clientProfilePicture = item['client_pp'];
        appointment.barberProfilePicture = item['barber_pp'];
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
  String packageName;
  String appointmentTime;
  String appointmentFullTime;
  int status;
  int price;
  int tip;
  int duration;
  String updated;
  String stripePaymentID;
  String stripeCustomerID;
  String email;
  String manualClientName;
  String manualClientPhone;
  int cashPayment;
  String clientProfilePicture;
  String barberProfilePicture;
}
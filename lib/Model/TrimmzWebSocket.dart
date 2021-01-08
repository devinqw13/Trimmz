import 'package:web_socket_channel/io.dart';
import 'package:trimmz/globals.dart' as globals;

class TrimmzWebSocket {
  var channel = IOWebSocketChannel.connect(
    "wss://c3amg9ynvf.execute-api.us-east-2.amazonaws.com/production",
    headers: {"userId": globals.user.token, "screen": "conversation"}
  );
}
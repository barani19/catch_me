import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = IO.io('http://192.168.207.54:2000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    // Handle successful connection
    socket!.onConnect((_) {
      print("✅ Connected to Socket Server: ${socket!.id}");
    });

    // Handle errors
    socket!.onError((error) {
      print("⚠️ Socket Error: $error");
    });

    // Handle disconnection
    socket!.onDisconnect((_) {
      print("❌ Disconnected from server");
    });

    socket!.connect();
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}

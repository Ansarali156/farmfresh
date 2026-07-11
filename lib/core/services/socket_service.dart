import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/app_constants.dart';

class SocketService {
  io.Socket? _socket;
  final Map<String, StreamController<Map<String, dynamic>>> _listeners = {};

  void connect({required String token}) {
    if (_socket?.connected == true) return;

    _socket = io.io(
      AppConstants.socketBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Socket connected');
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket disconnected');
    });

    _socket!.onConnectError((err) {
      debugPrint('Socket connect error: $err');
    });

    _socket!.onError((err) {
      debugPrint('Socket error: $err');
    });

    _socket!.on('order:update', (data) {
      _emit('order:update', data);
    });

    _socket!.on('delivery:location', (data) {
      _emit('delivery:location', data);
    });

    _socket!.on('delivery:status', (data) {
      _emit('delivery:status', data);
    });
  }

  void _emit(String event, dynamic data) {
    final controller = _listeners[event];
    if (controller != null && !controller.isClosed) {
      if (data is Map<String, dynamic>) {
        controller.add(data);
      }
    }
  }

  Stream<Map<String, dynamic>> onEvent(String event) {
    _listeners[event] ??= StreamController<Map<String, dynamic>>.broadcast();
    return _listeners[event]!.stream;
  }

  void joinOrderRoom(String orderId) {
    _socket?.emit('join:order', {'orderId': orderId});
  }

  void leaveOrderRoom(String orderId) {
    _socket?.emit('leave:order', {'orderId': orderId});
  }

  void disconnect() {
    for (final controller in _listeners.values) {
      controller.close();
    }
    _listeners.clear();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}

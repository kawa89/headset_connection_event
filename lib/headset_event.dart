import 'dart:async';

import 'package:flutter/services.dart';

typedef WiredPluggedCallback = Function(WiredHeadsetState payload);
typedef BluetoothPluggedCallback = Function(BluetoothHeadsetState payload);

enum WiredHeadsetState {
  CONNECTED,
  DISCONNECTED,
}

enum BluetoothHeadsetState {
  CONNECTED,
  DISCONNECTED,
}

enum CurrentHeadsetState {
  DISCONNECTED,
  CONNECTED_WIRED,
  CONNECTED_BLUETOOTH,
  CONNECTED_WIRED_AND_BLUETOOTH,
}

class HeadsetEvent {
  static HeadsetEvent _instance;
  final MethodChannel _channel;
  WiredPluggedCallback wiredPluggedCallback;
  BluetoothPluggedCallback bluetoothPluggedCallback;

  factory HeadsetEvent() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel('flutter.moum/headset_event');
      _instance = HeadsetEvent.private(methodChannel);
    }
    return _instance;
  }

  HeadsetEvent.private(this._channel);

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<CurrentHeadsetState> get getCurrentState async {
    final int currentState = await _channel.invokeMethod('getCurrentState');
    switch (currentState) {
      case 0:
        return Future.value(CurrentHeadsetState.DISCONNECTED);
      case 1:
        return Future.value(CurrentHeadsetState.CONNECTED_WIRED);
      case 2:
        return Future.value(CurrentHeadsetState.CONNECTED_BLUETOOTH);
      case 3:
        return Future.value(CurrentHeadsetState.CONNECTED_WIRED_AND_BLUETOOTH);
      default:
        return Future.value(CurrentHeadsetState.DISCONNECTED);
    }
  }

  setWiredHeadSetListener(WiredPluggedCallback onPlugged) {
    wiredPluggedCallback = onPlugged;
    _channel.setMethodCallHandler(_handleMethod);
  }

  setBluetoothSetListener(BluetoothPluggedCallback onPlugged) {
    bluetoothPluggedCallback = onPlugged;
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    print('call.method: ${call.method}');
    switch (call.method) {
      case "connectWired":
        return wiredPluggedCallback(WiredHeadsetState.CONNECTED);
      case "disconnectWired":
        return wiredPluggedCallback(WiredHeadsetState.DISCONNECTED);
      case "connectBluetooth":
        return bluetoothPluggedCallback(BluetoothHeadsetState.CONNECTED);
      case "disconnectBluetooth":
        return bluetoothPluggedCallback(BluetoothHeadsetState.DISCONNECTED);
      default:
        print('_handleMethod default/unknown');
        bluetoothPluggedCallback(BluetoothHeadsetState.DISCONNECTED);
        return wiredPluggedCallback(WiredHeadsetState.DISCONNECTED);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:headset_connection_event/headset_event.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  HeadsetEvent headsetPlugin = new HeadsetEvent();
  WiredHeadsetState wiredHeadsetEvent;
  BluetoothHeadsetState bluetoothHeadsetEvent;
  CurrentHeadsetState currentHeadsetState;

  @override
  void initState() {
    super.initState();

    /// check one time, if headset is plugged
    updateCurrentState();

    /// Detect the moment headset is plugged or unplugged
    headsetPlugin.setBluetoothSetListener((_val) {
      updateCurrentState();
      setState(() {
        bluetoothHeadsetEvent = _val;
      });
    });
    
    headsetPlugin.setWiredHeadSetListener((_val) {
      updateCurrentState();
      setState(() {
        wiredHeadsetEvent = _val;
      });
    });
  }

  void updateCurrentState() {
    headsetPlugin.getCurrentState.then((_val) {
      setState(() {
        currentHeadsetState = _val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Better Headset Event Plugin'),
        ),
        body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
              Text(
                'currentHeadsetState:\n$currentHeadsetState\n',
                textAlign: TextAlign.left,
              ),
              Text(
                'wiredHeadsetEvent:\n$wiredHeadsetEvent\n',
                textAlign: TextAlign.left,
              ),
              Text(
                'bluetoothHeadsetEvent:\n$bluetoothHeadsetEvent\n',
                textAlign: TextAlign.left,
              ),
          ],
        ),
            )),
      ),
    );
  }
}

import 'package:control_pad/control_pad.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:control_pad/models/gestures.dart';
import 'package:control_pad/models/pad_button_item.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert' show utf8;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class JoyPad extends StatefulWidget {
  @override
  _JoyPadState createState() => _JoyPadState();
}

class _JoyPadState extends State<JoyPad> {

  // normal way is let users see the scan result and select one of them but
  // we have a target device

  final String joystick = 'Degree and Distance';
  final String joypad = 'joypad index number';

  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String TARGET_DEVICE_NAME = "ESP32 GET NOTI FROM DEVICE";

  FlutterBlue flutterBlue = FlutterBlue.instance; //Obtain an instance
  StreamSubscription<ScanResult>? scanSubScription;
  BluetoothDevice? targetDevice;
  BluetoothCharacteristic? targetCharacteristic;
  String connectionText = ""; //states of BL



  @override
  void dispose(){
    print('disposed');
    disconnectFromDevice();
    stopScan();
    super.dispose();

  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => startScan());

  }

  startScan() async {
    setState(() {
      connectionText = "Start Scanning";
    });

/*    print('scanning');
    if(!(await flutterBlue.isScanning.isEmpty) && (await flutterBlue.isScanning.last)){
      print('scanning');
      await flutterBlue.stopScan();
    }*/
    await flutterBlue.stopScan();
    scanSubScription?.cancel();
    scanSubScription = flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.name == TARGET_DEVICE_NAME) {
        print('DEVICE found');
        stopScan();
        setState(() {
          connectionText = "Found Target Device";
        });

        targetDevice = scanResult.device;
        connectToDevice();
      }
    }, onDone: (stopScan())
        , onError: (e) {
      print('start scan error : $e');
    }); //원래 => stopScan() 이였음
  }

  stopScan() {
    scanSubScription?.cancel();
    scanSubScription = null;
  }

  connectToDevice() async {
    if (targetDevice == null) return;

    setState(() {
      connectionText = "Device Connecting";
    });

    await targetDevice?.connect();
    print('DEVICE CONNECTED');
    setState(() {
      connectionText = "Device Connected";


    });

    discoverServices();
  }

  disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice?.disconnect();
    if(!mounted) {
      setState(() {
        connectionText = "Device Disconnected";
      });
    }
  }

  discoverServices() async {
    if (targetDevice == null) return;

    List<BluetoothService> services = await targetDevice!
        .discoverServices(); //targetDevice 앞에 await 지워줌
    services.forEach((service) {
      print(services);
      // do something with service
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            targetCharacteristic = characteristic;
            // writeData("Hi there, ESP32!!");
            setState(() {
              connectionText = "All Ready with ${targetDevice?.name}";
            });
          }
        });
      }
    });
  }

  //

  writeData(data) async {
    if (targetCharacteristic == null) return;
    List<int> bytes = utf8.encode(data);

    try {
      await targetCharacteristic!.write(
          bytes, withoutResponse: true); // what's the difference btween ? and i
    } catch (e) {
      print(data);
    }
  }


  // List<int> btn = List.filled(6,0);


  List<String> _btn = ['0', '0', '0', '0'];
  String degreeData = '';
  String distanceData = '';


  @override
  Widget build(BuildContext context) {
    JoystickDirectionCallback? onDirectionChanged(double degrees,
        double distance) {
      degreeData = '${degrees.toStringAsFixed(2)}';
      distanceData = '${distance.toStringAsFixed(2)}';

      final data =
          '$degreeData,$distanceData,${_btn[0]},${_btn[1]},${_btn[2]},${_btn[3]}';

      print(data);
      writeData(data);
    }

    PadButtonPressedCallback? padButtonPressedCallback(int buttonIndex,
        Gestures gestures) {
      // final joystickValue = JoystickView().onDirectionChanged;

      final buttonIndexData = "buttonIndex : ${buttonIndex}";

      _btn[buttonIndex] = Gestures.TAPDOWN == gestures ? '1' : '0';

      final data = '$degreeData,$distanceData,${_btn[0]},${_btn[1]},${_btn[2]},${_btn[3]}';
      print(data);
      print('gestures: $gestures');
      writeData(data);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Control Pad', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,)),
      ),
      body: Container(
        child: targetCharacteristic == null ? Center(
          child: Text(
            "Waiting...",
            style: TextStyle(fontSize: 24, color: Colors.red),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            JoystickView(
              onDirectionChanged: onDirectionChanged,
              interval: Duration(microseconds: 10),


            ),

            PadButtonsView(
              padButtonPressedCallback: padButtonPressedCallback,
              buttons: const [
                PadButtonItem(index: 2,
                    buttonText: "d",
                    supportedGestures: [
                      Gestures.TAPDOWN,
                      Gestures.TAPUP,
                      Gestures.LONGPRESSUP
                    ]),
                PadButtonItem(
                    index: 3,
                    buttonText: "c",
                    pressedColor: Colors.red,
                    supportedGestures: [
                      Gestures.TAPDOWN,
                      Gestures.TAPUP,
                      Gestures.LONGPRESSUP
                    ]),
                PadButtonItem(
                    index: 0,
                    buttonText: "a",
                    pressedColor: Colors.green,
                    supportedGestures: [
                      Gestures.TAPDOWN,
                      Gestures.TAPUP,
                      Gestures.LONGPRESSUP
                    ]),
                PadButtonItem(
                    index: 1,
                    buttonText: "b",
                    pressedColor: Colors.yellow,
                    supportedGestures: [
                      Gestures.TAPDOWN,
                      Gestures.TAPUP,
                      Gestures.LONGPRESSUP
                    ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
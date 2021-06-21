import 'dart:io';
import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:control_pad/models/gestures.dart';
import 'package:control_pad/models/pad_button_item.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert' show utf8;
import 'joypad.dart';
import 'package:flutter/widgets.dart';

  Future <void> main()  async {
  WidgetsFlutterBinding.ensureInitialized();
 await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
 runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Pad Example',
      home: Center(),
      theme: ThemeData.dark(),
    );
  }
}

class Center extends StatefulWidget {
  const Center({Key? key}) : super(key: key);

  @override
  _CenterState createState() => _CenterState();
}

class _CenterState extends State<Center> {


    @override
    void initState() {
    // TODO: implement initState
    super.initState();
    }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(onPressed: (){
        Navigator.push(context,MaterialPageRoute(builder: (context) => JoyPad()));
      }, child: Text('Joypad bluetooth', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:url_launcher/url_launcher.dart';

main() {
  runApp(
    const OKToast(child:MaterialApp(
          home: Example(),
        )
    ),
  );
}

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  bool granted = false;

  Future<bool> requestPermission() async {
    var status = await Permission.phone.request();

    switch (status) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.granted:
      case PermissionStatus.provisional:
        return true;
    }
  }

  @override
  void initState() {
    super.initState();
    
  }

  void setStream() {
    PhoneState.phoneStateStream.listen((event) {
        switch (event) {
          case PhoneStateStatus.NOTHING:
          showToast('NOTHING');
          break;
          case PhoneStateStatus.CALL_INCOMING:
          showToast('CALL_INCOMING');
          break;
          case PhoneStateStatus.CALL_STARTED:
          showToast('CALL_STARTED');
          break;
          case PhoneStateStatus.CALL_ENDED:
          showToast('CALL_ENDED');
          break;
        }
        setState(() {
          if (event != null) {
            status = event;
          }
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone State"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (Platform.isAndroid)
              MaterialButton(
                child: const Text("Request permission of Phone"),
                onPressed: !granted
                    ? () async {
                        bool temp = await requestPermission();
                        setState(() {
                          granted = temp;
                          if (granted) {
                            setStream();
                          }
                        });
                      }
                    : null,
              ),
            const Text(
              "Status of call",
              style: TextStyle(fontSize: 24),
            ),
            TextButton(onPressed: () async{
                if (Platform.isIOS) setStream();
               await launchUrl(Uri(scheme: 'tel', path: '13510883751'));
            }, child: const Text('Call Phone')),
            Icon(
              getIcons(),
              color: getColor(),
              size: 80,
            )
          ],
        ),
      ),
    );
  }

  IconData getIcons() {
    switch (status) {
      case PhoneStateStatus.NOTHING:
        return Icons.clear;
      case PhoneStateStatus.CALL_INCOMING:
        return Icons.add_call;
      case PhoneStateStatus.CALL_STARTED:
        return Icons.call;
      case PhoneStateStatus.CALL_ENDED:
        return Icons.call_end;
    }
  }

  Color getColor() {
    switch (status) {
      case PhoneStateStatus.NOTHING:
      case PhoneStateStatus.CALL_ENDED:
        return Colors.red;
      case PhoneStateStatus.CALL_INCOMING:
        return Colors.green;
      case PhoneStateStatus.CALL_STARTED:
        return Colors.orange;
    }
  }
}

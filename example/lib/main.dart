import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:in_app_purchase_amazon/in_app_purchase_amazon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _inAppPurchaseAmazonPlugin = InAppPurchaseAmazon();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initAmazon();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _inAppPurchaseAmazonPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  AmazonUserData? _clientInformation;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAmazon() async {
    AmazonUserData? clientInformation;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      await _inAppPurchaseAmazonPlugin.initialize();

      _inAppPurchaseAmazonPlugin.clientInformationStream.listen(
        (event) {
          debugPrint(event?.toString());
        },
        onError: (e, s) {
          debugPrint(e);
          debugPrintStack(stackTrace: s);
        },
      );

      clientInformation =
          await _inAppPurchaseAmazonPlugin.getClientInformation();
    } on PlatformException {
      clientInformation = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _clientInformation = clientInformation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Running on: $_platformVersion\n'),
            Text(
              'User information: ${_clientInformation ?? "'Failed to get platform version.'"}\n',
            ),
          ],
        ),
      ),
    );
  }
}

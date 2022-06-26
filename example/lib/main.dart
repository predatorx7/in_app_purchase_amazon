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
    initAmazon().then((_) {
      getSdkMode().then((_) {
        _inAppPurchaseAmazonPlugin.getClientInformation();
      });
    });
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

  String? _amazonSdkMode;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getSdkMode() async {
    String amazonSdkMode;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      amazonSdkMode = await _inAppPurchaseAmazonPlugin.getAmazonSdkMode() ??
          'Unknown AppStore SDK Mode';
    } on PlatformException {
      amazonSdkMode = 'Failed to get AppStore SDK Mode.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _amazonSdkMode = amazonSdkMode;
    });
  }

  AmazonUserData? _clientInformation;
  String? _licenseVerificationResponse;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initAmazon() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      await _inAppPurchaseAmazonPlugin.initialize();

      _inAppPurchaseAmazonPlugin.licenseVerificationResponseStream.listen(
        _onLicenseVerificationUpdate,
        onError: (e, s) {
          debugPrint(e);
          debugPrintStack(stackTrace: s);
          _inAppPurchaseAmazonPlugin.getClientInformation();
        },
      );

      _inAppPurchaseAmazonPlugin.clientInformationStream.listen(
        _onClientInformationUpdate,
        onError: (e, s) {
          debugPrint(e);
          debugPrintStack(stackTrace: s);
        },
      );
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
    }
  }

  void _onLicenseVerificationUpdate(String? response) {
    debugPrint('License Verification Response: $response');
    setState(() {
      _licenseVerificationResponse = response;
    });
    _inAppPurchaseAmazonPlugin.getClientInformation();
  }

  void _onClientInformationUpdate(AmazonUserData? event) {
    debugPrint(event?.toString());
    setState(() {
      _clientInformation = event;
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
            Text(
              'Running on: $_platformVersion\n',
            ),
            Text(
              'Amazon Appstore SDK mode: $_amazonSdkMode\n',
            ),
            Text(
              'Amazon License verification state: $_licenseVerificationResponse\n',
            ),
            Text(
              'User information: $_clientInformation\n',
            ),
          ],
        ),
      ),
    );
  }
}

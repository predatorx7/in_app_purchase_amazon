# in_app_purchase_amazon

A new Flutter plugin project.

## Getting Started

- Install Amazon App Store on Target device from https://www.amazon.com/Amazon-App-Tester/dp/B00BN3YZM2/

- Add below query in AndroidManifest.xml
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    ...>
    ...
    <queries>
        <package android:name="com.amazon.venezia"/>
    </queries>
    ...
```

- Add rules below in `<project-root>\android\app\proguard-rules.pro`
```pro
-keep class com.amazon.** {*;}
-keep class com.android.vending.billing.**
-dontwarn com.amazon.**
-keepattributes *Annotation*

```

- Follow instructions at https://developer.amazon.com/docs/in-app-purchasing/integrate-appstore-sdk.html#configure_key

- Follow instructions at https://developer.amazon.com/docs/in-app-purchasing/iap-implement-iap.html#responsereceiver

- Push test file for testing on target test device with "Amazon App Tester" app installed (else you'll get unknown on non-amazon devices)
```
adb push ancillary/amazon.sdktester.json /sdcard/
```

- Enable debug sandboxing with (reference https://developer.amazon.com/es/docs/in-app-purchasing/iap-app-tester-user-guide.html#installtester)
```
adb shell setprop debug.amazon.sandboxmode debug
```

- To exit sandbox, type `adb shell setprop debug.amazon.sandboxmode none`

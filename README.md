# flutter_acpplaces

## Notice of deprecation

Since *April 25, 2023*, [Apple has required](https://developer.apple.com/news/?id=jd9wcyov) apps submitted to the App Store to be built with Xcode 14.1 or later. The Experience Platform Mobile SDKs and extensions outlined below were built with prior versions of Xcode and are no longer compatible with iOS and iPadOS given Apple’s current App Store requirements. Consequently, on *August 31, 2023*, Adobe will be deprecating support for the following Experience Platform Mobile SDKs and wrapper extensions:

- [ACP iOS SDK](https://developer.adobe.com/client-sdks/previous-versions/documentation/sdk-versions/#ios)
- [Cordova](https://developer.adobe.com/client-sdks/previous-versions/documentation/sdk-versions/#cordova)
- [Flutter for ACP](https://developer.adobe.com/client-sdks/previous-versions/documentation/sdk-versions/#flutter)
- [React Native for ACP](https://developer.adobe.com/client-sdks/previous-versions/documentation/sdk-versions/#react-native)
- [Xamarin](https://developer.adobe.com/client-sdks/previous-versions/documentation/sdk-versions/#xamarin)

After *August 31, 2023*, applications already submitted to the App Store that contain these SDKs and wrapper extensions will continue to operate, however, Adobe will not be providing security updates or bug fixes, and these SDKs and wrapper extensions will be provided as-is exclusive of any warranty, due to the App Store policy outlined above.

We encourage all customers to migrate to the latest Adobe Experience Platform versions of the Mobile SDK to ensure continued compatibility and support. Documentation for the latest versions of the Adobe Experience Platform Mobile SDKs can be found [here](https://developer.adobe.com/client-sdks/documentation/current-sdk-versions/). The iOS migration guide can be found [here](https://developer.adobe.com/client-sdks/previous-versions/documentation/migrate-to-swift/).

---

[![pub package](https://img.shields.io/pub/v/flutter_acpplaces.svg)](https://pub.dartlang.org/packages/flutter_acpplaces) ![Build](https://github.com/adobe/flutter-acpplaces/workflows/Dart%20Unit%20Tests%20+%20Android%20Build%20+%20iOS%20Build/badge.svg) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

`flutter_acpplaces` is a flutter plugin for the iOS and Android [AEP Places SDK](https://docs.adobe.com/content/help/en/places/using/places-ext-aep-sdks/places-extension/places-extension.html) to allow for integration with flutter applications. Functionality to enable the Places extension is provided entirely through Dart documented below.

## Installation

Install instructions for this package can be found [here](https://pub.dev/packages/flutter_acpplaces#-installing-tab-).

> Note: After you have installed the SDK, don't forget to run `pod install` in your `ios` directory to link the libraries to your Xcode project.

## Tests

Run:

```bash
flutter test
```

## Usage

### [Places](https://docs.adobe.com/content/help/en/places/using/places-ext-aep-sdks/places-extension/places-extension.html)

##### Importing the SDK:
```dart
import 'package:flutter_acpplaces/flutter_acpplaces.dart';
```

##### Getting the SDK version:
 ```dart
String version = await FlutterACPPlaces.extensionVersion;
 ```

 ##### Registering the extension with ACPCore:

 > Note: It is required to initialize the SDK via native code inside your AppDelegate and MainApplication for iOS and Android respectively. For more information see how to initialize [Core](https://aep-sdks.gitbook.io/docs/getting-started/get-the-sdk#2-add-initialization-code).

 ##### **iOS**
Swift
 ```swift
import ACPPlaces

ACPPlaces.registerExtension()
 ```
Objective-C
 ```objective-c
#import "ACPPlaces.h"

[ACPPlaces registerExtension];
 ```

 ##### **Android:**
 ```java
import com.adobe.marketing.mobile.Places;

Places.registerExtension();
 ```

##### Clear client side Places plugin data:

```dart
try {
  await FlutterACPPlaces.clear;
} on PlatformException {
  log("Failed to clear Places data.");
}
```

##### Get the current POI's that the device is currently known to be within:

```dart
String pois;
try {
  pois = await FlutterACPPlaces.currentPointsOfInterest;
} on PlatformException {
  log("Failed to get the current POI's.");
}
```

##### Get the last latitude and longitude stored in the Places plugin:

```dart
String location;
try {
  location = await FlutterACPPlaces.lastKnownLocation;
} on PlatformException {
  log("Failed to get the last known location.");
}
```

##### Get a list of nearby POI's:

```dart
String pois;
try {
  var location = {'latitude':37.3309422, 'longitude': -121.8939077};
  pois = await FlutterACPPlaces.getNearbyPointsOfInterest(location, 100);
} on PlatformException {
  log("Failed to get the nearby POI's.");
}
```

##### Pass a Geofence and transition type to be processed by the Places plugin:

```dart
var geofence = new Geofence({'requestId':'d4e72ade-0400-4280-9bfe-8ba7553a6444', 'latitude':37.3309422, 'longitude': -121.8939077, 'radius': 1000, 'expirationDuration':-1});
FlutterACPPlaces.processGeofence(geofence, ACPPlacesRegionEventType.ENTRY);
```

##### Set the authorization status:

```dart
FlutterACPPlaces.setAuthorizationStatus(ACPPlacesAuthorizationStatus.ALWAYS);
```

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md)

## License
See [LICENSE](LICENSE)

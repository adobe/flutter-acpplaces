# flutter_acpplaces

[![pub package](https://img.shields.io/pub/v/flutter_acpplaces.svg)](https://pub.dartlang.org/packages/flutter_acpplaces) ![Build](https://github.com/adobe/flutter_acpplaces/workflows/Dart%20Unit%20Tests%20+%20Android%20Build%20+%20iOS%20Build/badge.svg) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

`flutter_acpplaces` is a flutter plugin for the iOS and Android [AEP Places SDK](https://aep-sdks.gitbook.io/docs/using-mobile-extensions/places) to allow for integration with flutter applications. Functionality to enable the Places extension is provided entirely through Dart documented below.

## Installation

Install instructions for this package can be found [here](https://pub.dev/packages/flutter_acpplaces#-installing-tab-).

> Note: After you have installed the SDK, don't forget to run `pod install` in your `ios` directory to link the libraries to your Xcode project.

## Tests

Run:

```bash
flutter test
```

## Usage

### [Places](https://aep-sdks.gitbook.io/docs/using-mobile-extensions/places)

##### Importing the SDK:
```dart
import 'package:flutter_acpplaces/flutter_acpplaces.dart';
```

##### Getting the SDK version:
 ```dart
String version = await FlutterACPPlaces.extensionVersion;
 ```

 ##### Registering the extension with ACPCore:

 > Note: It is required to initialize the SDK via native code inside your AppDelegate and MainApplication for iOS and Android respectively. For more information see how to initialize [Core](https://aep-sdks.gitbook.io/docs/getting-started/initialize-the-sdk).

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

## Contributing
See [CONTRIBUTING](CONTRIBUTING.md)

## License
See [LICENSE](LICENSE)

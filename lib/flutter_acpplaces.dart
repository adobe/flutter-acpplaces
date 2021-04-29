/*
Copyright 2020 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_acpplaces/src/flutter_acpplaces_objects.dart';
export 'package:flutter_acpplaces/src/flutter_acpplaces_objects.dart';

/// Adobe Experience Platform Places API.
class FlutterACPPlaces {
  static const MethodChannel _channel =
      const MethodChannel('flutter_acpplaces');

  /// Gets the current Places extension version.
  static Future<String> get extensionVersion =>
      _channel.invokeMethod<String>('extensionVersion').then((value) => value!);

  /// Clears out the client-side data for Places.
  static Future<void> clear() => _channel.invokeMethod('clear');

  /// Returns all Points of Interest (POI) in which the device is currently known to be within.
  static Future<String?> get currentPointsOfInterest =>
      _channel.invokeMethod<String>('getCurrentPointsOfInterest');

  /// Returns the last latitude and longitude provided to the ACPPlaces Extension.
  static Future<String?> get lastKnownLocation =>
      _channel.invokeMethod<String>('getLastKnownLocation');

  /// Requests a list of nearby Points of Interest (POI).
  static Future<String?> getNearbyPointsOfInterest(
    final Map location,
    final int limit,
  ) =>
      _channel.invokeMethod<String>('getNearbyPointsOfInterest', {
        'Location': location,
        'Limit': limit,
      });

  /// Pass a Geofence and transition type to be processed by the SDK.
  /// This corresponds to Android ACPPlaces.processGeofence and iOS ACPPlaces.processRegionEvent
  static Future<void> processGeofence(
    final Geofence geofence,
    final ACPPlacesRegionEventType transitionType,
  ) =>
      _channel.invokeMethod('processGeofence', {
        'Geofence': geofence.data,
        'TransitionType': transitionType.value,
      });

  /// Sets the authorization status in the Places extension.
  static Future<void> setAuthorizationStatus(
          final ACPPlacesAuthorizationStatus status) =>
      _channel.invokeMethod(
        'setAuthorizationStatus',
        status.value,
      );
}

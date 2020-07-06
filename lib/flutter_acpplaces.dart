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

/// Adobe Experience Platform Places API.
class FlutterACPPlaces {
  static const MethodChannel _channel =
      const MethodChannel('flutter_acpplaces');

  /// Gets the current Places extension version.
  static Future<String> get extensionVersion async {
    final String version = await _channel.invokeMethod('extensionVersion');
    return version;
  }

  /// Returns all Points of Interest (POI) in which the device is currently known to be within.
  static Future<List<PlacesPoi>>  get CurrentPointsOfInterest async {
    final List<dynamic> result = await _channel.invokeListMethod<dynamic>('getCurrentPointsOfInterest');
    return result
        ?.list<PlacesPoi>(
          (dynamic data) => PlacesPoi(data),
        )
        ?.toList();
  }

  /// Returns the last latitude and longitude provided to the ACPPlaces Extension.
  static Future<void> get LastKnownLocation async {
    final Location location = await _channel.invokeMethod('getLastKnownLocation');
    return location;
  }

  /// Requests a list of nearby Points of Interest (POI).
  static Future<List<PlacesPoi>>  get NearbyPointsOfInterest(final Location location, final int limit) async {
    final List<dynamic> result = await _channel.invokeListMethod<dynamic>(
      'getNearbyPointsOfInterest',{
      'Location': location,
      'Limit': limit
    });
    return result
        ?.list<PlacesPoi>(
          (dynamic data) => PlacesPoi(data),
        )
        ?.toList();
  }

  /// Pass a Geofence and transition type to be processed by the SDK.
  /// This corresponds to Android ACPPlaces.processGeofence and iOS ACPPlaces.processRegionEvent
  static Future<void> processGeofence(final Geofence geofence, final int transitionType) async {
    await _channel.invokeMethod('processGeofence',{
      'Geofence': geofence,
      'TransitionType': transitionType
    });
  }

  /// Sets the authorization status in the Places extension.
  static Future<void> setAuthorizationStatus(final PlacesAuthorizationStatus status) async {
    await _channel.invokeMethod('setAuthorizationStatus', status ?? PlacesAuthorizationStatus.DENIED);
  }

}

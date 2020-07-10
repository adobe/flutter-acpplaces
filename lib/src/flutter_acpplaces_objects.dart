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

import 'dart:wasm';

/// This is used to indicate the Places Authorization Status
class ACPPlacesAuthorizationStatus {
  final int value;

  const ACPPlacesAuthorizationStatus(this.value);

  static const ACPPlacesAuthorizationStatus DENIED =
  const ACPPlacesAuthorizationStatus(0);
  static const ACPPlacesAuthorizationStatus ALWAYS =
  const ACPPlacesAuthorizationStatus(1);
  static const ACPPlacesAuthorizationStatus UNKNOWN =
  const ACPPlacesAuthorizationStatus(2);
  static const ACPPlacesAuthorizationStatus RESTRICTED =
  const ACPPlacesAuthorizationStatus(3);
  static const ACPPlacesAuthorizationStatus WHENINUSE =
  const ACPPlacesAuthorizationStatus(4);
}

/// This is used to indicate the Region Event Type
class ACPPlacesRegionEventType {
  final int value;

  const ACPPlacesRegionEventType(this.value);

  static const ACPPlacesRegionEventType NONE =
  const ACPPlacesRegionEventType(0);
  static const ACPPlacesRegionEventType ENTRY =
  const ACPPlacesRegionEventType(1);
  static const ACPPlacesRegionEventType EXIT =
  const ACPPlacesRegionEventType(2);
}

/// This is an object representing a geofence
class Geofence {
  Map<dynamic, dynamic> _data;

  Geofence(this._data);

  Geofence.createGeofence(final String requestId, final Double latitude, final Double longitude, final Double radius, final Double expirationDuration) {
    final Map<dynamic, dynamic> geofenceConstructorData = {
      "requestId": requestId,
      "latitude": latitude,
      "longitude": longitude,
      "radius": radius,
      "expirationDuration": expirationDuration
    };
    this._data = geofenceConstructorData;
  }

  set data(Map<dynamic, dynamic> val) => _data = val;

  /// Dictionary representation of this event
  Map<dynamic, dynamic> get data => _data;

  /// The request id
  String get requestId => _data['requestId'];

  /// The latitude
  Double get latitude => _data['latitude'];

  /// The longitude
  Double get longitude => _data['longitude'];

  /// The radius
  Double get radius => _data['radius'];

  /// The expiration duration
  Double get expirationDuration => _data['expirationDuration'];
}
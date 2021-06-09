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

/// This is used to indicate the Places Authorization Status
enum ACPPlacesAuthorizationStatus {
  denied,
  always,
  unknown,
  restricted,
  whenInUse
}

extension ACPPlacesAuthorizationStatusExt on ACPPlacesAuthorizationStatus {
  int get value {
    switch (this) {
      case ACPPlacesAuthorizationStatus.denied:
        return 0;
      case ACPPlacesAuthorizationStatus.always:
        return 1;
      case ACPPlacesAuthorizationStatus.unknown:
        return 2;
      case ACPPlacesAuthorizationStatus.restricted:
        return 3;
      case ACPPlacesAuthorizationStatus.whenInUse:
        return 4;
    }
  }
}

extension ACPPlacesAuthorizationStatusValueExt on int {
  ACPPlacesAuthorizationStatus get toACPPlacesAuthorizationStatus {
    switch (this) {
      case 0:
        return ACPPlacesAuthorizationStatus.denied;
      case 1:
        return ACPPlacesAuthorizationStatus.always;
      case 2:
        return ACPPlacesAuthorizationStatus.unknown;
      case 3:
        return ACPPlacesAuthorizationStatus.restricted;
      case 4:
        return ACPPlacesAuthorizationStatus.whenInUse;
    }
    throw Exception('Invalid ACPPlacesAuthorizationStatus value: $this');
  }
}

/// This is used to indicate the Region Event Type
enum ACPPlacesRegionEventType { none, entry, exit }

extension ACPPlacesRegionEventTypeExt on ACPPlacesRegionEventType {
  int get value {
    switch (this) {
      case ACPPlacesRegionEventType.none:
        return 0;
      case ACPPlacesRegionEventType.entry:
        return 1;
      case ACPPlacesRegionEventType.exit:
        return 2;
    }
  }
}

extension ACPPlacesRegionEventTypeValueExt on int {
  ACPPlacesRegionEventType get toACPPlacesRegionEventType {
    switch (this) {
      case 0:
        return ACPPlacesRegionEventType.none;
      case 1:
        return ACPPlacesRegionEventType.entry;
      case 2:
        return ACPPlacesRegionEventType.exit;
    }
    throw Exception('Invalid ACPPlacesRegionEventType value: $this');
  }
}

/// This is an object representing a geofence
class Geofence {
  Geofence(this.data);

  Geofence.createGeofence(
    String requestId,
    double latitude,
    double longitude,
    double radius,
    double expirationDuration,
  ) {
    final Map<dynamic, dynamic> geofenceConstructorData = {
      "requestId": requestId,
      "latitude": latitude,
      "longitude": longitude,
      "radius": radius,
      "expirationDuration": expirationDuration
    };
    this.data = geofenceConstructorData;
  }

  /// Dictionary representation of this event
  late Map<dynamic, dynamic> data;

  /// The request id
  String? get requestId => data['requestId'];

  /// The latitude
  double? get latitude => data['latitude'];

  /// The longitude
  double? get longitude => data['longitude'];

  /// The radius
  double? get radius => data['radius'];

  /// The expiration duration
  double? get expirationDuration => data['expirationDuration'];
}

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

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_acpplaces/flutter_acpplaces.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_acpplaces');

  TestWidgetsFlutterBinding.ensureInitialized();

  group('extensionVersion', () {
    final String testVersion = "1.4.2";
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return testVersion;
      });
    });

    test('invokes correct method', () async {
      await FlutterACPPlaces.extensionVersion;

      expect(log, <Matcher>[
        isMethodCall(
          'extensionVersion',
          arguments: null,
        ),
      ]);
    });

    test('returns correct result', () async {
      expect(await FlutterACPPlaces.extensionVersion, testVersion);
    });
  });

  group('clear', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });
    });

    test('invokes correct method', () async {
      await FlutterACPPlaces.clear();

      expect(log, <Matcher>[
        isMethodCall(
          'clear',
          arguments: null,
        ),
      ]);
    });
  });

  group('currentPointsOfInterest', () {
    final String testPois = "[{\"POI\":\"testPoi\",\"latitude\":37.331372,\"longitude\":-121.8934039,\"identifier\":\"1dee0063-ffcd-4809-8da4-130645d8fa9a\"}]";
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return testPois;
      });
    });

    test('invokes correct method', () async {
      await FlutterACPPlaces.currentPointsOfInterest;

      expect(log, <Matcher>[
        isMethodCall(
          'getCurrentPointsOfInterest',
          arguments: null,
        ),
      ]);
    });

    test('returns correct result', () async {
      expect(await FlutterACPPlaces.currentPointsOfInterest, testPois);
    });
  });

  group('lastKnownLocation', () {
    final String testLocation = "{\"latitude\":30,\"longitude\":-120}";
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return testLocation;
      });
    });

    test('invokes correct method', () async {
      await FlutterACPPlaces.lastKnownLocation;

      expect(log, <Matcher>[
        isMethodCall(
          'getLastKnownLocation',
          arguments: null,
        ),
      ]);
    });

    test('returns correct result', () async {
      expect(await FlutterACPPlaces.lastKnownLocation, testLocation);
    });
  });

  group('getNearbyPointsOfInterest', () {
    final String testPois = "[{\"POI\":\"testPoi\",\"latitude\":37.331372,\"longitude\":-121.8934039,\"identifier\":\"1dee0063-ffcd-4809-8da4-130645d8fa9a\"}]";
    final Map location = {'latitude':37.3309422, 'longitude': -121.8939077};
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return testPois;
      });
    });

    test('invokes correct method', () async {
      await FlutterACPPlaces.getNearbyPointsOfInterest(location, 100);

      expect(log, <Matcher>[
        isMethodCall(
          'getNearbyPointsOfInterest',
          arguments: {'Location':location, 'Limit':100},
        ),
      ]);
    });

    test('returns correct result', () async {
      expect(await FlutterACPPlaces.getNearbyPointsOfInterest(location, 100), testPois);
    });
  });

  group('processGeofence', () {
    final Geofence geofence = new Geofence({'requestId':'d4e72ade-0400-4280-9bfe-8ba7553a6444', 'latitude':37.3309422, 'longitude': -121.8939077, 'radius': 1000, 'expirationDuration':-1});
    final ACPPlacesRegionEventType eventType = ACPPlacesRegionEventType.entry;
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });
    });

    test('invokes correct method', () async {
      await FlutterACPPlaces.processGeofence(geofence, eventType);

      expect(log, <Matcher>[
        isMethodCall(
          'processGeofence',
          arguments: {'Geofence':geofence.data, 'TransitionType':eventType.value},
        ),
      ]);
    });
  });

  group('setAuthorizationStatus', () {
    final ACPPlacesAuthorizationStatus status = ACPPlacesAuthorizationStatus.always;
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });
    });

    test('invokes correct method', () async {
      await FlutterACPPlaces.setAuthorizationStatus(status);

      expect(log, <Matcher>[
        isMethodCall(
          'setAuthorizationStatus',
          arguments: status.value,
        ),
      ]);
    });
  });
}
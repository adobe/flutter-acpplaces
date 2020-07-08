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

import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_acpplaces/flutter_acpplaces.dart';
import 'package:flutter_acpplaces/src/flutter_acpplaces_objects.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _currentpois = "null";
  String _nearbypois = "null";
  String _location = "null";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterACPPlaces.extensionVersion;
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

  Future<void> clear() async {
    try {
      await FlutterACPPlaces.clear;
    } on PlatformException {
      log("Failed to clear Places data.");
    }
  }

  Future<void> getCurrentPointsOfInterest() async {
    String pois;
    try {
      pois = await FlutterACPPlaces.currentPointsOfInterest;
    } on PlatformException {
      log("Failed to get the current POI's.");
    }

    if (!mounted) return;
    setState(() {
      _currentpois = pois.toString();
    });
  }

  Future<void> getLastKnownLocation() async {
    String location;
    try {
      location = await FlutterACPPlaces.lastKnownLocation;
    } on PlatformException {
      log("Failed to get the last known location.");
    }

    if (!mounted) return;
    setState(() {
      _location = location;
    });
  }

  Future<void> getNearbyPointsOfInterest() async {
    String pois;
    try {
      var location = {'latitude':37.3309422, 'longitude': -121.8939077};
      pois = await FlutterACPPlaces.getNearbyPointsOfInterest(location, 100);
    } on PlatformException {
      log("Failed to get the nearby POI's.");
    }

    if (!mounted) return;
    setState(() {
      _nearbypois = pois.toString();
    });
  }

  Future<void> processGeofence() async {
    var geofence = new Geofence({'requestId':'d4e72ade-0400-4280-9bfe-8ba7553a6444', 'latitude':37.3309422, 'longitude': -121.8939077, 'radius': 1000, 'expirationDuration':-1});
    FlutterACPPlaces.processGeofence(geofence, ACPPlacesRegionEventType.ENTRY);
  }

  Future<void> setAuthorizationStatus() async {
    FlutterACPPlaces.setAuthorizationStatus(ACPPlacesAuthorizationStatus.ALWAYS);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ACPPlaces Plugin example app'),
        ),
        body: Center(
          child: Column(children: <Widget>[
            Text('ACPPlaces version = $_platformVersion\n'),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Text("ACPPlaces.getCurrentPointsOfInterest()"),
                    onPressed: () => getCurrentPointsOfInterest(),
                  ),
                ]),
            Flexible(
                child:
                new Text('Current Points of Interest = $_currentpois\n'),
                ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
              RaisedButton(
                child: Text("ACPPlaces.getNearbyPointsOfInterest()"),
                onPressed: () => getNearbyPointsOfInterest(),
              ),
            ]),
            Flexible(
                child:
                new Text('Nearby Points of Interest = $_nearbypois\n'),
                ),
            RaisedButton(
              child: Text("ACPPlaces.clear()"),
              onPressed: () => FlutterACPPlaces.clear(),
            ),
            RaisedButton(
              child: Text("ACPPlaces.setAuthorizationStatus()"),
              onPressed: () => setAuthorizationStatus(),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Text('ACPPlaces.getLastKnownLocation()'),
                    onPressed: () => getLastKnownLocation(),
                  ),
                ]),
            Flexible(
                child:
                new Text('Last known location = $_location\n'),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    child: Text("ACPPlaces.processGeofence()"),
                    onPressed: () => processGeofence(),
                  ),
          ]),
        ]),
      ),
    )
    );
  }
}
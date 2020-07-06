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
package com.adobe.marketing.mobile.flutter;

import android.location.Location;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.adobe.marketing.mobile.AdobeCallback;
import com.adobe.marketing.mobile.Places;
import com.adobe.marketing.mobile.PlacesAuthorizationStatus;
import com.adobe.marketing.mobile.PlacesPOI;
import com.google.android.gms.location.Geofence;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterACPPlacesPlugin */
public class FlutterACPPlacesPlugin implements MethodCallHandler {

  final static String METHOD_PLACES_CLEAR = "clear";
  final static String METHOD_PLACES_EXTENSION_VERSION_PLACES = "extensionVersion";
  final static String METHOD_PLACES_GET_CURRENT_POINTS_OF_INTEREST = "getCurrentPointsOfInterest";
  final static String METHOD_PLACES_GET_LAST_KNOWN_LOCATION = "getLastKnownLocation";
  final static String METHOD_PLACES_GET_NEARBY_POINTS_OF_INTEREST = "getNearbyPointsOfInterest";
  final static String METHOD_PLACES_PROCESS_GEOFENCE = "processGeofence";
  final static String METHOD_PLACES_SET_AUTHORIZATION_STATUS = "setAuthorizationStatus";

  final static String LOG_TAG = "ACPPlaces_Flutter";

  final static String POI = "POI";
  final static String LATITUDE = "Latitude";
  final static String LONGITUDE = "Longitude";
  final static String LOWERCASE_LATITUDE = "latitude";
  final static String LOWERCASE_LONGITUDE = "longitude";
  final static String IDENTIFIER = "Identifier";
  final static String PROVIDER = "generic provider";

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_acpplaces");
    channel.setMethodCallHandler(new FlutterACPPlacesPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (METHOD_PLACES_EXTENSION_VERSION_PLACES.equals(call.method)) {
      result.success(Places.extensionVersion());
    } else if (METHOD_PLACES_CLEAR.equals((call.method))) {
      Places.clear();
      result.success(null);
    } else if (METHOD_PLACES_GET_CURRENT_POINTS_OF_INTEREST.equals((call.method))) {
      getCurrentPointsOfInterest(result);
    } else if (METHOD_PLACES_GET_LAST_KNOWN_LOCATION.equals((call.method))) {
      getLastKnownLocation(result);
    } else if (METHOD_PLACES_GET_NEARBY_POINTS_OF_INTEREST.equals((call.method))) {
      getNearbyPointsOfInterest(result, call.arguments);
    } else if (METHOD_PLACES_PROCESS_GEOFENCE.equals((call.method))) {
      processGeofence(call.arguments);
      result.success(null);
    } else (METHOD_PLACES_SET_AUTHORIZATION_STATUS.equals((call.method))) {
      setAuthorizationStatus(call.arguments);
      result.success(null);
    }
  }

  private void getCurrentPointsOfInterest(final Result result) {
    Places.getCurrentPointsOfInterest(new AdobeCallback<List<PlacesPOI>>() {
      @Override
      public void call(final List<PlacesPOI> pois) {
        runOnUIThread(new Runnable() {
          @Override
          public void run() {
            result.success(generatePOIString(pois));
          }
        });
      }
    });
  }

  private void getLastKnownLocation(final Result result) {
    Places.getLastKnownLocation(new AdobeCallback<Location>() {
      @Override
      public void call(final Location location) {
        runOnUIThread(new Runnable() {
          @Override
          public void run() {
            if(location != null) {
              JSONObject json = new JSONObject();
              try {
                json.put(LATITUDE, location.getLatitude());
                json.put(LONGITUDE, location.getLongitude());
              } catch (JSONException e) {
                Log.e(LOG_TAG, "Error putting data into JSON: " + e.getLocalizedMessage());
              }
              result.success(json.toString());
            }
          }
        });
      }
    });
  }

  private void getNearbyPointsOfInterest(final Result result, final Object arguments) {
    if (!(arguments instanceof Map)) {
      Log.e(LOG_TAG, "Get Nearby Points of Interest failed because arguments were invalid");
      return;
    }
    Location location;
    int limit;
    Map<String, Object> params = (Map<String, Object>) arguments;
    if (!(params.get("Location") instanceof Location) || !(params.get("Limit") instanceof Integer)) {
      Log.e(LOG_TAG, "Get Nearby Points of Interest failed because arguments were invalid");
    }

    location = (Location) params.get("Location");
    limit = (int)params.get("Limit");

    Places.getNearbyPointsOfInterest(location, limit, new AdobeCallback<List<PlacesPOI>>() {
      @Override
      public void call(final List<PlacesPOI> pois) {
        runOnUIThread(new Runnable() {
          @Override
          public void run() {
            result.success(generatePOIString(pois));
          }
        });
      }
    });
  }

  private void processGeofence(final Object arguments) {
    if (!(arguments instanceof Map)) {
      Log.e(LOG_TAG, "Process Geofence failed because arguments were invalid");
      return;
    }
    int transitionType;
    Geofence geofence;
    Map<String, Object> params = (Map<String, Object>) arguments;
    if (!(params.get("Geofence") instanceof Geofence) || !(params.get("TransitionType") instanceof Integer)) {
      Log.e(LOG_TAG, "Process Geofence failed because arguments were invalid");
    }

    geofence = (Geofence)params.get("Geofence");
    transitionType = (int)params.get("TransitionType");
    Places.processGeofence(geofence, transitionType);
  }

  private void setAuthorizationStatus(final Object arguments) {
    if (!(arguments instanceof PlacesAuthorizationStatus)) {
      Log.e(LOG_TAG, "Set Authorization Status failed because arguments were invalid");
      return;
    }
    Places.setAuthorizationStatus((PlacesAuthorizationStatus)arguments);
  }

  private void runOnUIThread(Runnable runnable) {
    new Handler(Looper.getMainLooper()).post(runnable);
  }

  private String generatePOIString(final List<PlacesPOI> pois) {
    JSONArray jsonArray = new JSONArray();
    JSONObject json;
    if (!pois.isEmpty()) {
      for (int index = 0; index < pois.size(); index++) {
        try {
          PlacesPOI poi = pois.get(index);
          json = new JSONObject();
          json.put(POI, poi.getName());
          json.put(LATITUDE, poi.getLatitude());
          json.put(LONGITUDE, poi.getLongitude());
          json.put(IDENTIFIER, poi.getIdentifier());
          jsonArray.put(index, json);
        } catch (JSONException e) {
          Log.d(LOG_TAG, "Error putting data into JSON: " + e.getLocalizedMessage());
        }
      }
    }
    return jsonArray.toString();
  }
}

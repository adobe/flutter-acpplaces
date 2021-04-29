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

import java.util.List;
import java.util.Map;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterACPPlacesPlugin
 */
public class FlutterACPPlacesPlugin implements FlutterPlugin, MethodCallHandler {

    final static String METHOD_PLACES_CLEAR = "clear";
    final static String METHOD_PLACES_EXTENSION_VERSION = "extensionVersion";
    final static String METHOD_PLACES_GET_CURRENT_POINTS_OF_INTEREST = "getCurrentPointsOfInterest";
    final static String METHOD_PLACES_GET_LAST_KNOWN_LOCATION = "getLastKnownLocation";
    final static String METHOD_PLACES_GET_NEARBY_POINTS_OF_INTEREST = "getNearbyPointsOfInterest";
    final static String METHOD_PLACES_PROCESS_GEOFENCE = "processGeofence";
    final static String METHOD_PLACES_SET_AUTHORIZATION_STATUS = "setAuthorizationStatus";

    final static String LOG_TAG = "ACPPlaces_Flutter";

    final static String POI = "POI";
    final static String LATITUDE = "latitude";
    final static String LONGITUDE = "longitude";
    final static String IDENTIFIER = "identifier";
    final static String LIMIT = "Limit";
    final static String LOCATION = "Location";
    final static String GEOFENCE = "Geofence";
    final static String TRANSITION_TYPE = "TransitionType";
    final static String RADIUS = "radius";
    final static String EXPIRATION_DURATION = "expirationDuration";
    final static String REQUEST_ID = "requestId";
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull final FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_acpplaces");
        channel.setMethodCallHandler(new FlutterACPPlacesPlugin());
    }

    @Override
    public void onDetachedFromEngine(@NonNull final FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
        }
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (METHOD_PLACES_EXTENSION_VERSION.equals(call.method)) {
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
        } else if (METHOD_PLACES_SET_AUTHORIZATION_STATUS.equals(call.method)) {
            setAuthorizationStatus(call.arguments);
            result.success(null);
        } else {
            result.notImplemented();
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
                        if (location != null) {
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
        Map<String, Object> params = (Map<String, Object>) arguments;
        if (!(params.get(LOCATION) instanceof Map) || !(params.get(LIMIT) instanceof Integer)) {
            Log.e(LOG_TAG, "Get Nearby Points of Interest failed because arguments were invalid");
            return;
        }

        final Location location = new Location("default provider");
        final Map<String, Object> locationMap = (Map<String, Object>) params.get(LOCATION);
        location.setLatitude((Double) locationMap.get(LATITUDE));
        location.setLongitude((Double) locationMap.get(LONGITUDE));
        final int limit = (int) params.get(LIMIT);

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
        Map<String, Object> params = (Map<String, Object>) arguments;
        if (!(params.get(GEOFENCE) instanceof Map) || !(params.get(TRANSITION_TYPE) instanceof Integer)) {
            Log.e(LOG_TAG, "Process Geofence failed because arguments were invalid");
            return;
        }

        final Map<String, Object> geofenceMap = (Map<String, Object>) params.get(GEOFENCE);
        final Integer radius = (Integer) geofenceMap.get(RADIUS);
        final Integer expirationDuration = (Integer) geofenceMap.get(EXPIRATION_DURATION);
        final int transitionType = (int) params.get(TRANSITION_TYPE);
        final Geofence geofence = new Geofence.Builder()
                .setCircularRegion((Double) geofenceMap.get(LATITUDE), (Double) geofenceMap.get(LONGITUDE), radius.floatValue())
                .setExpirationDuration(expirationDuration.longValue())
                .setTransitionTypes(transitionType)
                .setRequestId((String) geofenceMap.get(REQUEST_ID))
                .build();
        Places.processGeofence(geofence, transitionType);
    }

    private void setAuthorizationStatus(final Object arguments) {
        if (!(arguments instanceof Integer)) {
            Log.e(LOG_TAG, "Set Authorization Status failed because arguments were invalid");
            return;
        }

        Places.setAuthorizationStatus(getAuthorizationStatus((Integer) arguments));
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

    private PlacesAuthorizationStatus getAuthorizationStatus(final int status) {
        if (status == 0) {
            return PlacesAuthorizationStatus.DENIED;
        } else if (status == 1) {
            return PlacesAuthorizationStatus.ALWAYS;
        } else if (status == 2) {
            return PlacesAuthorizationStatus.UNKNOWN;
        } else if (status == 3) {
            return PlacesAuthorizationStatus.RESTRICTED;
        } else if (status == 4) {
            return PlacesAuthorizationStatus.WHEN_IN_USE;
        } else {
            return null;
        }
    }
}

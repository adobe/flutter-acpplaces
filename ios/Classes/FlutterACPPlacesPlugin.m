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
#import "FlutterACPPlacesPlugin.h"
#import "ACPPlaces.h"

static NSString* const METHOD_PLACES_CLEAR = @"clear";
static NSString* const METHOD_PLACES_EXTENSION_VERSION = @"extensionVersion";
static NSString* const METHOD_PLACES_GET_CURRENT_POINTS_OF_INTEREST = @"getCurrentPointsOfInterest";
static NSString* const METHOD_PLACES_GET_LAST_KNOWN_LOCATION = @"getLastKnownLocation";
static NSString* const METHOD_PLACES_GET_NEARBY_POINTS_OF_INTEREST = @"getNearbyPointsOfInterest";
static NSString* const METHOD_PLACES_PROCESS_GEOFENCE = @"processGeofence";
static NSString* const METHOD_PLACES_SET_AUTHORIZATION_STATUS = @"setAuthorizationStatus";
static NSString* const POI = @"POI";
static NSString* const IDENTIFIER = @"Identifier";
static NSString* const EMPTY_ARRAY_STRING = @"[]";
static NSString* const LATITUDE = @"latitude";
static NSString* const LONGITUDE = @"longitude";
static NSString* const CIRCULAR_REGION = @"circularRegion";
static NSString* const RADIUS = @"radius";
static NSString* const REQUEST_ID = @"requestId";
static NSString* const TRANSITION_TYPE = @"TransitionType";
static NSString* const LIMIT = @"Limit";
static NSString* const LOCATION = @"Location";
static NSString* const GEOFENCE = @"Geofence";

@implementation FlutterACPPlacesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_acpplaces"
            binaryMessenger:[registrar messenger]];
  FlutterACPPlacesPlugin* instance = [[FlutterACPPlacesPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([METHOD_PLACES_EXTENSION_VERSION isEqualToString:call.method]) {
        result([ACPPlaces extensionVersion]);
    } else if ([METHOD_PLACES_CLEAR isEqualToString:call.method]) {
        [ACPPlaces clear];
        result(nil);
    } else if ([METHOD_PLACES_GET_CURRENT_POINTS_OF_INTEREST isEqualToString:call.method]) {
        [self getCurrentPointsOfInterest:call result:result];
    } else if ([METHOD_PLACES_GET_LAST_KNOWN_LOCATION isEqualToString:call.method]) {
        [self getLastKnownLocation:call result:result];
    } else if ([METHOD_PLACES_GET_NEARBY_POINTS_OF_INTEREST isEqualToString:call.method]) {
        [self getNearbyPointsOfInterest:call result:result];
    } else if ([METHOD_PLACES_PROCESS_GEOFENCE isEqualToString:call.method]) {
        [self processGeofence:call];
        result(nil);
    } else if ([METHOD_PLACES_SET_AUTHORIZATION_STATUS isEqualToString:call.method]) {
        NSNumber* status = call.arguments;
        [ACPPlaces setAuthorizationStatus:[self convertToCLAuthorizationStatus:[status intValue]]];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)getCurrentPointsOfInterest:(FlutterMethodCall *)call result:(FlutterResult)result {
    __block NSString* currentPoisString = EMPTY_ARRAY_STRING;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ACPPlaces getCurrentPointsOfInterest:^(NSArray<ACPPlacesPoi *> * _Nullable retrievedPois) {
        if(retrievedPois != nil && retrievedPois.count != 0) {
        currentPoisString = [self generatePOIString:retrievedPois];
        dispatch_semaphore_signal(semaphore);
        }
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, ((int64_t)1 * NSEC_PER_SEC)));
    result(currentPoisString);
}

- (void)getLastKnownLocation:(FlutterMethodCall *)call result:(FlutterResult)result {
    [ACPPlaces getLastKnownLocation:^(CLLocation * _Nullable lastLocation) {
        NSMutableDictionary* tempDict = [[NSMutableDictionary alloc]init];
        [tempDict setValue:[NSNumber numberWithDouble:lastLocation.coordinate.latitude] forKey:LATITUDE];
        [tempDict setValue:[NSNumber numberWithDouble:lastLocation.coordinate.longitude] forKey:LONGITUDE];
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:tempDict options:0 error:nil];
        result([[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    }];
}

- (void)getNearbyPointsOfInterest:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary* argumentDict = (NSDictionary *) call.arguments;
    NSDictionary* locationDict = [argumentDict valueForKey:LOCATION];
    CLLocationDegrees latitude = [[locationDict valueForKey:LATITUDE] doubleValue];
    CLLocationDegrees longitude = [[locationDict valueForKey:LONGITUDE] doubleValue];
    CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    NSUInteger limit = [[argumentDict valueForKey:LIMIT] integerValue];
    __block NSString* currentPoisString = EMPTY_ARRAY_STRING;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ACPPlaces getNearbyPointsOfInterest:currentLocation limit:limit callback:^(NSArray<ACPPlacesPoi *> * _Nullable retrievedPois) {
        currentPoisString = [self generatePOIString:retrievedPois];
        dispatch_semaphore_signal(semaphore);
    }
    errorCallback:^(ACPPlacesRequestError error) {
        result([NSString stringWithFormat:@"Places request error code: %lu", error]);
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, ((int64_t)1 * NSEC_PER_SEC)));
    result(currentPoisString);
}

- (void)processGeofence:(FlutterMethodCall *)call {
    NSDictionary* argumentDict = (NSDictionary *) call.arguments;
    NSDictionary* geofenceDict = [argumentDict valueForKey:GEOFENCE];
    ACPRegionEventType eventType = [[argumentDict valueForKey:TRANSITION_TYPE] integerValue];
    CLLocationDegrees latitude = [[geofenceDict valueForKey:LATITUDE] doubleValue];
    CLLocationDegrees longitude = [[geofenceDict valueForKey:LONGITUDE] doubleValue];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude,longitude);
    NSUInteger radius = [[geofenceDict valueForKey:RADIUS] integerValue];
    NSString* identifier = [geofenceDict valueForKey:REQUEST_ID];
    CLRegion* region = [[CLCircularRegion alloc] initWithCenter:center radius:radius identifier:identifier];
    [ACPPlaces processRegionEvent:region forRegionEventType:eventType];
}

/*
 * Helper functions
 */

- (NSString*) generatePOIString:(NSArray<ACPPlacesPoi *> *) retrievedPois {
    NSMutableArray* retrievedPoisArray = [[NSMutableArray alloc]init];
    if(retrievedPois != nil && retrievedPois.count != 0) {
        for (int index = 0; index < retrievedPois.count; index++) {
            NSMutableDictionary* tempDict = [[NSMutableDictionary alloc]init];
            ACPPlacesPoi* currentPoi = retrievedPois[index];
            [tempDict setValue:currentPoi.name forKey:POI];
            [tempDict setValue:[NSNumber numberWithDouble:currentPoi.latitude] forKey:LATITUDE];
            [tempDict setValue:[NSNumber numberWithDouble:currentPoi.longitude] forKey:LONGITUDE];
            [tempDict setValue:currentPoi.identifier forKey:IDENTIFIER];
            retrievedPoisArray[index] = tempDict;
        }
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:retrievedPoisArray options:0 error:nil];
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return EMPTY_ARRAY_STRING;
}

- (CLAuthorizationStatus) convertToCLAuthorizationStatus:(int) status {
    switch (status) {
    case 0:
        return kCLAuthorizationStatusDenied;
        break;

    case 1:
        return kCLAuthorizationStatusAuthorizedAlways;
        break;

    case 2:
        return kCLAuthorizationStatusNotDetermined;
        break;

    case 3:
        return kCLAuthorizationStatusRestricted;
        break;

    case 4:
    default:
        return kCLAuthorizationStatusAuthorizedWhenInUse;
        break;
    }
}

@end

#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "ACPCore.h"
#import "ACPIdentity.h"
#import "ACPLifecycle.h"
#import "ACPSignal.h"
#import "ACPPlaces.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    [self initSDK:application];
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)initSDK:(UIApplication *) application {
    [ACPCore setLogLevel:ACPMobileLogLevelVerbose];
    [ACPCore setPrivacyStatus:ACPMobilePrivacyStatusOptIn];
    [ACPCore setWrapperType:ACPMobileWrapperTypeFlutter];
    [ACPCore configureWithAppId:@"94f571f308d5/bda071acf896/launch-189f3f522ee2-development"];
    [ACPIdentity registerExtension];
    [ACPLifecycle registerExtension];
    [ACPSignal registerExtension];
    [ACPPlaces registerExtension];

    const UIApplicationState appState = application.applicationState;
    [ACPCore start:^{
        // only start lifecycle if the application is not in the background
        if (appState != UIApplicationStateBackground) {
            [ACPCore lifecycleStart:nil];
        }
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [ACPCore lifecyclePause];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [ACPCore lifecycleStart:nil];
}

@end
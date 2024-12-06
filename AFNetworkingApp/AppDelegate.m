//
//  AppDelegate.m
//  AFNetworkingApp
//
//  Created by Maxime Epain on 06/12/2024.
//

#import "AppDelegate.h"
#import "AFNetworking.h"

@import DatadogObjc;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    {
        /// # Datadog Notes:
        ///
        /// This configuration must be applied on the React-Native side
        [DDDatadog initializeWithConfiguration:[[DDConfiguration alloc] initWithClientToken:@"xxx" env:@"test"]
                               trackingConsent:[DDTrackingConsent granted]];

        DDRUMConfiguration *configuration = [[DDRUMConfiguration alloc] initWithApplicationID:@"yyy"];
        configuration.sessionSampleRate = 100;
        configuration.uiKitViewsPredicate = [DDDefaultUIKitRUMViewsPredicate new];
        configuration.uiKitActionsPredicate = [DDDefaultUIKitRUMActionsPredicate new];

        /// You can enable the hosts at the main configuration
        DDRUMURLSessionTracking *urlSessionTracking = [DDRUMURLSessionTracking new];
        [urlSessionTracking setFirstPartyHostsTracing:[[DDRUMFirstPartyHostsTracing alloc] initWithHosts:[NSSet setWithObject:@"httpbin.org"] sampleRate:100]];
        [configuration setURLSessionTracking:urlSessionTracking];
        [DDRUM enableWith:configuration];
    }

    {
        /// # Datadog Notes:
        /// 
        /// You can enable the URLSession Instrumentation using the `[AFHTTPSessionManager class]`.
        /// This way, all instances of `AFHTTPSessionManager` will be instrumented.
        DDURLSessionInstrumentationConfiguration *configuration = [[DDURLSessionInstrumentationConfiguration alloc] initWithDelegateClass:[AFHTTPSessionManager class]];

        /// You can also specify **additionals** hosts when using the `AFHTTPSessionManager`
        [configuration setFirstPartyHostsTracing:[[DDURLSessionInstrumentationFirstPartyHostsTracing alloc] initWithHosts:[NSSet setWithObject:@"httpbin.org"]]];
        [DDURLSessionInstrumentation enableWithConfiguration:configuration];
    }

    /// Delay execution of my block for 3 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self getJSONData];
    });

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (void)getJSONData {
    // Create a manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    // Set the response serializer to JSON
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    [manager.requestSerializer setValue:@"1" forHTTPHeaderField:@"x-datadog-sampling-priority"];

    // Specify the URL
    NSString *urlString = @"https://httpbin.org/get";

    // Perform the GET request
    [manager GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // Handle successful response:
        //
        // ---> httpbin.org returns the request.headers where the 'x-datadog-*' are visible
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // Handle error
        NSLog(@"Error: %@", error);
    }];
}

@end

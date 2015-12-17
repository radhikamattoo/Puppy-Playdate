//  Puppy Playdate App
//  AppDelegate.m
//  by Dhruv Gupta
//
//  Setting up Parse
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"QXhqhVm17GB0pqh0KviFE1wPTNzlIx7Fa5ANWbZF"
                  clientKey:@"iUufbN8tuNY1YZtH21Wi5URjvilXz5EDXQFDicu3"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    return YES;
}

@end

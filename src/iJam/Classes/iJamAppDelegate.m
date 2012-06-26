//
//  iJamAppDelegate.m
//  iJam
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iJamAppDelegate.h"
#import "iJamViewController.h"

@implementation iJamAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end

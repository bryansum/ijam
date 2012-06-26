//
//  PdLibTestAppDelegate.m
//  PdLibTest
//
//  Created by Bryan Summersett on 11/9/09.
//  Copyright NatIanBryan 2009. All rights reserved.
//

#import "PdLibTestAppDelegate.h"
#import "PdLibTestViewController.h"

@implementation PdLibTestAppDelegate

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

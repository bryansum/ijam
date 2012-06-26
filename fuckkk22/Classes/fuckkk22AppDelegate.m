//
//  fuckkk22AppDelegate.m
//  fuckkk22
//
//  Created by Nathaniel Christman on 11/30/09.
//  Copyright University of Michigan 2009. All rights reserved.
//

#import "fuckkk22AppDelegate.h"
#import "mainViewController.h"

@implementation fuckkk22AppDelegate

@synthesize window;
//@synthesize rootController;
//@synthesize rootView;
//@synthesize drumView;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
	mainView = [mainViewController alloc];
	[window addSubview:mainView.view];
	
	[window makeKeyAndVisible];

}


- (void)dealloc {
//	[rootController release];
	//[drumView release];
    [window release];
    [super dealloc];
}

-(void)loadView:(int)view{
	switch (view) {
		case 0:
			[mainView loadMenuView];
			break;
		case 1:
			[mainView loadHostView];
			break;
		case 2:
			[mainView loadSessionView];
			break;
		case 3:
			[mainView loadOptionView];
			break;
		case 4:
			[mainView loadInstrumentView];
			break;
		case 5:
			[mainView loadDrumView];
			break;
		case 6:
			[mainView loadBassView];
			break;
		default:
			break;
	}
}

@end

//
//  menuViewController.m
//  fuckkk22
//
//  Created by Nathaniel Christman on 12/1/09.
//  Copyright 2009 University of Michigan. All rights reserved.
//

#import "menuViewController.h"
#import "mainViewController.h"
#import "fuckkk22AppDelegate.h"

int join = 0;
int host = 1;
int option = 2;
int back = 3;
int drum = 4;

@implementation menuViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"iJam-main.png"]];

	
	
	joinSession = [UIButton buttonWithType:UIButtonTypeCustom];
	joinSession.frame = CGRectMake(45, 5, 39, 203);
	//[bass setTitle:@"bass" forState:UIControlStateNormal];
	//[bass imageRectForContentRect:CGRectMake(0, 0, 80, 80)];
	[joinSession setBackgroundImage:[UIImage imageNamed:@"button-main-join-session.png"] forState:UIButtonTypeCustom];
	[joinSession addTarget:self action:@selector(loadInstruments) forControlEvents:UIControlEventTouchDown];
//	joinSession.transform = transform;
	[self.view addSubview:joinSession];
	
	
	hostSession = [UIButton buttonWithType:UIButtonTypeCustom];
	hostSession.frame = CGRectMake(5, 5, 39, 203);
	//[bass setTitle:@"bass" forState:UIControlStateNormal];
	//[bass imageRectForContentRect:CGRectMake(0, 0, 80, 80)];
	[hostSession setBackgroundImage:[UIImage imageNamed:@"button-main-create-session.png"] forState:UIButtonTypeCustom];
	[hostSession addTarget:self action:@selector(loadHost) forControlEvents:UIControlEventTouchDown];
	//	joinSession.transform = transform;
	[self.view addSubview:hostSession];
	
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[hostSession release];
	[joinSession release];
}


- (void)dealloc {
    [super dealloc];
	[hostSession release];
	[joinSession release];
}

@end

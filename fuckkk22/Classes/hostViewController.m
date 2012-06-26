//
//  hostViewController.m
//  fuckkk22
//
//  Created by Nathaniel Christman on 12/5/09.
//  Copyright 2009 University of Michigan. All rights reserved.
//

#import "hostViewController.h"


@implementation hostViewController

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
    //[super viewDidLoad];
	CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);

	back = [UIButton buttonWithType:UIButtonTypeCustom];
	[back setFrame:CGRectMake(287, 3, 32, 65)];
	[back imageRectForContentRect:CGRectMake(280, 0, 32, 65)];
	[back setBackgroundImage:[UIImage imageNamed:@"button-back.png"] forState:UIButtonTypeCustom];
	[back addTarget:self action:@selector(loadMenu) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:back];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

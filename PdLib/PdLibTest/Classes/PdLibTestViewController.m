//
//  PdLibTestViewController.m
//  PdLibTest
//
//  Created by Bryan Summersett on 11/9/09.
//  Copyright NatIanBryan 2009. All rights reserved.
//

#import "PdLibTestViewController.h"

@implementation PdLibTestViewController

@synthesize textField;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView {
//    
//    NSLog(@"Caching pdController in view");
//}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *iJamDir = @"pd";
    NSBundle *bundle = [NSBundle mainBundle];
        
    pdController = [PdController sharedController];
    pdController.libdir = [[NSBundle mainBundle] resourcePath];
    pdController.externs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pd_darwin" inDirectory:nil];
    pdController.openfiles = [NSArray arrayWithObjects: [bundle pathForResource:@"ij-router" ofType:@"pd" inDirectory:nil],
                              [bundle pathForResource:@"ij-dac" ofType:@"pd" inDirectory:nil],
                              [bundle pathForResource:@"i-drumelectro" ofType:@"pd" inDirectory:nil],
                              [bundle pathForResource:@"i-rhodeybass" ofType:@"pd" inDirectory: nil],
                              nil];
    
    [pdController start];
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
    
    [pdController stop];
//    [pdController release];
}


- (void)dealloc {
    [super dealloc];
}

@end

//
//  mainViewController.m
//  fuckkk22
//
//  Created by Nathaniel Christman on 12/4/09.
//  Copyright 2009 University of Michigan. All rights reserved.
//

#import "mainViewController.h"
#import "sessionViewController.h"
#import "menuViewController.h"
#import	"drumViewController.h"
#import "bassViewController.h"
#import "instrumentViewController.h"
#import "hostViewController.h"
#import "optionViewController.h"
#import "Sequencer.h"

@implementation mainViewController


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)startPd
{
    [Sequencer startTiming];

    NSBundle *bundle = [NSBundle mainBundle];
    
    pdController = [PdController sharedController];
    pdController.libdir = [bundle resourcePath];
    pdController.externs = [bundle pathsForResourcesOfType:@"pd_darwin" inDirectory:nil];
    pdController.openfiles = [NSArray arrayWithObjects: [bundle pathForResource:@"ij-router" ofType:@"pd" inDirectory:nil],
                              [bundle pathForResource:@"ij-dac" ofType:@"pd" inDirectory:nil],
                              [bundle pathForResource:@"i-drumelectro" ofType:@"pd" inDirectory:nil],
                              [bundle pathForResource:@"i-rhodeybass" ofType:@"pd" inDirectory: nil],
                              nil];
    pdController.callbackFn = &SequencerCallbackFn;
    [pdController start];    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
	sessionView = [sessionViewController alloc];
	menuView = [menuViewController alloc];
	bassView = [bassViewController alloc];
	hostView = [hostViewController alloc];
	instrumentView = [instrumentViewController alloc];
	optionView = [optionViewController alloc];
	drumView = [drumViewController alloc];
	
	[self.view addSubview:menuView.view];
	currentView = menuView;
	
    [self startPd];
    
	[super viewDidLoad];
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
    [pdController stop];
    [super dealloc];
}

-(void)loadMenuView{
	[currentView.view removeFromSuperview];
	currentView = menuView;
	[self.view addSubview:menuView.view];
}

-(void)loadHostView{
	[currentView.view removeFromSuperview];
	currentView = hostView;
	[self.view addSubview:hostView.view];
}

-(void)loadSessionView{
	[currentView.view removeFromSuperview];
	currentView = sessionView;
	[self.view addSubview:sessionView.view];
}

-(void)loadOptionView{
	[currentView.view removeFromSuperview];
	currentView = optionView;
	[self.view addSubview:optionView.view];
}

-(void)loadInstrumentView{
	[currentView.view removeFromSuperview];
	currentView = instrumentView;
	[self.view addSubview:instrumentView.view];
}

-(void)loadDrumView{
	[currentView.view removeFromSuperview];
	currentView = drumView;
	[self.view addSubview:drumView.view];
}

-(void)loadBassView{
	[currentView.view removeFromSuperview];
	currentView = bassView;
	[self.view addSubview:bassView.view];
}

-(void)loadMenu{
	fuckkk22AppDelegate *appDelegate = [[UIApplication
										 sharedApplication] delegate];
	[appDelegate loadView:0];
}

-(void)loadHost{
	fuckkk22AppDelegate *appDelegate = [[UIApplication
										 sharedApplication] delegate];
	[appDelegate loadView:1];
}

-(void)loadSessions{
	fuckkk22AppDelegate *appDelegate = [[UIApplication
										 sharedApplication] delegate];
	[appDelegate loadView:2];
}

-(void)loadOptions{
	fuckkk22AppDelegate *appDelegate = [[UIApplication
										 sharedApplication] delegate];
	[appDelegate loadView:3];
}

-(void)loadInstruments{
	fuckkk22AppDelegate *appDelegate = [[UIApplication
										 sharedApplication] delegate];
	[appDelegate loadView:4];
}

-(void)loadDrums{
	fuckkk22AppDelegate *appDelegate = [[UIApplication
										 sharedApplication] delegate];
	[appDelegate loadView:5];
}

-(void)loadBass{
	fuckkk22AppDelegate *appDelegate = [[UIApplication
										 sharedApplication] delegate];
	[appDelegate loadView:6];
}


@end

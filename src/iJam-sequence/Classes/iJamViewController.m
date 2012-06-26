//
//  iJamViewController.m
//  iJam
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iJamViewController.h"
#import "cocos2d.h"
#import "FreeFormScene.h"
#import "SequenceScene.h"
#import "Sequencer.h"
#import "AVController.h"
#import "TargetConditionals.h"

#define ACC_UPDATE_INTERVAL 0.1 
#define FAKE_MAGNITUDE 1.0

@implementation iJamViewController

@synthesize sequencer;
@synthesize avController;
@synthesize scrollView;
@synthesize bpmLabel;
@synthesize bpmSlider;
@synthesize gridButtonController;
@synthesize freeFormController;

@synthesize currentScene;
@synthesize freeFormScene;
@synthesize sequenceScene;

@synthesize accelerometer;
@synthesize accelerometerMagnitude;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewDidLoad {
    sequencer = [[Sequencer alloc] init];
    sequencer.viewController = self;
    avController = [[AVController alloc] init];
    
    // make the sequence view 
	[self bpmDidChange:nil];

	[self loadAccelerometer];
	[super viewDidLoad];
	[self loadScrollViews];
}

- (void)loadScrollViews { 
	
	// Put the page control vertically in the top left corner.
//	pageControl.transform =
//    CGAffineTransformRotate(controlPageControl.transform, degreesToRadians(90));
//	controlPageControl.transform =
//    CGAffineTransformTranslate(controlPageControl.transform, 47, 50);
	
	// New controls panels should be added here
//	NSMutableArray *controlViews = [[NSMutableArray alloc] init]; 
//	[controlViews addObject:freeFormView];
//	[controlViews addObject:sequenceView];
//	
//	CGRect frame = scrollView.frame;
//	frame.origin.x = 0;
//	for (int i = 0; i < [controlViews count]; ++i) {
//		frame.origin.y = 320 * i;   //TODO: hardcoded values are BAD
//		UIView* view = [controlViews objectAtIndex:i];
//		view.frame = frame;
//		[scrollView addSubview:view];
//	}
//	
//	CGSize size = {480.0, 320.0};
//	CGSize scrollSize = size;
//	scrollSize.height *= [controlViews count];
//	[scrollView setContentSize:scrollSize];
//	
//	[controlViews release];
}

-(void)swapScene
{
    currentScene =  (currentScene == freeFormScene) ? sequenceScene : freeFormScene;
    NSLog(@"swapping scene to %@", (currentScene == freeFormScene ? @"freeForm" : @"sequence"));
    [[Director sharedDirector] replaceScene: [FadeTransition transitionWithDuration:1.0f scene:currentScene]];
}

- (void)syncPageControl {
	// Switch the indicator when more than 50% of the previous/next page is visible
//	CGFloat pageHeight = scrollView.frame.size.height;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self syncPageControl];
}

- (IBAction)changePage:(id)sender {
	int page = 0; //FIXME: this is alwasys 0
	// update the scroll view to the appropriate page
	CGRect frame = scrollView.frame;
	frame.origin.x = 0;
	frame.origin.y = frame.size.height * page;
	
	[scrollView scrollRectToVisible:frame animated:YES];
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
    [sequencer release];
    [avController release];

    [freeFormScene release];
    [sequenceScene release];
}

- (void)loadAccelerometer
{
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"Target is not an iPhone");
    self.accelerometerMagnitude = FAKE_MAGNITUDE; // just fake it if we're on the simulator
#else
	NSLog(@"target is an iPhone");
    oldX = 0.0;
	oldY = 0.0;
	oldZ = 0.0;
	newX = 0.0;
	newY = 0.0;
	newZ = 0.0;
	
	accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.updateInterval = ACC_UPDATE_INTERVAL;
	accelerometer.delegate = self;
#endif
}

// Delegate function for the accelerometer. 
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	oldX = newX;
	oldY = newY;
	oldZ = newZ;
	
	newY = acceleration.y;
	newX = acceleration.x;
	newZ = acceleration.z;
	
	self.accelerometerMagnitude = sqrt(pow(oldX-newX, 2) + pow(oldY-newY, 2) + pow(oldZ-newZ, 2))*1.7;
}

-(void)loadBpm
{
    [bpmSlider setValue:[sequencer bpm]];
}

-(void)setBpmText:(float)bpm
{        
    [sequencer setBpm:bpm];
    NSLog(@"bpm %f", bpm);
    [bpmLabel setText:[NSString stringWithFormat:@"%0.0f", bpm]];    
}

-(void)bpmDidChange:(id)sender
{
    [self setBpmText:[bpmSlider value]];
}

@end

//
//  bassViewController.m
//  fuckkk22
//
//  Created by Nathaniel Christman on 12/4/09.
//  Copyright 2009 University of Michigan. All rights reserved.
//

#import "bassViewController.h"
#import "mainViewController.h"

#define RECORD_GRID_START 60
#define RECORD_GRID_END 460
#define RECORD_LENGTH 8.0


@implementation bassViewController

@synthesize grid_images;
//@synthesize timer;

BOOL record_mode;

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
   // [super viewDidLoad];
	//CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);

	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-bass.png"]];

	
	record_mode = false;
	
	self.grid_images = [[NSMutableArray alloc] init];
	
//	if(timer == nil){
//		timer = [NSTimer timerWithTimeInterval:0.04 target:self selector:@selector(update_measure:) userInfo:nil repeats: YES];
//		
//		[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//	}
	
	grid = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black-bar.png"]];
	grid.frame = CGRectMake(277, 0, 43, 480);
	[self.view insertSubview:grid atIndex:1];
	
	measure = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider.png"]];
	measure.frame = CGRectMake(287, 210, 28, 7);
	[self.view addSubview:measure];
	
	back = [UIButton buttonWithType:UIButtonTypeCustom];
	[back setFrame:CGRectMake(287, 3, 32, 65)];
	[back imageRectForContentRect:CGRectMake(280, 0, 32, 65)];
	[back setBackgroundImage:[UIImage imageNamed:@"button-back.png"] forState:UIButtonTypeCustom];
	[back addTarget:self action:@selector(loadInstruments) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:back];
	
	
	record = [UIButton buttonWithType:UIButtonTypeCustom];
	[record setFrame:CGRectMake(287, 75, 33, 33)];
	[record imageRectForContentRect:CGRectMake(300, 0, 20, 20)];
	[record setBackgroundImage:[UIImage imageNamed:@"button-record.png"] forState:UIButtonTypeCustom];
	[record addTarget:self action:@selector(recordMode) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:record];
	
	EString = [UIButton buttonWithType:UIButtonTypeCustom];
	[EString setFrame:CGRectMake(20, 0, 40, 480)];
	[EString setTitle:@"E" forState:UIControlStateNormal];
	[EString imageRectForContentRect:CGRectMake(280, 0, 50, 480)];
	[EString setBackgroundImage:[UIImage imageNamed:@"redbar.png"] forState:UIButtonTypeCustom];
	[EString addTarget:self action:@selector(touchString:withEvent:) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:EString];
	
	AString = [UIButton buttonWithType:UIButtonTypeCustom];
	[AString setFrame:CGRectMake(85, 0, 40, 480)];
	[AString setTitle:@"A" forState:UIControlStateNormal];
	[AString imageRectForContentRect:CGRectMake(280, 0, 50, 480)];
	[AString setBackgroundImage:[UIImage imageNamed:@"redbar.png"] forState:UIButtonTypeCustom];
	[AString addTarget:self action:@selector(touchString:withEvent:) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:AString];
	
	DString = [UIButton buttonWithType:UIButtonTypeCustom];
	[DString setFrame:CGRectMake(150, 0, 40, 480)];
	[DString setTitle:@"D" forState:UIControlStateNormal];
	[DString imageRectForContentRect:CGRectMake(280, 0, 50, 480)];
	[DString setBackgroundImage:[UIImage imageNamed:@"redbar.png"] forState:UIButtonTypeCustom];
	[DString addTarget:self action:@selector(touchString:withEvent:) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:DString];

	GString = [UIButton buttonWithType:UIButtonTypeCustom];
	[GString setFrame:CGRectMake(215, 0, 40, 480)];
	[GString setTitle:@"G" forState:UIControlStateNormal];
	[GString imageRectForContentRect:CGRectMake(280, 0, 50, 480)];
	[GString setBackgroundImage:[UIImage imageNamed:@"redbar.png"] forState:UIButtonTypeCustom];
	[GString addTarget:self action:@selector(touchString:withEvent:) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:GString];
	 
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

-(void)recordMode {
		if(record_mode){
			record_mode = false;
			[record_start release];
		} else {
			record_mode = true;
			record_start = [[NSDate date] retain];
		}
}



-(void)update_grid:(NSTimeInterval)time :(CGFloat)value{ 
	NSLog(@"updating grid %f", value);
	
	UIImageView *grid_image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green-dot.png"]];
		
	grid_image.frame = CGRectMake(287 + (value/57.0), measure.center.y, 6, 6);
	[self.view addSubview:grid_image];
	[grid_images addObject:grid_image];
	
	[grid_image release];
}

-(void)clear_grid {
	NSLog(@"clearing grid");
	[self.grid_images makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self.grid_images removeAllObjects];
}

-(void)update_measure:(NSTimer *)timer{
	//measure.x = measure.x + 10;
	CGPoint location = measure.center;
	if(location.y > 460.0){
		location.y = 212.0;
	} else {
		location.y += 1.0;
	}
	measure.center = location;	
}

-(void)touchString:(UIControl *)sender withEvent:(UIEvent *)ev{
	if (record_mode) {
		
		NSTimeInterval timeInterval = [record_start timeIntervalSinceNow];		
		CGFloat touch = [[[ev allTouches] anyObject] locationInView:nil].y;				
		
		UIButton *button = (UIButton *)sender;
		
		if(button.currentTitle == @"E"){
			touch += 0.0;
		} else if (button.currentTitle == @"A") {
			touch += 240.0;
		} else if (button.currentTitle == @"D") {
			touch += 480.0;
		} else {
			touch += 720.0;
		}

			NSLog(@"%f", touch);

			[self update_grid:timeInterval :touch];
			//update the image
		
	}
	
	
}

@end

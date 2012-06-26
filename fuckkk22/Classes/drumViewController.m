//
//  drumViewController.m
//  fuckkk22
//
//  Created by Nathaniel Christman on 11/30/09.
//  Copyright 2009 University of Michigan. All rights reserved.
//

#import "drumViewController.h"
#import "fuckkk22AppDelegate.h"
#import "mainViewController.h"
#import "ijam_ports.h"
#import "Sequencer.h"

#define RECORD_GRID_START 60
#define RECORD_GRID_END 460
#define RECORD_LENGTH 8.0
#define INSTRUMENT @"/inst/calvin/drumelectro"
#define PLAY_INSTRUMENT @"/inst/calvin/drumelectro/play"
#define MODE_INSTRUMENT @"/inst/calvin/drumelectro/mode"
#define CLEAR_INSTRUMENT @"/inst/calvin/drumelectro/command/clear"

@implementation drumViewController

@synthesize grid_images;
//@synthesize timer;

BOOL edit_mode;


BOOL record_mode;

-(void)playInstrument:(NSString*)inst
{
    lo_message msg = lo_message_new();
    lo_message_add_string(msg, [inst cStringUsingEncoding:NSASCIIStringEncoding]);
    [Sequencer sendMsg:msg withPath:[PLAY_INSTRUMENT cStringUsingEncoding:NSASCIIStringEncoding]];
}

            
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  //  [super viewDidLoad];
	CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
	

	UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	self.view = view;
	[view release];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-drums.png"]];

	[Sequencer setDelegate:self withInterval:0.03];
//	if(timer == nil){
//		timer = [NSTimer timerWithTimeInterval:0.04 target:self selector:@selector(update_measure:) userInfo:nil repeats: YES];
//		NSLog(@"timer done");
//		[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//		
//	}

	self.grid_images = [[NSMutableArray alloc] init];
	
	edit_mode = false;
	record_mode = false;
	
	bass = [UIButton buttonWithType:UIButtonTypeCustom];
	[bass setFrame:CGRectMake(100, 0, 160, 160)];
	[bass setTitle:@"bass" forState:UIControlStateNormal];
	[bass imageRectForContentRect:CGRectMake(0, 0, 160, 160)];
	[bass setBackgroundImage:[UIImage imageNamed:@"drum-green.png"] forState:UIButtonTypeCustom];
	[bass addTarget:self action:@selector(touchDrum:) forControlEvents:UIControlEventTouchDown];
	[bass addTarget:self action:@selector(moveDrum:withEvent:) forControlEvents:UIControlEventTouchDragInside];
	bass.transform = transform;
	[self.view addSubview:bass];
	
	hihat = [UIButton buttonWithType:UIButtonTypeCustom];
	[hihat setFrame:CGRectMake(120, 250, 140, 140)];
	[hihat setTitle:@"hihat" forState:UIControlStateNormal];
	[hihat imageRectForContentRect:CGRectMake(150, 250, 140, 140)];
	[hihat setBackgroundImage:[UIImage imageNamed:@"drum-blue.png"] forState:UIButtonTypeCustom];
	[hihat addTarget:self action:@selector(touchDrum:) forControlEvents:UIControlEventTouchDown];
	[hihat addTarget:self action:@selector(moveDrum:withEvent:) forControlEvents:UIControlEventTouchDragInside];
	hihat.transform = transform;
	[self.view addSubview:hihat];
	
	snare = [UIButton buttonWithType:UIButtonTypeCustom];
	[snare setFrame:CGRectMake(0, 330, 120, 120)];
	[snare setTitle:@"snare" forState:UIControlStateNormal];
	[snare imageRectForContentRect:CGRectMake(0, 300, 120, 120)];
	[snare setBackgroundImage:[UIImage imageNamed:@"yellow-drum.png"] forState:UIButtonTypeCustom];
	[snare addTarget:self action:@selector(touchDrum:) forControlEvents:UIControlEventTouchDown];
	[snare addTarget:self action:@selector(moveDrum:withEvent:) forControlEvents:UIControlEventTouchDragInside];
	snare.transform = transform;
	[self.view addSubview:snare];
	
	clap = [UIButton buttonWithType:UIButtonTypeCustom];
	[clap setFrame:CGRectMake(0, 150, 120, 120)];
	[clap setTitle:@"clap" forState:UIControlStateNormal];
	[clap imageRectForContentRect:CGRectMake(0, 150, 120, 120)];
	[clap setBackgroundImage:[UIImage imageNamed:@"drum-magenta.png"] forState:UIButtonTypeCustom];
	[clap addTarget:self action:@selector(touchDrum:) forControlEvents:UIControlEventTouchDown];
	[clap addTarget:self action:@selector(moveDrum:withEvent:) forControlEvents:UIControlEventTouchDragInside];
	clap.transform = transform;
	[self.view addSubview:clap];
	
	grid = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black-bar.png"]];
	grid.frame = CGRectMake(280, 0, 40, 480);
	[self.view insertSubview:grid atIndex:1];
	
	measure = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider.png"]];
	measure.frame = CGRectMake(287, 210, 28, 7);
	[self.view addSubview:measure];
		
	record = [UIButton buttonWithType:UIButtonTypeCustom];
	[record setFrame:CGRectMake(287, 170, 33, 33)];
	[record imageRectForContentRect:CGRectMake(300, 0, 20, 20)];
	[record setBackgroundImage:[UIImage imageNamed:@"button-record.png"] forState:UIButtonTypeCustom];
	[record addTarget:self action:@selector(recordMode) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:record];
	
	clear = [UIButton buttonWithType:UIButtonTypeCustom];
	[clear setFrame:CGRectMake(287, 122, 32, 44)];
	[clear imageRectForContentRect:CGRectMake(300, 0, 20, 20)];
	[clear setBackgroundImage:[UIImage imageNamed:@"button-clear.png"] forState:UIButtonTypeCustom];
	[clear addTarget:self action:@selector(clear_grid) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:clear];
		
	back = [UIButton buttonWithType:UIButtonTypeCustom];
	[back setFrame:CGRectMake(287, 3, 32, 65)];
	[back imageRectForContentRect:CGRectMake(280, 0, 32, 65)];
	[back setBackgroundImage:[UIImage imageNamed:@"button-back.png"] forState:UIButtonTypeCustom];
	[back addTarget:self action:@selector(loadInstruments) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:back];

}

-(void)touchDrum:(UIControl *)sender {
	if(!edit_mode){
		NSString *instrument;
		
		int value;
		
		UIButton *button = (UIButton *)sender;
//		NSLog(@"%@", button.currentTitle);
		
		if(button.currentTitle == @"bass"){
			value = 0;
			instrument = [NSString stringWithFormat:@"%@", @"bd"];
		} else if (button.currentTitle == @"clap") {
			value = 1;
			instrument = [NSString stringWithFormat:@"%@", @"cp"];
		} else if (button.currentTitle == @"snare") {
			value = 2;
			instrument = [NSString stringWithFormat:@"%@", @"sn"];
		} else {
			value = 3;
			instrument = [NSString stringWithFormat:@"%@", @"hh"];
		}
		
		if (record_mode) {

			NSTimeInterval timeInterval = [record_start timeIntervalSinceNow];		
			NSLog(@"%f", (-1)*timeInterval);
				
			[self update_grid:timeInterval :value];
		}
		
//		NSLog(@"%@",[NSString stringWithFormat:@"%@/%@", @"/inst/drumelectro/calvin/play",instrument]);
		[self playInstrument:instrument];
        
		
		//send the audio shit out
	}
}

-(void)moveDrum:(UIControl *)sender withEvent:(UIEvent *)ev{
	if (edit_mode) {
		sender.center = [[[ev allTouches] anyObject] locationInView:nil];
	}
}

-(void)editMode {
	edit_mode = !edit_mode;
}

-(void)recordMode {
	if(!edit_mode){
        lo_message msg = lo_message_new();
		if(record_mode){
			record_mode = false;
            lo_message msg = lo_message_new();
            [Sequencer sendMsg:msg withPath:[[NSString stringWithFormat:@"%@/%@", MODE_INSTRUMENT, @"free-form"] cStringUsingEncoding:NSASCIIStringEncoding]];
			[record_start release];
		} else {
			record_mode = true;
            [Sequencer sendMsg:msg withPath:[[NSString stringWithFormat:@"%@/%@", MODE_INSTRUMENT, @"sequence"] cStringUsingEncoding:NSASCIIStringEncoding]];
			record_start = [[NSDate date] retain];
		}
	}
}


-(void)update_grid:(NSTimeInterval)time :(int)value{ 
	NSLog(@"updating grid");
	
	UIImageView *grid_image ;
	
	switch (value) {
		case 0:
			grid_image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green-dot.png"]];
			break;
		case 1:
			grid_image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"magenta-dot.png"]];
			break;
		case 2:
			grid_image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yellow-dot.png"]];
			break;
		case 3:
			grid_image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue-dot.png"]];
			break;
		default:
			break;
	}
		
	grid_image.frame = CGRectMake(290+ 6*value, measure.center.y, 6, 6);
	[self.view insertSubview:grid_image atIndex:2];
	[grid_images addObject:grid_image];
	
	[grid_image release];
}

-(void)clear_grid {
	NSLog(@"clearing grid");
	[self.grid_images makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self.grid_images removeAllObjects];
    [Sequencer sendMsg:lo_message_new() withPath:[CLEAR_INSTRUMENT cStringUsingEncoding:NSASCIIStringEncoding]];
}

-(void)update_measure {

	CGPoint location = measure.center;
	if(location.y > 460.0){
		location.y = 212.0;
	} else {
		location.y += 1.0;
	}
	measure.center = location;	
}

-(void)intervalDidPass
{
    [self update_measure];
}

- (void)dealloc {
    [super dealloc];
	[grid_images release];
	[self.view release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.view = nil;
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || 
		 interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
 }*/
 

@end


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */






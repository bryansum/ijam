//
//  GridButtonController.m
//  iJam-sequence
//
//  Created by Bryan Summersett on 10/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GridButtonController.h"
#import "iJamViewController.h"
#import "Sequencer.h"

#define NUM_ROWS 4
#define NUM_COLS 8

@implementation GridButtonController

@synthesize viewController;

- (void) dealloc
{
    //NSLog(@"Dealloced GridButton");
    [super dealloc];
}

-(IBAction)toggleEvent:(UIButton *)sender
{
    [sender setTitle:@"ON" forState:UIControlStateSelected];

    //NSLog(@"Received event");
    // convert to instrument / period
    MusicEvent *event = [[MusicEvent alloc] init];    
    event.instrument = (NSUInteger) sender.tag / NUM_COLS;
	
    // set the volume based on the accelerometer magnitude
    event.volume = [viewController accelerometerMagnitude];
    
    if ([sender isSelected]) {        
        sender.selected = NO;
        event.type = STOP;
    } else {
        sender.selected = YES;
        event.type = START;
    }
    
    NSUInteger period = sender.tag % NUM_COLS;
    
    //NSLog(@"Received trigger from button %@, period %lu", event, (unsigned long)period);
    
    // send off 
    NSNumber *instNum = [NSNumber numberWithInteger:event.instrument];
    if (event.type == START) {
        [viewController.sequencer setEvent:event atPeriod:period forInstrument:instNum];        
    } else {
        [viewController.sequencer removeEventForInstrument:instNum atPeriod:period];
    }
    
    [event release];
}

@end

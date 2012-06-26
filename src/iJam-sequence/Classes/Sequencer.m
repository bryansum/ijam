//
//  Sequencer.m
//  iJam-sequence
//
//  Created by Bryan Summersett on 10/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Sequencer.h"
#import "AVController.h"
#import "MusicEvent.h"
#import "iJamViewController.h"
#import <Foundation/NSException.h>
#include <unistd.h>

#define NUM_DEFAULT_PERIODS 8
#define DEFAULT_BPM 120
#define SLEEPNS_PER_BPM(BPM) (useconds_t) (pow(10, 6) * 60 / BPM)

@implementation Sequencer

@synthesize bpm; //TODO: store this as SLEEPNS_PER_BPM for performance reasons

@synthesize numPeriods;
@synthesize viewController;

- (id) init
{
    return [self initWithNumPeriods:NUM_DEFAULT_PERIODS];
}

-(id)initWithNumPeriods: (NSUInteger)nPeriods
{
    self = [super init];
    if (self != nil) {
        NSLog(@"Init with numPeriods: %lu", nPeriods);
        numPeriods = nPeriods;
        periods = [[NSMutableArray alloc] initWithCapacity:numPeriods];
        for(NSUInteger i = 0; i < nPeriods; ++i) {
            [periods insertObject:[NSMutableDictionary dictionary] atIndex:i];
        }        
		
		// set bpm
		self.bpm = DEFAULT_BPM;
		
		NSLog(@"Detaching new fireAudio thread");
		[NSThread detachNewThreadSelector:@selector(fireAudioLoop) toTarget:self withObject:nil];
    }
    return self;
}

- (void) dealloc
{
    NSLog(@"Dealloced Sequencer");
    [periods release];
    [viewController release];
    [super dealloc];
}

-(void)setEvent:(id)event atPeriod:(NSUInteger)period forInstrument:(id)instrument
{
    NSLog(@"setEvent event: (%@), period: %lu for instrument %@", event, (unsigned long)period, instrument);
    [[periods objectAtIndex:period] setObject:event forKey:instrument];
}

-(void)removeEventForInstrument:(id)instrument atPeriod:(NSUInteger)period
{
    [[periods objectAtIndex:period] removeObjectForKey:instrument];
}

-(NSArray *)getEventsForPeriod:(NSUInteger)period
{
    NSMutableDictionary *eventDict = [periods objectAtIndex:period]; 
    return [eventDict allValues];
}
    
-(IBAction)makeFireAudio
{
    [self fireAudio];
}

-(void)fireAudioLoop
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [NSThread setThreadPriority:1.0];
	
	while(1) {
		[self fireAudio];
		usleep(SLEEPNS_PER_BPM(self.bpm));
	}
	
	[pool drain];
}

// Fires off audio to our AVController
-(void)fireAudio
{
    NSArray *events = [self getEventsForPeriod:currentPeriod];
    
    for (MusicEvent *event in events) {
        
        // figure out instrument
        NSString *instrument;
        NSLog(@"%lu", event.instrument);
        switch (event.instrument) {
            case 0:
                instrument = @"kick";
                break;
            case 1:
                instrument = @"snare";
                break;
            case 2:
                instrument = @"crash";
                break;
            case 3:
                instrument = @"hi-hat";
                break;
            default:
                NSLog(@"Instrument %lu not defined", (unsigned long) event.instrument);
                break;
        }
        [viewController.avController playInstrument:instrument];
    }
    currentPeriod = (currentPeriod + 1) % 8;
     
}

@end

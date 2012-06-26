//
//  Sequencer.h
//  iJam-sequence
//
//  Created by Bryan Summersett on 10/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
@class iJamViewController;

extern NSUInteger const kDefaultPeriods;

@interface Sequencer : NSObject {
@private
    NSMutableArray *periods; // NSMA of Events
    NSUInteger numPeriods;
    
    NSUInteger currentPeriod;
	
	float bpm;
    
    // Referecnce to our controller parent
    iJamViewController *viewController;
}

-(id)init;
-(id)initWithNumPeriods:(NSUInteger)numPeriods;

// Insert event for a given instrume
-(void)setEvent:(id)event atPeriod:(NSUInteger)period forInstrument:(id)instrument;
-(void)removeEventForInstrument:(id)instrument atPeriod:(NSUInteger)period;

// Events and instruments are updated references to C arrays, and the method returns a
// count of the number of events
-(NSArray *)getEventsForPeriod:(NSUInteger)period;

-(IBAction)makeFireAudio;
-(void)fireAudio;

@property (assign) float bpm;
@property (readonly) NSUInteger numPeriods;
@property (nonatomic, retain) iJamViewController *viewController;

@end

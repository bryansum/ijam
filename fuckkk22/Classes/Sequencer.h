//
//  Sequencer.h
//  fuckkk22
//
//  Created by Bryan Summersett on 12/10/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioOutput.h"
#import "PdController.h"
#import <lo.h>
    
// This sequencer is basically another singleton. It has its startTime and keys off that 
// value to calculate beats and so on. 
// 
#ifdef __cplusplus
extern "C" {
#endif

void SequencerCallbackFn(AudioTimeStamp *ts);

@interface Sequencer : NSObject {}

+(void)startTiming;
+(void)startTimingWithBpm:(NSInteger)bpm;
+(void)sendMsg:(lo_message)msg withPath:(const char *)path; // don't have to fill out timestamp field
+(void)setDelegate:(id)d withInterval:(double)seconds;
@end

#ifdef __cplusplus
}
#endif
        

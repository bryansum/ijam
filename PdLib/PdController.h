//
//  PdController.h
//  PdLib
//
//  Created by Bryan Summersett on 11/21/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioOutput.h"

// This is a somewhat malformed singleton.
// First set externs, openfiles, and libdir to the desired values BEFORE
// the calling "start" on PdController. Any changes to these properties 
// after starting will not be reflected until PD is either stopped or restarted.

@interface PdController : NSObject {
@private
    NSThread        *pdThread;
    NSArray         *externs;
    NSArray         *openfiles;
    NSString        *libdir;
    NSInteger       soundRate; // in Hz
    NSInteger       blockSize; // essentially, how many samples to run per DSP tick. Defaults to 256
    NSInteger       nOutChannels; // 1/2: If we want mono or stereo out
    AudioCallbackFn callbackFn; // Function to call back for every DSP tick. Called BEFORE DSP rendering
}

+ (PdController*)sharedController;
-(int)openFile:(NSString*)path;
-(void)start;
-(void)restart;
-(void)stop;

@property (copy) NSArray *externs;
@property (copy) NSArray *openfiles;
@property (copy) NSString *libdir;
@property (assign) NSInteger soundRate;
@property (assign) NSInteger blockSize;
@property (assign) NSInteger nOutChannels;
@property (assign) AudioCallbackFn callbackFn;
@end

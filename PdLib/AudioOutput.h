/*
 *  AudioOutput.h
 *  mobilesynth
 *
 *  Created by Bryan Summersett on 11/22/09.
 *  Copyright 2009 NatIanBryan. All rights reserved.
 *
 */

#ifndef _AUDIO_OUTPUT_H
#define _AUDIO_OUTPUT_H

#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>

typedef void (*AudioCallbackFn)(AudioTimeStamp *timestamp);

typedef struct AudioCallbackParams {
    AudioCallbackFn     callback;
    AudioUnit           audioUnit;
} AudioCallbackParams;

OSStatus AudioOutputInitialize(AudioCallbackParams *params);

#endif

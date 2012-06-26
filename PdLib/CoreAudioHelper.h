/*
 *  coreaudio_helper.h
 *  Pd-commandline
 *
 *  Created by Bryan Summersett on 11/6/09.
 *  Copyright 2009 NatIanBryan. All rights reserved.
 *
 */

#ifndef CORE_AUDIO_HELPER_H
#define CORE_AUDIO_HELPER_H
    
#include "pdAudio.h"
#include "CAStreamBasicDescription.h"
#include <AudioToolbox/AudioToolbox.h>
#include <AudioUnit/AudioUnit.h>
#include <CoreAudio/CoreAudioTypes.h>
#include <objc/objc.h>
#include <stdbool.h>

// Forward declaration
struct AudioParams;
    
struct CoreAudioHelper 
{
    CoreAudioHelper(AudioCallbackFn *);
    ~CoreAudioHelper();
    
	CAStreamBasicDescription	thruFormat;
	
    AURenderCallbackStruct		playbackCallbackStruct;
    AURenderCallbackStruct		micInputCallbackStruct;

	AudioUnit					rioUnit;
	BOOL						unitIsRunning;

    AudioParams                 *audioParams;
    
    // External callback function. Note that this is keyed on 
    AudioCallbackFn             *externalCallback;
    
    // Variables used to synchronize when our audio callback fn is fired
	bool                        hasMicData;
	bool                        hasSpeakerData;
};

void SilenceData(AudioBufferList *inData);
            
#endif /* CORE_AUDIO_HELPER_H */

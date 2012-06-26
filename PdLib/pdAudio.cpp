/* Copyright (c) 2003, Miller Puckette and others.
* For information on usage and redistribution, and for a DISCLAIMER OF ALL
* WARRANTIES, see the file, "LICENSE.txt," in this distribution.  */

/* Replacment for s_audio.c for **iPhone ONLY** */

#include "PdLib.h"
#include "pdAudio.h"
#include "AudioParams.h"
#include "s_stuff.h"
#include "CoreAudioHelper.h"
#include <stdio.h>
#include <assert.h>
#include <unistd.h>
#include <errno.h>

// our current audio parameter settings.
static CoreAudioHelper *gCoreAudioHelper = 0;
static bool gIsAudioOpen = false;

OSStatus sysAudioOpen(AudioCallbackFn *inCallback) {
    if (gIsAudioOpen)
        return kPdLibErrAlreadyInitialized;
    
    canvas_resume_dsp(canvas_suspend_dsp());
    
    gCoreAudioHelper = new CoreAudioHelper(inCallback);
    
    // everything worked, continue!
    gIsAudioOpen = gCoreAudioHelper->unitIsRunning;
    
    if (gIsAudioOpen) {
        return noErr;
    } else {
        return kPdLibErrCoreAudio;
    }
}


OSStatus sysAudioClose(void) {
    if (!gIsAudioOpen)
        return kPdLibErrNotInitialized;
    
    canvas_suspend_dsp();

    // CoreAudioHelper follows the RAII paradigm, so deleting it removes the
    // audio unit from processing
    if (gCoreAudioHelper) delete gCoreAudioHelper;
    
    gIsAudioOpen = false;
    
    return noErr;
}

int sysAudioIsInitialized(void) {
    return gIsAudioOpen;
}

AudioBuffer *sysAudioGetInBuffer(void) {
    assert(sysAudioIsInitialized());
    return &gCoreAudioHelper->audioParams->bufs[kInputBuffer];
}

AudioBuffer *sysAudioGetOutBuffer(void) {
    assert(sysAudioIsInitialized());
    return &gCoreAudioHelper->audioParams->bufs[kOutputBuffer];    
}

// in seconds
Float32 sysAudioGetBufferDuration(void) {
    assert(sysAudioIsInitialized());
    return gCoreAudioHelper->audioParams->bufferDuration;
}

// in samples / second
UInt32 sysAudioGetSampleRate(void) {
    assert(sysAudioIsInitialized());
    return gCoreAudioHelper->audioParams->sampleRate;
}

// In samples
UInt32 sysAudioGetNumSamplesInBlock(void) {
    assert(gIsAudioOpen);
    return gCoreAudioHelper->audioParams->getBufferNumSamplesInBlock();
}


/*
 *  Test.cpp
 *  Pd-commandline
 *
 *  Created by Bryan Summersett on 11/7/09.
 *  Copyright 2009 NatIanBryan. All rights reserved.
 *
 */

#include "AudioParams.h"
#include <stdlib.h>

AudioParams::AudioParams(Float64 inSampleRate,
                         Float32 inBufferDuration, 
                         UInt32 inNumOutChannels,
                         UInt32 inNumInChannels) : 
    sampleRate(inSampleRate),
    bufferDuration(inBufferDuration)
{
    //bufs.mBuffers = malloc(kNumBuffers * sizeof(AudioBuffer));
    bufs[kOutputBuffer].mNumberChannels = inNumOutChannels;
    bufs[kInputBuffer].mNumberChannels = inNumInChannels;
    for(UInt32 i = 0; i < 2; i++) {
        bufs[i].mDataByteSize = getTotalBufferByteSize((AudioParamsBufferType) i);
        bufs[i].mData = malloc(bufs[i].mDataByteSize);
    }
}

AudioParams::~AudioParams() {
    // remove all audio buffer data
    for(UInt32 i = 0; i < 2; i++) {
        if (bufs[i].mDataByteSize > 0) {
            free(bufs[i].mData);
        }
    }
}

UInt32 AudioParams::getTotalBufferByteSize(AudioParamsBufferType bufType) { 
    return getBufferNumSamplesInBlock() * bufs[bufType].mNumberChannels; 
}

UInt32 AudioParams::getBufferNumSamplesInBlock() { 
    return bufferDuration * sampleRate;
}

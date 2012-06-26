
#ifndef _AUDIO_PARAMS_H
#define _AUDIO_PARAMS_H

#include <CoreAudio/CoreAudioTypes.h>
#include <CoreFoundation/CoreFoundation.h>

const UInt32  kDefaultSampleRate = 44100;
const UInt32  kDefaultNumChannels = 2;
const Float32 kDefaultBufferDuration = 0.005;       // seconds

typedef enum AudioParamsBufferType { 
    kOutputBuffer = 0, 
    kInputBuffer = 1
} AudioParamsBufferType;

struct AudioParams
{
    AudioParams(Float64 inSampleRate = kDefaultSampleRate,
                Float32 inBufferDuration = kDefaultBufferDuration, 
                UInt32 inNumOutChannels = kDefaultNumChannels,
                UInt32 inNumInChannels = kDefaultNumChannels);
    
    ~AudioParams();
    
    Float64          sampleRate;                    // rate in Hz
    Float32         bufferDuration;                // buffer duration in sec
    
    // These AudioBuffers here are stored in a different way than CoreAudio does. 
    // Whereas CoreAudio uses two mono AudioBuffers when dealing with 
    // non-interleaved audio, we're using them to store both the left & right
    // channel one after each other. For instance, buffer's mData for 2 channels is essentially:
    //  ----------------------------------------------------------------------
    //  |  leftChan (blockSize bytes)       |    rightChan (blockSize bytes) |
    //  ----------------------------------------------------------------------
    //
    // and so the total buffer size is blockSize * # channels, where 
    // blockSize = sampleRate * bufferDuration * sizeof(sample)
    AudioBuffer     bufs[2];                       // buffers for out & in, respectively

    UInt32 getTotalBufferByteSize(AudioParamsBufferType bufType);
    UInt32 getBufferNumSamplesInBlock();
};
        

#endif

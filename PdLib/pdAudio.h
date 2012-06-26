
#ifndef PD_AUDIO_H
#define PD_AUDIO_H
    
#ifdef __cplusplus
extern "C" {
#endif
    
#include "MacTypes.h"
#include <CoreAudio/CoreAudioTypes.h>
    
// The type of function we're going to callback to whenever we get a CoreAudio
// callback request. 
// Calling this implies we've written something to the buffers and and has such
// has new data for processing. 
typedef void (*AudioCallbackFn)(void);

OSStatus sysAudioOpen(AudioCallbackFn *inCallback);
OSStatus sysAudioClose(void);

AudioBuffer *sysAudioGetInBuffer(void);
AudioBuffer *sysAudioGetOutBuffer(void);

int sysAudioIsInitialized(void);
Float32 sysAudioGetBufferDuration(void); // In seconds
UInt32 sysAudioGetSampleRate(void); // in samples / sec
UInt32 sysAudioGetNumSamplesInBlock(void); // in samples

#ifdef __cplusplus
}
#endif
        
#endif /* PD_AUDIO_H */

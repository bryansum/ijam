/*
 *  AudioOutput.c
 *
 *  Created by Bryan Summersett on 11/22/09.
 *  Copyright 2009 NatIanBryan. All rights reserved.
 *
 */

#import "AudioOutput.h"
#import "m_pd.h"
#import "s_stuff.h"

#define MIN(a,b) ((a)>(b)?(b):(a))
#define MAX(a,b) ((a)<(b)?(b):(a))
#ifndef CLAMP
#define CLAMP(min,x,max) (x < min ? min : (x > max ? max : x))
#endif

static const UInt32 kOutputBus = 0;

static void interruptionListener(void *inClientData, UInt32 inInterruption)
{
    fprintf(stderr,"Session interrupted! %s, ", inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");
	
	AudioCallbackParams *params = (AudioCallbackParams*)inClientData;
	
	if (inInterruption == kAudioSessionEndInterruption) {
		// make sure we are again the active session
		AudioSessionSetActive(true);
		AudioOutputUnitStart(params->audioUnit);
	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
		AudioOutputUnitStop(params->audioUnit);
    }
}

static OSStatus playCallback(void *inRefCon,
                             AudioUnitRenderActionFlags *ioActionFlags __attribute__((unused)),
                             const AudioTimeStamp *inTimeStamp,
                             UInt32 inBusNumber,
                             UInt32 inNumberFrames,
                             AudioBufferList *ioData) {
    assert(inBusNumber == kOutputBus);
    assert(ioData->mNumberBuffers == 1);  // doing one callback, right?
    assert(sizeof(t_sample) == 4);  // assume 32-bit floats here

    // sys_schedblocksize is How many frames we have per PD dsp_tick
    // inNumberFrames is how many CoreAudio wants
    
    // Make sure we're dealing with evenly divisible numbers here. Otherwise
    // this looping scheme doesn't make much sense
    assert(inNumberFrames % sys_schedblocksize == 0);
    // How many times to iterate through PD's dsp loop
    UInt32 times = inNumberFrames / sys_schedblocksize;
    
    AudioBuffer *buffer = &ioData->mBuffers[0];
    SInt16 *data = (SInt16*) buffer->mData;

    AudioCallbackParams *params = (AudioCallbackParams*)inRefCon;

    for(UInt32 i = 0; i < times; i++) {

        sys_lock();
        (*params->callback)(inTimeStamp);
        sys_unlock();
                
        // This should cover left & right channels both. Turns non-interleaved into 
        // interleaved audio.
        for (int n = 0; n < sys_schedblocksize; n++) {
            for(int ch = 0; ch < sys_noutchannels; ch++) {
                t_sample fsample = sys_soundout[n+sys_schedblocksize*ch];
                //fsample = CLAMP(-1.0, fsample, 1.0); // clip if necessary
                SInt16 sample = (SInt16)(fsample * 32767.0);
                data[(n*sys_noutchannels+ch) + // offset in iteration
                     i*sys_schedblocksize*sys_noutchannels] // iteration starting address
                = sample;
            }
        }
        
        // After loading the samples, we need to wipe them out
        memset(sys_soundout, 0, sizeof(t_sample)*sys_noutchannels*sys_schedblocksize);        
    }
    // Tell our callback how much we've filled it up
    //buffer->mDataByteSize = sizeof(SInt16) * inNumberFrames;    

    return noErr;
}

OSStatus AudioOutputInitialize(AudioCallbackParams *params)
{    
    // Initialize Audio session
    OSStatus status;
    
    if ((status = AudioSessionInitialize(NULL, NULL, interruptionListener, params))) {
        fprintf(stderr,"couldn't initialize audio session");
        return status;
    }
        
    if ((status = AudioSessionSetActive(true))) {
        fprintf(stderr,"couldn't set active audio session");
        return status;
    }
    
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    
    if ((status = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, 
                                          sizeof(audioCategory), 
                                          &audioCategory))) {
        fprintf(stderr,"couldn't set up audio category");
        return status;
    }
    // Now set output format
    
    AudioStreamBasicDescription outputFormat;
    memset(&outputFormat, 0, sizeof(outputFormat));
    outputFormat.mSampleRate = sys_dacsr;
    outputFormat.mFormatID = kAudioFormatLinearPCM;
        
    // Used a signed integer as per http://www.subfurther.com/blog/?p=507        
    outputFormat.mFormatFlags  = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    outputFormat.mFramesPerPacket = 1; // always this for PCM audio
    outputFormat.mBytesPerPacket = sizeof(SInt16) * sys_noutchannels;
    outputFormat.mBytesPerFrame = sizeof(SInt16) * sys_noutchannels;
    outputFormat.mChannelsPerFrame = sys_noutchannels;
    outputFormat.mBitsPerChannel = 8 * sizeof(SInt16);
    outputFormat.mReserved = 0;
    
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent outputComponent = AudioComponentFindNext(NULL, &desc);
    if (outputComponent == NULL) {
        fprintf(stderr,"AudioComponentFindNext failed");
        return status;
    }
    
    // Get audio units
    status = AudioComponentInstanceNew(outputComponent, &params->audioUnit);
    if (status) {
        fprintf(stderr,"AudioComponentInstanceNew failed");
        return status;
    }
    
    // Enable playback
    UInt32 enableIO = 1;
    status = AudioUnitSetProperty(params->audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &enableIO,
                                  sizeof(UInt32));
    if (status) {
        fprintf(stderr,"AudioUnitSetProperty EnableIO (out)");
        return status;
    }
    
    // Apply format
    status = AudioUnitSetProperty(params->audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &outputFormat,
                                  sizeof(AudioStreamBasicDescription));
    if (status) {
        fprintf(stderr,"AudioUnitSetProperty StreamFormat");
        return status;
    }
    
    AURenderCallbackStruct callback;
    callback.inputProc = &playCallback;
    callback.inputProcRefCon = params;
    
    // Set output callback
    status = AudioUnitSetProperty(params->audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callback,
                                  sizeof(AURenderCallbackStruct));
    if (status) {
        fprintf(stderr,"AudioUnitSetProperty SetRenderCallback");
        return status;
    }
    
    status = AudioUnitInitialize(params->audioUnit);
    if (status) {
        fprintf(stderr,"AudioUnitInitialize failure");
        return status;
    }  
    
    status = AudioOutputUnitStart(params->audioUnit);
    if (status) {
        fprintf(stderr,"AudioOutputUnitStart failure");
        return status;
    }
    
    return noErr;
}

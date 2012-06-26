/*
 *  coreaudio_helper.cpp
 *  Pd-commandline
 *
 *  Created by Bryan Summersett on 11/6/09.
 *  Copyright 2009 NatIanBryan. All rights reserved.
 *
 */

#include "CoreAudioHelper.h"
#include "AudioParams.h"
#include <AudioToolbox/AudioToolbox.h>
#include <AudioUnit/AudioUnit.h>
#include <AudioUnit/AUComponent.h>
#include "CAXException.h"
#include "m_pd.h"

// For any of this, I HIGHLY recommend looking at 
// http://www.subfurther.com/blog/?p=507
// helpful hints regarding CoreAudio. 
// The iPhone uses an Audio unit called RemoteIO for all its IO operations. It
// looks like this: (credit Chris Adamson):
//                            -------------------------
//                            | i                   o |
//-- BUS 1 -- from mic -->    | n    REMOTE I/O     u | -- BUS 1 -- to app -->
//                            | p      AUDIO        t |
//-- BUS 0 -- from app -->    | u       UNIT        p | -- BUS 0 -- to speaker -->
//                            | t                   u |
//                            |                     t |
//                            -------------------------
//
// With that in mind, we set the buses thusly:
//              	
// Input Scope,  Bus 0:     Set ASBD to indicate what you’re providing for play-out	
//               Bus 1:     Get ASBD to inspect audio format being received from H/W
// Output Scope, Bus 0:     Get ASBD to inspect audio format being sent to H/W	
//               Bus 1:     Set ASBD to indicate what format you want your units to receive
// 
// Also, see http://michael.tyson.id.au/2008/11/04/using-remoteio-audio-unit/
// for another good source in understanding this madness. 

enum {
    kAppInputBus      = 0,
    kMicInputBus      = 1,
    kSpeakerOutputBus = 0,
    kAppOutputBus     = 1,
};

#pragma mark Helper methods

// Given a RemoteIO audio unit, a mic input callback function, 
// a playback callback function, and desired audio format for all,
// initializes the RemoteIO with playback / recording capabilities. 
static int SetupRemoteIO (AudioUnit& inRemoteIOUnit, 
                   AURenderCallbackStruct inMicInputCallback, 
                   AURenderCallbackStruct inPlaybackCallback,
                   CAStreamBasicDescription& outFormat)
{	
	try {		
		// Open the output unit
		AudioComponentDescription desc;
		desc.componentType = kAudioUnitType_Output;
		desc.componentSubType = kAudioUnitSubType_RemoteIO;
		desc.componentManufacturer = kAudioUnitManufacturer_Apple;
		desc.componentFlags = 0;
		desc.componentFlagsMask = 0;
		
		AudioComponent comp = AudioComponentFindNext(NULL, &desc);
		
		XThrowIfError(AudioComponentInstanceNew(comp, &inRemoteIOUnit), 
                      "couldn't open the remote I/O unit");
        
        // Enable recording on bus 1 (the mic input bus)
		UInt32 one = 1;
		XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, 
                                           kAudioOutputUnitProperty_EnableIO, 
                                           kAudioUnitScope_Input, 
                                           kMicInputBus, 
                                           &one, 
                                           sizeof(one)), 
                      "couldn't enable input on the remote I/O unit");

        // Enable playback on the speaker bus. This is probably already enabled
        // by default. 
        XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, 
                                      kAudioOutputUnitProperty_EnableIO, 
                                      kAudioUnitScope_Output, 
                                      kSpeakerOutputBus,
                                      &one, 
                                      sizeof(one)),
                      "couldn't enable speaker playback");
        
        // Set a render callback for mic input
		XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, 
                                           kAudioOutputUnitProperty_SetInputCallback, 
                                           kAudioUnitScope_Global, 
                                           kMicInputBus, 
                                           &inMicInputCallback, 
                                           sizeof(inMicInputCallback)), 
                      "couldn't set remote i/o mic input callback");

        // Set the playback callback. This is where PD sets CoreAudio's buffers. 
        XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, 
                                           kAudioUnitProperty_SetRenderCallback, 
                                           kAudioUnitScope_Global, 
                                           kAppInputBus,
                                           &inPlaybackCallback, 
                                           sizeof(inPlaybackCallback)),
                      "couldn't set up playback callback for device");
        
        // Set the audio format we're going to send the RemoteIO unit from PD. 
		XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, 
                                           kAudioUnitProperty_StreamFormat, 
                                           kAudioUnitScope_Input, 
                                           kAppInputBus, 
                                           &outFormat, 
                                           sizeof(outFormat)), 
                      "couldn't set the remote I/O unit's app input format");
        
        // What format our audio units are going to receive from the RemoteIO unit. 
//		XThrowIfError(AudioUnitSetProperty(inRemoteIOUnit, 
//                                           kAudioUnitProperty_StreamFormat, 
//                                           kAudioUnitScope_Output, 
//                                           kAppOutputBus, 
//                                           &inFormat, 
//                                           sizeof(inFormat)), 
//                      "couldn't set the remote I/O unit's app output format");
        
	} catch (CAXException &e) {
		char buf[256];
		error("Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		return 1;
	}
	catch (...) {
		error("An unknown error occurred\n");
		return 1;
	}	
	
	return 0;
}

void SilenceData(AudioBufferList *inData)
{
	for (UInt32 i=0; i < inData->mNumberBuffers; i++) {
        memset(inData->mBuffers[i].mData, 0, inData->mBuffers[i].mDataByteSize);
    }
}

#pragma mark -Audio Session Interruption Listener

void rioInterruptionListener(void *inClientData, UInt32 inInterruption)
{
	debug("Session interrupted! --- %s ---", 
           (inInterruption == kAudioSessionBeginInterruption) ? "Begin Interruption" : "End Interruption");
	
	CoreAudioHelper *THIS = (CoreAudioHelper*)inClientData;
	
	if (inInterruption == kAudioSessionEndInterruption) {
		// make sure we are again the active session
		AudioSessionSetActive(true);
		AudioOutputUnitStart(THIS->rioUnit);
	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
		AudioOutputUnitStop(THIS->rioUnit);
    }
}

#pragma mark -Audio Session Property Listener

void propListener(void *                  inClientData,
                  AudioSessionPropertyID  inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
    debug("Property listener callback function entered");
    
	CoreAudioHelper *THIS = (CoreAudioHelper*)inClientData;
	if (inID == kAudioSessionProperty_AudioRouteChange) {
		try {
			// if there was a route change, we need to dispose the current rio unit and create a new one.
			XThrowIfError(AudioComponentInstanceDispose(THIS->rioUnit), "couldn't dispose remote i/o unit");		
            
			SetupRemoteIO(THIS->rioUnit, 
                          THIS->micInputCallbackStruct, 
                          THIS->playbackCallbackStruct,
                          THIS->thruFormat);
			
            // Get the new sample rate, if that's what changed. 
            UInt32 newSampleRate;
            UInt32 oldSampleRate = THIS->audioParams->sampleRate;
			UInt32 size = sizeof(newSampleRate);
			XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, 
                                                  &size, 
                                                  &(newSampleRate)),
                          "couldn't get new sample rate");

            if (oldSampleRate != newSampleRate) {
                error("Error: sample rate has changed from %lu to %lu!",oldSampleRate,newSampleRate);
                // This will cause some problems, I think
                assert(false);
            }
            
            // Start up this unit again. 
			XThrowIfError(AudioOutputUnitStart(THIS->rioUnit), 
                          "couldn't start unit");
            
            // Now, find out what our new route is since we know it changed. 
			CFStringRef newRoute;
			size = sizeof(CFStringRef);
			XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, 
                                                  &size, 
                                                  &newRoute), 
                          "couldn't get new audio route");
			if (newRoute)
			{	
				CFShow(newRoute);
				if (CFStringCompare(newRoute, CFSTR("Headset"), NULL) == kCFCompareEqualTo) {
                    // Put code dependent on the headphone jack here
                } else if (CFStringCompare(newRoute, CFSTR("Receiver"), NULL) == kCFCompareEqualTo) {
                    // Put code dependent on the receiver (?) here
                } else {
                    // Otherwise something else. I don't know what this would be 
                    // exactly....
                }
			}
		} catch (CAXException e) {
			char buf[256];
			error("Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		}
	}
}

#pragma mark -RIO Render Callback

// float to 8.24
static inline SInt32 FloatToFixed(Float32 sample) {
    return sample * (1<<24);
}

// 8.24 to float
static inline Float32 FixedToFloat(SInt32 sample) {
    return sample / (Float32)(1<<24);
}

// Note that these two have mutexes around the bottom parts: we need this so that
// 1) we can wait until the recording buffer AND the playback buffer are full; and
// 2) we guarantee that the callback function receives valid input AND
// 3) external calls via PdLib are blocked until the DSP calculations are done.
//      (See the PdLib.c file for more sys_lock, unlocks)

static OSStatus	micInputCallback(void						*inRefCon, 
                                AudioUnitRenderActionFlags 	*ioActionFlags, 
                                const AudioTimeStamp 		*inTimeStamp, 
                                UInt32 						inBusNumber, 
                                UInt32 						inNumberFrames, 
                                AudioBufferList 			*ioData)
{
	CoreAudioHelper *THIS = (CoreAudioHelper *)inRefCon;

    debug("Mic input callback function entered");
    
    assert(inBusNumber == kMicInputBus); // We should be dealing with the app input bus. 
    
    // actually render our audio. The callback doesn't do this automatically 
    // for us. 
	OSStatus err = AudioUnitRender(THIS->rioUnit, 
                                   ioActionFlags, 
                                   inTimeStamp, 
                                   kMicInputBus, 
                                   inNumberFrames, 
                                   ioData);

    if (err != noErr) { 
        error("micInputCallback: error %d\n", (int)err); 
        assert(false);
    }
    // Read the discussion on AudioStreamBasicDescription for more information.
    // When dealing with non-interleaved audio, a buffer is made for each channel. 
    assert(ioData->mNumberBuffers == THIS->audioParams->bufs[kInputBuffer].mNumberChannels); 
    
	

	// Remove DC component
    // TODO: determine if this helps us or not. For now, assume we don't need it. 
//	for(UInt32 i = 0; i < ioData->mNumberBuffers; ++i) {
//        THIS->dcFilter[i].InplaceFilter((SInt32*)(ioData->mBuffers[i].mData), inNumberFrames, 1);
//    }
    
    // Synchronize when to fire off our callback function
    sys_lock();
    
    if (THIS->hasMicData) { // already called twice before the next playback callback!
        debug("micCallback called twice before playback!");
    }
    THIS->hasMicData = true;    
    
    // For each *channel*
    for (UInt32 i = 0; i < ioData->mNumberBuffers; i++) {
        AudioBuffer inBuffer = ioData->mBuffers[i];
        SInt32* in = (SInt32*)inBuffer.mData;
        Float32* out = (Float32*)THIS->audioParams->bufs[kInputBuffer].mData;
        
        // As a consequence of the way non-interleaved data is stored, all of these
        // have are in mono, split by AudioBuffer. 
        assert(inBuffer.mNumberChannels == 1);
        
        // bytesInBlock/sizeof(sample) == # samples / block
        // This is called "blockSize" elsewhere in PD
        assert(inBuffer.mDataByteSize / sizeof(AudioSampleType) == inNumberFrames);
        // We should be receiving just enough samples to fill our buffer
        assert(THIS->audioParams->getBufferNumSamplesInBlock() == inNumberFrames);
        
        // convert all audio from fixed point to PD's floating pt
        for (UInt32 j = 0; j < inNumberFrames; ++i) {
            out[j + i*inNumberFrames] = FixedToFloat(in[i]);
        }
    }
        
    if (THIS->hasSpeakerData) { // if we have a full buffer
        debug("firing extern callback from mic callback");        
        (*THIS->externalCallback)(); // fire off callback
        THIS->hasMicData = THIS->hasSpeakerData = false;
    }
    sys_unlock();

	return err;
}

static OSStatus playbackCallback(void                       *inRefCon, 
								 AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp       *inTimeStamp, 
								 UInt32                     inBusNumber, 
								 UInt32                     inNumberFrames, 
								 AudioBufferList            *ioData) 
{  
    debug("Playback callback function entered");
    
    CoreAudioHelper *THIS = (CoreAudioHelper *)inRefCon;
    
    assert(inBusNumber == kAppInputBus); // We should be dealing with the app input bus. 
    // Read the discussion on AudioStreamBasicDescription for more information.
    // When dealing with non-interleaved audio, a buffer is made for each channel. 
    assert(ioData->mNumberBuffers == THIS->audioParams->bufs[kOutputBuffer].mNumberChannels); 
    
    // Synchronize when to fire off our callback function
    sys_lock();

    if (THIS->hasSpeakerData) { // already called twice before the next playback callback!
        debug("playbackCallback called twice before micInput, dropping frames!");    
    }
    THIS->hasSpeakerData = true;
    
    // For each *channel*
    for (UInt32 i = 0; i < ioData->mNumberBuffers; i++) {
        AudioBuffer outBuffer = ioData->mBuffers[i];
        Float32* in = (Float32*)THIS->audioParams->bufs[kOutputBuffer].mData;
        SInt32* out = (SInt32*)outBuffer.mData;
        
        // As a consequence of the way non-interleaved data is stored, all of these
        // have are in mono, split by AudioBuffer. 
        assert(outBuffer.mNumberChannels == 1);
        
        // bytesInBlock/sizeof(sample) == # samples / block
        // This is called "blockSize" elsewhere in PD
        assert(outBuffer.mDataByteSize / sizeof(AudioSampleType) == inNumberFrames);
        // We should be receiving just enough samples to fill our buffer
        assert(THIS->audioParams->getBufferNumSamplesInBlock() == inNumberFrames);
        
        // convert all audio from float to fixed point for iphone
        for (UInt32 j = 0; j < inNumberFrames; ++i) {
            out[i] = FloatToFixed(in[j + i*inNumberFrames]);
        }
    }
    
    if (THIS->hasMicData) { // if we have a full buffer
        debug("firing extern callback from speaker callback");        
        (*THIS->externalCallback)(); // fire off callback
        THIS->hasMicData = THIS->hasSpeakerData = false;
    }
    sys_unlock();

    return noErr;
}

CoreAudioHelper::CoreAudioHelper(AudioCallbackFn *inExternCallback) : 
    unitIsRunning(NO),
    audioParams(0),
    externalCallback(inExternCallback),
    hasMicData(0),
    hasSpeakerData(0)
{
    // Initialize our remote i/o unit
	
	micInputCallbackStruct.inputProc = micInputCallback;
	micInputCallbackStruct.inputProcRefCon = this;
    playbackCallbackStruct.inputProc = playbackCallback;
    playbackCallbackStruct.inputProcRefCon = this;

    // set to Canonical AU format: LPCM non-interleaved (fixed point)
    // bryansum: From what I can read, this means that the audio is:
    // - SInt16 for iPhone (fixed point), Float32 for OS X.
    // - Native endian
    //
    // From testing, I've found the RemoteIO can do 1 mono channel of floating point
    // in each direction at either 22050Hz / 44100Hz, but it flakey when doing
    // stereo.
    // It seems to like 44100.0Hz, 2 channels for mic & speakers, fixed point, so that's what
    // we're going to leave it at. Note PD needs to convert this back to floating
    // point though, so there's the downside. 
    thruFormat.SetAUCanonical(kDefaultNumChannels, false); // 2 channels, non-interleaved fixed point
    
	try {        
		// Initialize and configure the audio session
		XThrowIfError(AudioSessionInitialize(NULL, 
                                             NULL, 
                                             rioInterruptionListener, 
                                             this), 
                      "couldn't initialize audio session");
        
        // Make this the active session for the iPhone
		XThrowIfError(AudioSessionSetActive(true), 
                      "couldn't set audio session active\n");
        
        // Make this a play and record app. See the definition for more information
        // on the implications of this. 
		UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
		XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, 
                                              sizeof(audioCategory), 
                                              &audioCategory), 
                      "couldn't set audio category");
        
        // When the audio route changes, we should resubmit all our audio format
        // information so that audio continues to play
		XThrowIfError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, 
                                                      propListener, 
                                                      this), "couldn't set property listener");
        
		Float32 preferredBufferDuration = kDefaultBufferDuration; // 0.005s by default
		XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, 
                                              sizeof(preferredBufferDuration), 
                                              &preferredBufferDuration), 
                      "couldn't set i/o buffer duration");
                
		XThrowIfError(SetupRemoteIO(rioUnit, 
                                    micInputCallbackStruct, 
                                    playbackCallbackStruct,
                                    thruFormat), 
                      "couldn't setup remote i/o unit");

		XThrowIfError(AudioUnitInitialize(rioUnit), 
                      "couldn't initialize the remote I/O unit");

        UInt32 size;

        Float32 bufferDuration;
        size = sizeof(bufferDuration);
		XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, 
                                              &size, 
                                              &bufferDuration), 
                      "couldn't get buffer duration");
        
        // 44100.0Hz by default
        Float64 hwSampleRate;
        size = sizeof(hwSampleRate);
		XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, 
                                              &size, 
                                              &hwSampleRate), 
                      "couldn't get hw sample rate");
        
		UInt32 maxFPS;
		size = sizeof(maxFPS);
		XThrowIfError(AudioUnitGetProperty(rioUnit, 
                                           kAudioUnitProperty_MaximumFramesPerSlice, 
                                           kAudioUnitScope_Global, 
                                           0, 
                                           &maxFPS, 
                                           &size), 
                      "couldn't get the remote I/O unit's max frames per slice");
        
        XThrowIfError(AudioOutputUnitStart(rioUnit), 
                      "couldn't start remote i/o unit");
        
        // after starting the unit, get our output format again. (It may have 
        // changed). 
		size = sizeof(thruFormat);
		XThrowIfError(AudioUnitGetProperty(rioUnit, 
                                           kAudioUnitProperty_StreamFormat, 
                                           kAudioUnitScope_Output, 
                                           kAppOutputBus, 
                                           &thruFormat, 
                                           &size), 
                      "couldn't get the remote I/O unit's output client format");

        audioParams = new AudioParams(hwSampleRate,
                                      bufferDuration,
                                      kDefaultNumChannels,
                                      kDefaultNumChannels);
        
        assert(bufSize == maxFPS);
        size_t bufSize = audioParams->bufs[kOutputBuffer].mDataByteSize;
        debug("maxFPS is %u, calculated audio buffer size is %u",maxFPS,bufSize);
        
        debug("Constructed CoreAudioHelper");

		unitIsRunning = YES;

	} catch (CAXException &e) {
		char buf[256];
		error("Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		unitIsRunning = NO;
	} catch (...) {
		error("An unknown error occurred\n");
		unitIsRunning = NO;
	}
	    
}

CoreAudioHelper::~CoreAudioHelper() {
    debug("Deallocing CoreAudioHelper");
    AudioUnitUninitialize(rioUnit);
    if (audioParams) delete audioParams;
}

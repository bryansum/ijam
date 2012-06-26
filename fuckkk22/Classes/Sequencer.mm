//
//  Sequencer.m
//  fuckkk22
//
//  Created by Bryan Summersett on 12/10/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import "Sequencer.h"
#import <CoreAudio/CoreAudioTypes.h>
#import <list>
#import <vector>
#import <string>
#include <ext/hash_map>
#include <uuid/uuid.h>
#import <mach/mach_time.h>
#import "CAHostTimeBase.h"
#import "ijam_ports.h"

#define MAXNAME 16
#define kDefaultBpm     120
#define kNumBars        4
#define kBeatsPerBar    4 // 4/4 time
#define TimelineInterval 0.04

struct OSCMsg {
    lo_message      msg;
    std::string     path;
    UInt64          timestamp;
    
    OSCMsg(lo_message inMsg, const char *inPath, UInt64 ts) : msg(inMsg), path(inPath), timestamp(ts) {}
};

typedef std::list<OSCMsg> OscMsgList;
typedef OscMsgList::iterator OscMsgListItr;

typedef enum SeqMode {
    kSeqModeFreeForm,
    kSeqModeSequence
} SeqMode;

struct OSCSeq {
    OscMsgList      list;
    OscMsgListItr   curEle;
    SeqMode         mode;
//    char            *owner;
};

struct eqstr {
    bool operator()(const char *s1, const char *s2) const {
        return strcmp(s1, s2) == 0;
    }
}; 

//typedef __gnu_cxx::hash_map<int, OSCSeq> OSCMsgsContainer;
//typedef OSCMsgsContainer::iterator OSCMsgsContainerItr;

// global variables!
//static OSCMsgsContainer     gOSCMsgs;
static OSCSeq               gSequence;
static UInt64               gStartTime = 0;
static NSInteger            gBpm;
static UInt64               nsPerTotalBars;
static lo_address           gLoAddress;
static pthread_mutex_t      seqMutex = PTHREAD_MUTEX_INITIALIZER;
static UInt64               totalBarsCount = 0;
static id                   delegate = NULL;
static UInt64               delegateNs = 0;
static UInt64               delegateCount = 0;

// Get the relative timestamp within the given 
static UInt64 getRelativeTimestamp(UInt64 ts)
{
    return (ts - gStartTime) % nsPerTotalBars;
}

static void updateSequencer(UInt64 ts, UInt64 seqNum)
{
//    for(OSCMsgsContainerItr it(gOSCMsgs.begin()); it != gOSCMsgs.end(); it++) {
//        OSCSeq& seq = it->second;
    OSCSeq& seq = gSequence;
    pthread_mutex_lock(&seqMutex);
    if (!seq.list.empty() && seq.curEle->timestamp < ts) {
        lo_send_message(gLoAddress, seq.curEle->path.c_str(), seq.curEle->msg);
        seq.curEle->timestamp += nsPerTotalBars;
        // Increment this element or loop back
        seq.curEle++;
        if (seq.curEle == seq.list.end()) seq.curEle = seq.list.begin();
    }
    pthread_mutex_unlock(&seqMutex);
//    }    
}

// This gets called on every CoreAudio callback
void SequencerCallbackFn(AudioTimeStamp *ts)
{
    //TODO: maybe only execute this every once in awhile. Every DSP tick is pretty often.
    if (gStartTime) {
        UInt64 nsTime = CAHostTimeBase::ConvertToNanos(ts->mHostTime);
        if ((nsTime - gStartTime) / nsPerTotalBars != totalBarsCount) {
            totalBarsCount++;
            NSLog(@"bar: %d", totalBarsCount);
        }

        updateSequencer(nsTime, totalBarsCount);
        
        if (delegateNs && (nsTime - gStartTime) / delegateNs != delegateCount) {
            delegateCount++;
            [delegate performSelectorOnMainThread:@selector(intervalDidPass) withObject:nil waitUntilDone:NO];
        }
        
    }
}

@implementation Sequencer

+(void)startTiming
{
    [Sequencer startTimingWithBpm:kDefaultBpm];
}

+(void)startTimingWithBpm:(NSInteger)bpm
{
    gStartTime = CAHostTimeBase::GetCurrentTimeInNanos();
    gBpm = bpm;
    nsPerTotalBars = kNumBars * kBeatsPerBar * 60 * 1e9 / gBpm;
    NSLog(@"nsPerTotalBars %llu", nsPerTotalBars);
    gLoAddress = lo_address_new(NULL, PD_PORT_RX);
    gSequence.mode = kSeqModeFreeForm;
    gSequence.curEle = gSequence.list.begin();
}

+(void)sendMsg:(lo_message)msg withPath:(const char *)path
{
    if (lo_pattern_match(path, "/inst/*/*/mode/free-form")) {
        NSLog(@"Changing mode to free-form");
        gSequence.mode = kSeqModeFreeForm;
    } else if (lo_pattern_match(path, "/inst/*/*/mode/sequence")) {
        NSLog(@"Changing mode to sequence");
        gSequence.mode = kSeqModeSequence;
    } else if (lo_pattern_match(path, "/inst/*/*/command/clear")) {
        gSequence.list.clear();
        gSequence.curEle = gSequence.list.begin();
    } else if (lo_pattern_match(path, "/inst/*/*/play")) {
        // Add to the sequence list for this instrument
        pthread_mutex_lock(&seqMutex);
        if (gSequence.mode == kSeqModeSequence) {
//            UInt64 ts = getRelativeTimestamp(CAHostTimeBase::GetCurrentTimeInNanos());
            OscMsgListItr inserted = gSequence.list.insert(gSequence.curEle, OSCMsg(msg,path,CAHostTimeBase::GetCurrentTimeInNanos()+nsPerTotalBars));
            if (gSequence.curEle == gSequence.list.end()) gSequence.curEle = inserted;
        }
        // Either mode, send immediately
        lo_send_message(gLoAddress, path, msg);            

        pthread_mutex_unlock(&seqMutex);       
    }
}

+(void)setDelegate:(id)d withInterval:(double)seconds
{
    delegate = d;
    delegateNs = seconds * 1e9;
    delegateCount = 0;
}

@end    



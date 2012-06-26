/*
 *  pd_main.c
 *  Pd-commandline
 *
 *  Created by Bryan Summersett on 11/5/09.
 *  Copyright 2009 NatIanBryan. All rights reserved.
 *
 */

#include "PdLib.h"
#include "s_main.h"
#include <unistd.h>
#include <libgen.h>
#include <assert.h>
#include <pthread.h>

#ifdef __cplusplus
extern "C" {
#endif
    
static void *PdLibMainThread(void*_) {
    // recursively sets up all the symbols for Pd
    pd_init();    
    
    // tries to open audio
    sysAudioOpen((AudioCallbackFn*) sched_audio_callbackfn);
    
    return NULL;
}
    
static OSStatus sys_open_file(const char *dirname, const char *filename)
{
    assert(sysAudioIsInitialized());
    
    char dirbuf[MAXPDSTRING], *nameptr;
    int fd = open_via_path(dirname, filename, "", dirbuf, &nameptr, MAXPDSTRING, 0);
    if (fd < 0) {
        error("%s: can't open", filename);
        return kPdLibErrFileNotFound;
    } else {
        close(fd);
        glob_evalfile(0, gensym(nameptr), gensym(dirbuf));
        return noErr;
    }
}
    
#ifdef __cplusplus
}
#endif

static const char *errMessages[] = {
    "PdLib has not yet been initialized",
    "Pdlib has already been initialized",
    "Pdlib had an error with Core Audio",
    "Pdlib couldn't find a file",
    "Pdlib couldn't parse a file",
    "Pdlib encountered an unknown error"
};

const char *PdLibErrToString(OSStatus err) {
    return errMessages[((UInt32)err - (UInt32)kPdLibErrNotInitialized)];
}

OSStatus PdLibInitialize(UInt32 inPdLibArgFlags) 
{
    sys_lock();
    if (sysAudioIsInitialized()) {
        sys_unlock();
        return kPdLibErrAlreadyInitialized;
    }
    sys_unlock();
    
    gPdLibFlags = inPdLibArgFlags;

    // Create the thread using POSIX routines.
    pthread_attr_t  attr;
    pthread_t       posixThreadID;
    int             returnVal;
    
    returnVal = pthread_attr_init(&attr);
    assert(!returnVal);
    returnVal = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    assert(!returnVal);
    
    int threadError = pthread_create(&posixThreadID, &attr, &PdLibMainThread, NULL);
    
    returnVal = pthread_attr_destroy(&attr);
    assert(!returnVal);
    if (threadError != 0) {
        return kPdLibErrUnknown;
    }
    return noErr;
}

OSStatus PdLibDestruct(void) {
    sys_lock();
    OSStatus err = sysAudioClose();
    sys_unlock();
    return err;
}

OSStatus PdLibOpenFile(const char *inFileName) 
{
    sys_lock();    
    if (!sysAudioIsInitialized()) {
        error("system not initialized");
        sys_unlock();
        return kPdLibErrNotInitialized;
    }
    OSStatus err = sys_open_file(dirname((char*)inFileName), basename((char*)inFileName));
    
    sys_unlock();
    return err;
}
                         
OSStatus PdLibOpenExtern(const char *inExternFileName) 
{
    sys_lock();
    if (!sysAudioIsInitialized()) {
        error("system not initialized");
        sys_unlock();
        return kPdLibErrNotInitialized;
    }
    
    OSStatus returnVal;
    if (!sys_load_lib(NULL, (char*)inExternFileName)) {
        error("%s: can't load library", inExternFileName);
        returnVal = kPdLibErrFileParse;
    } else {
        returnVal = noErr;
    }      
    sys_unlock();
    return returnVal;
} 
                     
OSStatus PdLibSendMessage(const char *inMessage) {
    sys_lock();
    if (!sysAudioIsInitialized()) {
        error("system not initialized");
        sys_unlock();
        return kPdLibErrNotInitialized;
    }
    
    t_binbuf *b = binbuf_new();
    binbuf_text(b, (char*)inMessage, sizeof(inMessage));
    binbuf_eval(b, 0, 0, 0);
    binbuf_free(b);
    
    sys_unlock();
    return noErr;
}


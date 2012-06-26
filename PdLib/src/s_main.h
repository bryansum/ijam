/*
 *  s_main.h
 *  PdLib
 *
 *  Created by Bryan Summersett on 11/21/09.
 *  Copyright 2009 NatIanBryan. All rights reserved.
 *
 */

#import "AudioOutput.h"

int sys_main(const char *libdir, 
             const char *externs, 
             const char *openfiles,
             const char *searchpath,
             int soundRate,
             int blockSize,
             int nOutChannels,
             AudioCallbackFn callback);

int openit(const char *dirname, const char *filename);

void sys_send_msg(const char *msg);

void sys_exit(void);

// global lock for PD
void sys_lock(void);
void sys_unlock(void);

extern int sys_hasstarted;

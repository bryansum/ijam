//
//  PdController.m
//  PdLib
//
//  Created by Bryan Summersett on 11/21/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import "PdController.h"
#import "s_main.h"
#import <unistd.h>
#import <errno.h>
#import <stdlib.h>
#import <sys/socket.h>
#import <netdb.h>

static PdController *sharedSingleton = nil;

@implementation PdController

@synthesize externs, openfiles, libdir, soundRate, blockSize, nOutChannels, callbackFn;

+ (PdController*)sharedController
{
    if (sharedSingleton == nil) {
        sharedSingleton = [[super allocWithZone:NULL] init];
    }
    return sharedSingleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedController] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark public methods

-(int)openFile:(NSString*)path
{
    if (![pdThread isExecuting]) {
       NSLog(@"PD is not currently running");
       return -1; 
    }

    NSArray *components = [path componentsSeparatedByString: @"/"];
    NSString *filename = [components lastObject];
    NSMutableArray *baseComponents = [NSMutableArray arrayWithArray:components];
    [baseComponents removeLastObject];
    NSString *dirname = [baseComponents componentsJoinedByString:@"/"];
    
    // obtain system-wide mutex so our DSP callbacks don't butt heads. 
    // See AudioOutput.c for the sister mutex.
    sys_lock();
    int r_value = openit([dirname cStringUsingEncoding:NSISOLatin1StringEncoding],
                     [filename cStringUsingEncoding:NSISOLatin1StringEncoding]);
    sys_unlock();
    return r_value;
}

-(void)pdThreadMain
{    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (!libdir) {
        NSLog(@"PdLib: libdir must be specified");
        return;
    }
    if (!soundRate || !blockSize || !(blockSize % 64 == 0) || !nOutChannels) {
        NSLog(@"pd audio settings (soundRate, blockSize, nOutChannels) must be specified.");
    }
    
    // shouldn't ever exit unless we explicitly call stop()
    sys_main([libdir cStringUsingEncoding:NSISOLatin1StringEncoding],
             [[externs componentsJoinedByString:@":"] cStringUsingEncoding:NSISOLatin1StringEncoding],
             [[openfiles componentsJoinedByString:@":"] cStringUsingEncoding:NSISOLatin1StringEncoding],
             [libdir cStringUsingEncoding:NSISOLatin1StringEncoding],
             soundRate,
             blockSize,
             nOutChannels,
             callbackFn);
    
    [pool drain];
}

    
-(void)start
{
    @synchronized(self) {
        if (![pdThread isExecuting]) {
            [pdThread start];
        }        
    }
}
    
-(void)stop
{
    @synchronized(self) {
        if ([pdThread isExecuting]) {
            sys_exit(); 
        }        
    }
}

-(void)restart
{
    @synchronized(self) {
        [self stop];
        
        // TODO: May not be necessary
        sleep(1);
        
        [self start];
    }
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        pdThread = [[NSThread alloc] initWithTarget:self 
                                           selector:@selector(pdThreadMain)
                                             object:nil];
        externs = [[NSArray alloc] init];
        openfiles = [[NSArray alloc] init];
        libdir = NULL;
        soundRate = 11025; //22050;
        blockSize = 128; // 256
        nOutChannels = 2;
        callbackFn = NULL;
    }
    
    return self;
}

- (void) dealloc
{
    [self stop];
    [pdThread release];
    [externs release];
    [openfiles release];
    [libdir release];
    [super dealloc];
}


@end

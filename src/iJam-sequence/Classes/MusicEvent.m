//
//  MusicEvent.m
//  iJam-sequence
//
//  Created by Bryan Summersett on 10/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MusicEvent.h"


@implementation MusicEvent

@synthesize instrument;
@synthesize type;
@synthesize volume;

-(NSString *) description
{
    return [NSString stringWithFormat:@"instrument: %lu, type: %@, volume: %f", 
            (unsigned long) self.instrument, 
            (self.type == START ? @"START" : @"STOP"),
            self.volume];
}
@end

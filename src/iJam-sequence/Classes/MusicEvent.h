//
//  MusicEvent.h
//  iJam-sequence
//
//  Created by Bryan Summersett on 10/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum EventType_e {
    START,
    STOP
} EventType;

@interface MusicEvent : NSObject
{
    @private
    NSUInteger instrument;
	float volume;
    EventType type;
}

@property (nonatomic, assign) EventType type;
@property (nonatomic, assign) NSUInteger instrument;
@property (nonatomic, assign) float volume;
@end

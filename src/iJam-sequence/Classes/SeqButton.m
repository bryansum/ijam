//
//  SeqButton.m
//  iJam-sequence
//
//  Created by Bryan Summersett on 11/4/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import "SeqButton.h"

@implementation SeqButton

@synthesize state;

- (id) init
{
    wasPressed = NO;
    state = OFF;
    return [self initWithFile:@"seq-button-up.png"];
}

-(void)press
{
    state = PRESSED;
    [self setTexture:[[TextureMgr sharedTextureMgr] addImage:@"seq-button-pressed.png"]];
}

-(void)unpress
{
    state = OFF;
    [self setTexture:[[TextureMgr sharedTextureMgr] addImage:@"seq-button-up.png"]];  
}

-(void)pressStop
{
    if (wasPressed == NO) {
        state = ON;
        [self setTexture:[[TextureMgr sharedTextureMgr] addImage:@"seq-button-down.png"]];        
    } else {
        state = OFF;
        [self setTexture:[[TextureMgr sharedTextureMgr] addImage:@"seq-button-up.png"]];                
    }
    wasPressed = !wasPressed;
}

@end

//
//  SeqButton.h
//  iJam-sequence
//
//  Created by Bryan Summersett on 11/4/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum SeqButtonState_e {
    ON,
    OFF,
    PRESSED
} SeqButtonState;

@interface SeqButton : Sprite {
@private
    SeqButtonState state; // Will be in one of three states at any given time. 
                          // Change them by calling 'press' and 'pressStop'
    BOOL wasPressed;
}

-(void)press;
-(void)unpress;
-(void)pressStop;

@property (readonly, assign, nonatomic) SeqButtonState state;

@end

//
//  AVController.h
//  iJam
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVController : NSObject {
    
    NSMutableDictionary      *soundPlayers;
}

- (IBAction)kickButtonPressed:(UIButton *)sender;
- (IBAction)snareButtonPressed:(UIButton *)sender;
- (IBAction)crashButtonPressed:(UIButton *)sender;
- (IBAction)hiHatButtonPressed:(UIButton *)sender;
- (IBAction)lowTomButtonPressed:(UIButton *)sender;
- (IBAction)midTomButtonPressed:(UIButton *)sender;
- (IBAction)highTomButtonPressed:(UIButton *)sender;
- (IBAction)rideButtonPressed:(UIButton *)sender;
- (IBAction)rideBellButtonPressed:(UIButton *)sender;
- (IBAction)cowbellButtonPressed:(UIButton *)sender;

@end

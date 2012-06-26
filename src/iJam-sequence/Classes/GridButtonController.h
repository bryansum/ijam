//
//  GridButtonController.h
//  iJam-sequence
//
//  Created by Bryan Summersett on 10/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MusicEvent.h"

@class Sequencer;
@class iJamViewController;

@interface GridButtonController : NSObject  {
@private
    iJamViewController *viewController;
}

// reads in the UIButtons' tag number and changes its state. This 
// then creates a music event and sends it to the sequencer.
-(IBAction)toggleEvent:(UIButton *)sender;

@property (nonatomic, retain) IBOutlet iJamViewController *viewController;


@end

//
//  FreeFormController.h
//  iJam-sequence
//
//  Created by Kevin Wicks on 11/1/09.
//  Copyright 2009 University of Michigan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class iJamViewController;
@class AVController;

@interface FreeFormController : NSObject {
	iJamViewController *viewController;
}
-(IBAction)pressKickDrum:(id)sender;
-(IBAction)pressSnareDrum:(id)sender;
-(IBAction)pressHiHat:(id)sender;
-(IBAction)pressCrash:(id)sender;
@property (nonatomic, retain) IBOutlet iJamViewController *viewController;
@end

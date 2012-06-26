//
//  mainViewController.h
//  fuckkk22
//
//  Created by Nathaniel Christman on 12/4/09.
//  Copyright 2009 University of Michigan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fuckkk22AppDelegate.h"
#import "PdController.h"

@class drumViewController;
@class sessionViewController;
@class menuViewController;
@class optionViewController;
@class hostViewController;
@class instrumentViewController;
@class bassViewController;

@interface mainViewController : UIViewController {

	PdController    *pdController;

	sessionViewController *sessionView;
	menuViewController *menuView;
	bassViewController *bassView;
	hostViewController *hostView;
	instrumentViewController *instrumentView;
	optionViewController *optionView;
	drumViewController *drumView;

	
	UIViewController *currentView;
	
}

-(void)loadMenuView;
-(void)loadHostView;
-(void)loadSessionView;
-(void)loadOptionView;
-(void)loadInstrumentView;
-(void)loadDrumView;
-(void)loadBassView;

-(void)loadMenu;
-(void)loadHost;
-(void)loadSessions;
-(void)loadOptions;
-(void)loadInstruments;
-(void)loadDrums;
-(void)loadBass;

+(NSTimer *)timer;


@end

//
//  drumViewController.h
//  fuckkk22
//
//  Created by Nathaniel Christman on 11/30/09.
//  Copyright 2009 University of Michigan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mainViewController.h"
#import "lo.h"


@interface drumViewController : mainViewController {
	UIButton *snare;
	UIButton *hihat;
	UIButton *clap;
	UIButton *bass;

	UIButton *record;
	UIButton *back;
	UIImageView *grid;
	UIImageView *measure;
	UIButton *clear;
	NSDate *record_start;
	NSMutableArray *grid_images;
//	NSTimer *timer;
	
	lo_address address;
			
}

@property(nonatomic, retain) NSMutableArray *grid_images;
//@property(nonatomic, retain) NSTimer *timer;

-(void)touchDrum:(UIControl *)sender;
-(void)moveDrum:(UIControl *)sender withEvent:(UIEvent *)ev;
-(void)editMode;
-(void)recordMode;
-(void)update_grid:(NSTimeInterval)time :(int)value;
-(void)clear_grid;
-(void)update_measure;

@end

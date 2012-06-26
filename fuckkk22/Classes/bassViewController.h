//
//  bassViewController.h
//  fuckkk22
//
//  Created by Nathaniel Christman on 12/4/09.
//  Copyright 2009 University of Michigan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mainViewController.h"


@interface bassViewController : mainViewController {
	UIButton *record;
	UIButton *back;
	UIImageView *grid;
	NSDate *record_start;
	NSMutableArray *grid_images;
	UIImageView *measure;
	//NSTimer *timer;

	
	UIButton *EString;
	UIButton *AString;
	UIButton *DString;
	UIButton *GString;

}

@property(nonatomic, retain) NSMutableArray *grid_images;
//@property(nonatomic, retain) NSTimer *timer;


-(void)recordMode;
-(void)update_grid:(NSTimeInterval)time :(CGFloat)value;
-(void)clear_grid;


-(void)update_measure:(NSTimer *)timer;
-(void)touchString:(UIControl *)sender withEvent:(UIEvent *)ev;


@end

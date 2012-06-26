//
//  iJamViewController.h
//  iJam
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVController;
@class GridButtonController;
@class FreeFormController;

@class Scene;

@class Sequencer;
@class AVController;

@interface iJamViewController : UIViewController <UIAccelerometerDelegate> {
 @private
	
	Sequencer *sequencer;
    AVController *avController;
   
	//Depricated
	GridButtonController *gridButtonController;
	FreeFormController *freeFormController;
	
	UIScrollView *scrollView;
	
	
    UILabel *bpmLabel;
    UISlider *bpmSlider;    
    
    Scene *freeFormScene;
    Scene *sequenceScene;
    Scene *currentScene;
	
    // Accelerometer data
	double oldZ;
	double newZ;
	double oldY;
	double newY;
	double oldX;
	double newX;
	double accelerometerMagnitude;	
	UIAccelerometer *accelerometer;    
}

// Private loading methods
- (void)loadScrollViews;
- (void)loadAccelerometer;

-(void)swapScene;

// BPM
-(void)setBpmText:(float)in_bpm;
-(void)bpmDidChange:(id)sender;

@property (nonatomic, readonly) Sequencer *sequencer;
@property (nonatomic, readonly) AVController *avController;

@property (nonatomic, retain) IBOutlet GridButtonController *gridButtonController;
@property (nonatomic, retain) IBOutlet FreeFormController *freeFormController;
@property (nonatomic, retain) IBOutlet UILabel *bpmLabel;
@property (nonatomic, retain) IBOutlet UISlider *bpmSlider;    

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) IBOutlet Scene *currentScene;
@property (nonatomic, retain) IBOutlet Scene *freeFormScene;
@property (nonatomic, retain) IBOutlet Scene *sequenceScene;

@property (nonatomic, retain) UIAccelerometer *accelerometer;
@property (assign) double accelerometerMagnitude;

@end


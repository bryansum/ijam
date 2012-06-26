//
//  FreeFormController.m
//  iJam-sequence
//
//  Created by Kevin Wicks on 11/1/09.
//  Copyright 2009 University of Michigan. All rights reserved.
//

#import "FreeFormController.h"
#import "iJamViewController.h"
#import "AVController.h"

@implementation FreeFormController
@synthesize viewController;


-(IBAction)pressKickDrum:(id)sender{
	double volume = viewController.accelerometerMagnitude;
	[viewController.avController playInstrument:@"kick" withVolume:volume];
	
}

-(IBAction)pressSnareDrum:(id)sender{
	double volume = viewController.accelerometerMagnitude;
	[viewController.avController playInstrument:@"snare" withVolume:volume];
	
}

-(IBAction)pressHiHat:(id)sender{
	double volume = viewController.accelerometerMagnitude;
	[viewController.avController playInstrument:@"hi-hat" withVolume:volume];
	
}

-(IBAction)pressCrash:(id)sender{
	double volume = viewController.accelerometerMagnitude;
	[viewController.avController playInstrument:@"crash" withVolume:volume];
	
}

@end

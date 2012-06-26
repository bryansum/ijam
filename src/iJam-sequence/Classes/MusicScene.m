//
//  MusicScene.m
//  iJam-sequence
//
//  Created by Bryan Summersett on 11/2/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import "MusicScene.h"


@implementation MusicScene

@synthesize viewController;

+(id) scene
{
    return [MusicScene sceneFromLayer:[MusicScene node]];
}

+(id) sceneFromLayer:(Layer *)inNode
{
	// 'scene' is an autorelease object.
	Scene *scene = [Scene node];
	
	// add layer as a child to scene
	[scene addChild: inNode];
	
	// return the scene
	return scene;    
}

@end

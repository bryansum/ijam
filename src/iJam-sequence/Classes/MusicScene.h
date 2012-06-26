//
//  MusicScene.h
//  iJam-sequence
//
//  Created by Bryan Summersett on 11/2/09.
//  Copyright 2009 NatIanBryan. All rights reserved.
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>
#import "iJamViewController.h"

@interface MusicScene : Layer {
    iJamViewController *viewController;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
+(id) sceneFromLayer:(Layer *)inNode;

@property (nonatomic, retain) IBOutlet iJamViewController *viewController;

@end

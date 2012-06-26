//
//  iJamAppDelegate.h
//  iJam
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class iJamViewController;

@interface iJamAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iJamViewController *viewController;
}

- (void)cocos2dinit;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iJamViewController *viewController;

@end


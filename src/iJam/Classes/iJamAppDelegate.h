//
//  iJamAppDelegate.h
//  iJam
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iJamViewController;

@interface iJamAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iJamViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iJamViewController *viewController;

@end


//
//  PdLibTestAppDelegate.h
//  PdLibTest
//
//  Created by Bryan Summersett on 11/9/09.
//  Copyright NatIanBryan 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PdLibTestViewController;

@interface PdLibTestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PdLibTestViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PdLibTestViewController *viewController;

@end


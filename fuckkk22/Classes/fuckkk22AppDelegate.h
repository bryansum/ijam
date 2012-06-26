//
//  fuckkk22AppDelegate.h
//  fuckkk22
//
//  Created by Nathaniel Christman on 11/30/09.
//  Copyright University of Michigan 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class mainViewController;

@interface fuckkk22AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	//UITabBarController *rootController;
	//UIViewController *rootView;
	mainViewController *mainView;
	//drumViewController *drumView;
	//menuViewController *mainMenu;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
//@property (nonatomic, retain) IBOutlet UITabBarController *rootController;
//@property (nonatomic, retain) IBOutlet UIViewController *rootView;
//@property (nonatomic, retain) IBOutlet drumViewController *drumView;

-(void)loadView:(int)view;
@end




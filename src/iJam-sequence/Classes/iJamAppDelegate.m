//
//  iJamAppDelegate.m
//  iJam
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "iJamAppDelegate.h"
#import "iJamViewController.h"
#import "FreeFormScene.h"
#import "SequenceScene.h"

@implementation iJamAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	// Override point for customization after app launch    
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
    [window addSubview:viewController.view];
    
    [[Director sharedDirector] attachInView:viewController.view withFrame:CGRectMake(0, 0, 480, 320)];
    //[sequenceDirector attachInView:viewController.sequenceView withFrame:CGRectMake(0, 0, 480, 320)];
    
    [window makeKeyAndVisible];   
    
    FreeFormScene *freeFormScene = [FreeFormScene node];
    freeFormScene.viewController = self.viewController;
    
    SequenceScene *sequenceScene = [SequenceScene node];
    sequenceScene.viewController = self.viewController;
    
    viewController.currentScene = viewController.freeFormScene = [MusicScene sceneFromLayer:freeFormScene];
    viewController.sequenceScene = [MusicScene sceneFromLayer:sequenceScene];
    
    [[Director sharedDirector] runWithScene: viewController.freeFormScene];
}

- (void)dealloc {
    [viewController release];
    [[Director sharedDirector] release];
    [window release];
    [super dealloc];
}

- (void)cocos2dinit
{
    // Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use Threaded director
	if( ! [Director setDirectorType:CCDirectorTypeDisplayLink] )
		[Director setDirectorType:CCDirectorTypeDefault];
	
	// Use RGBA_8888 buffers
	// Default is: RGB_565 buffers
	[[Director sharedDirector] setPixelFormat:kPixelFormatRGBA8888];
    
	// Create a depth buffer of 16 bits
	// Enable it if you are going to use 3D transitions or 3d objects
    //	[[Director sharedDirector] setDepthBufferFormat:kDepthBuffer16];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// before creating any layer, set the landscape mode
//	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapelLeft];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	//[[Director sharedDirector] setDisplayFPS:YES];	

}

// Cocos2d methods
- (void)applicationWillResignActive:(UIApplication *)application {
	[[Director sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[Director sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeUnusedTextures];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[Director sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
    [[Director sharedDirector] setNextDeltaTimeZero:YES];
}

@end

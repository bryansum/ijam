
// Import the interfaces
#import "AVController.h"
#import "FreeFormScene.h"
#import "IntervalAction.h"
#import "iJamViewController.h"

enum {
	kCyanSprite = 1,
	kYellowSprite = 2,
	kPurpleSprite = 3,
	kRedSprite = 4,
	kGreenSprite = 5,
	kEditSprite = 6,
    kSwapSprite = 7
};

int edit_mode = 0;

NSString *instruments[] = { @"snare", @"hi-hat", @"high-tom", @"low-tom", @"kick" };

@implementation FreeFormScene

static CGRect rectForSprite(Sprite *sprite) {
    float x = [sprite position].x;
    float y = [sprite position].y;
    float h = [sprite contentSize].height;
    float w = [sprite contentSize].width;
    CGRect aRect = CGRectMake(x,y,w,h);
    return aRect;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		// create and initialize a Label
		self.isTouchEnabled = YES;
		
		//
		// Sprite
		//
		Sprite *background = [Sprite spriteWithFile:@"background.png"];		
		background.position = ccp(240,160);
        [self addChild:background z:0];
		
		Sprite *yellow = [Sprite spriteWithFile:@"gray-120.png"];
		[yellow setColor:ccc3(255,255,0)]; 
		yellow.position = ccp( 370, 250);
		[self addChild:yellow z:4 tag:kYellowSprite];
		//[yellow runAction:[ScaleBy actionWithDuration:.5 scale:1.3]];
		
		Sprite *purple = [Sprite spriteWithFile:@"gray-140.png"];
		[purple setColor:ccc3(255,0,255)];
		purple.position = ccp(230, 250);
		[self addChild:purple z:3 tag:kPurpleSprite];
		//[purple runAction:[ScaleBy actionWithDuration:.5 scale:1.5]];
		
		Sprite *red = [Sprite spriteWithFile:@"gray-160.png"];
		[red setColor:ccc3(255,0,0)];
		red.position = ccp(340, 100);
		[self addChild:red z:2 tag:kRedSprite];
		//[red runAction:[ScaleBy actionWithDuration:.5 scale:1.7]];
		
		Sprite *cyan = [Sprite spriteWithFile:@"gray-100.png"];
		[cyan setColor:ccc3(0,255,255)];
		cyan.position = ccp( 100, 250);
		[self addChild:cyan z:5 tag:kCyanSprite];
		//[cyan runAction:[ScaleBy actionWithDuration:.5 scale:1.1]];
		
		Sprite *green = [Sprite spriteWithFile:@"gray-180.png"];
		[green setColor:ccc3(0,255,0)];
		green.position = ccp( 140, 100);
		[self addChild:green z:1 tag:kGreenSprite];
		//[cyan runAction:[ScaleBy actionWithDuration:.5 scale:1.1]];
		

		// Edit sprite
		Sprite *edit = [Sprite spriteWithFile:@"pencil.png"];
        edit.position = ccp(455, 15);
		[self addChild:edit z:15 tag:kEditSprite];
		
        // Arrow sprite
		Sprite *arrow = [Sprite spriteWithFile:@"arrow.png"];
        arrow.position = ccp(20, 20);        
		[self addChild:arrow z:20 tag:kSwapSprite];
		
	}
	return self;
}

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
			
	for(UITouch * touch in touches) {

		CGPoint location = [touch locationInView: [touch view]];
		
		CGPoint convertedPoint = [[Director sharedDirector] convertToGL:location];
		Sprite *sprite;

		for(int i=1; i<=5; i++){
			sprite = (Sprite *)[self getChildByTag:i];
			CGRect spriteRect = CGRectMake(sprite.position.x-sprite.contentSize.width/2-5,
										   sprite.position.y-sprite.contentSize.height/2-5, 
										   sprite.contentSize.width+10, 
										   sprite.contentSize.height+10);
			
			if(CGRectContainsPoint(spriteRect, convertedPoint)){
				[sprite stopAllActions];
				if(!edit_mode){
					[sprite setOpacityModifyRGB:NO];
					[sprite runAction:[FadeOut actionWithDuration:.05]];
					[sprite runAction:[FadeIn actionWithDuration:.05]];
					
                    NSLog(@"i %d, instru %@",i,instruments[i-1]);
                    double volume = viewController.accelerometerMagnitude;
                    [viewController.avController playInstrument:instruments[i-1] withVolume:volume];
					return kEventHandled;

					
				}
					

			}
		}
		
        sprite = (Sprite*)[self getChildByTag:kEditSprite];
		CGRect spriteRect = CGRectMake(sprite.position.x-10, sprite.position.y-10, 
									   sprite.contentSize.width+20, sprite.contentSize.height+20);
		if(CGRectContainsPoint(spriteRect, convertedPoint)){
			if(edit_mode)
				edit_mode = 0;
			else {
				edit_mode = 1;
			}
			
			for(int i=1; i<=5; i++){
				sprite = (Sprite*)[self getChildByTag:i];
				[sprite setOpacityModifyRGB:NO];
				if(edit_mode)
					[sprite runAction:[FadeTo actionWithDuration:1 opacity:75]];
				else
					[sprite runAction:[FadeTo actionWithDuration:1 opacity:255]];
			}
			
			NSLog(@"edit mode %d", edit_mode);
			return kEventHandled;
		}
        
        sprite = (Sprite*)[self getChildByTag:kSwapSprite];
        if (CGRectContainsPoint(rectForSprite(sprite), convertedPoint)) {
            [viewController swapScene];
        }		
	}
	
	// we ignore the event. Other receivers will receive this event.
	return kEventIgnored;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{	
	
	if(edit_mode){
		if([touches count] == 1){
		
			UITouch *touch = [touches anyObject];
			
			CGPoint location = [touch locationInView: [touch view]];
			CGPoint convertedPoint = [[Director sharedDirector] convertToGL:location];		
			
			CocosNode *sprite;

			for(int i=1; i<=5; i++){
				sprite = [self getChildByTag:i];
				CGRect spriteRect = CGRectMake(sprite.position.x-sprite.contentSize.width/2-5,
											   sprite.position.y-sprite.contentSize.height/2-5, 
											   sprite.contentSize.width+10, 
											   sprite.contentSize.height+10);
				
				if(CGRectContainsPoint(spriteRect, convertedPoint)){
					[sprite stopAllActions];
					sprite.position = convertedPoint;
					break;
					//	return kEventHandled;
				}
			}

		} 
	}	
	return kEventIgnored;
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{				
//	if(!edit_mode && [touches count] == 1){
//		CocosNode *sprite;
//		
//		UITouch *touch = [touches anyObject];
//		
//		CGPoint location = [touch locationInView: [touch view]];
//		CGPoint convertedPoint = [[Director sharedDirector] convertToGL:location];	
//		
//		for(int i=1; i<=5; i++){
//			sprite = [self getChildByTag:i];
//			CGRect spriteRect = 
//				CGRectMake(sprite.position.x-60, sprite.position.y-60, 
//					sprite.contentSize.width+20, sprite.contentSize.height+20);
//			
//			if(CGRectContainsPoint(spriteRect, convertedPoint)){
//				[sprite setOpacity:255];
//				return kEventHandled;
//			}
//		}
//	}
//	
	return kEventHandled;
}

@end


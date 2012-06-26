//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "SequenceScene.h"
#import "MusicEvent.h"
#import "SeqButton.h"

// HelloWorld implementation
@implementation SequenceScene

#define NUM_COLS 8
#define NUM_ROWS 4
#define BUTTON_SIZE 46.0 //px
#define BUTTON_PLUS_GUTTER 
#define START_X 60.0
#define START_Y 34.0
#define xyToArray(x,y) (NUM_COLS*(x)+(y))

Sprite *grid_sprites[32];
BOOL grid_values[32];

enum {
    kSwapSprite
};

// Finds the array value for the given position, or -1 if it couldn't find one.
static int gridArrayValForPosition(CGPoint point, int* outX, int* outY) {
    int x = floor((point.x - 34.5) / 56);
    int y = floor((320.0 - point.y) - 8.5) / 56;
    
    if ((x >= NUM_COLS || x < 0) || (y >= NUM_ROWS || y < 0)) {
        return -1;
    } else {
        *outX = x;
        *outY = y;
        return xyToArray(y,x);
    }
} 

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
				
		self.isTouchEnabled = YES;
		Sprite *background = [Sprite spriteWithFile:@"sequence-bg.png"];		
		background.position = ccp(240,160);
        [self addChild:background z:0];

		for(int i=0; i<NUM_ROWS; i++){			
			for(int j=0; j<NUM_COLS; j++){
				int address = xyToArray(i,j);
				
                // start at 60, 34. Each is 56px down from the last, 56px apart x
                
				grid_sprites[address] = [[SeqButton alloc] init];
				grid_sprites[address].position = ccp(56*j+60, 320-(56*i+34));
				//[grid_sprites[address] setColor:ccc3(rR, rG, rB)];
				[self addChild:grid_sprites[address]];
			}
		}
		
		//sliderCtl = [[UISlider alloc] initWithFrame:CGRectMake(0.0, 280.0,
												//			   120.0, 7.0)];
	///	[sliderCtl addTarget:self action:@selector(sliderAction:)
	//	 forControlEvents:UIControlEventValueChanged];
		//[[Director sharedDirector] attachInView:sliderCtl];
			
        // Arrow sprite
		Sprite *arrow = [Sprite spriteWithFile:@"arrow.png"];
        arrow.position = ccp(20, 20);        
		[self addChild:arrow z:20 tag:kSwapSprite];		
        
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    for(UITouch *touch in touches) {
	
        CGPoint location = [touch locationInView: [touch view]];
        
        CGPoint convertedPoint = [[Director sharedDirector] convertToGL:location];
        Sprite *sprite;
        
        NSLog(@"%f, %f", convertedPoint.x, convertedPoint.y);
        
        sprite = (Sprite*)[self getChildByTag:kSwapSprite];
        if (CGRectContainsPoint(rectForSprite(sprite), convertedPoint)) {
            NSLog(@"Swap scene!");
            [viewController swapScene];
        }    
        
        int x,y;
        int arrayNum = gridArrayValForPosition(convertedPoint,&x,&y);
        
        if (arrayNum == -1) { //error
            NSLog(@"outside the bounds");
            return kEventHandled;            
        } else {
            SeqButton *seqButton = (SeqButton*)grid_sprites[arrayNum];
            
            //NSLog(@"Received event");
            // convert to instrument / period
            MusicEvent *event = [[MusicEvent alloc] init];    
            event.instrument = y;
            
            // set the volume based on the accelerometer magnitude
            event.volume = 1.0;
            event.type = START;
            NSUInteger period = x;
            NSNumber *instNum = [NSNumber numberWithInteger:event.instrument];
            
            if(grid_values[xyToArray(y,x)]) {
                [seqButton unpress];
                //            [sprite press];
                //			[sprite runAction:[EaseIn actionWithAction:[ScaleBy actionWithDuration:.2 scale:.5] rate:3]];
    			[viewController.sequencer removeEventForInstrument:instNum atPeriod:period];
                //	//[sprite runAction:[ScaleBy actionWithDuration:.2 scale:.5]];
    		} else {
                [seqButton press];
                //			[sprite runAction:[EaseIn actionWithAction:[ScaleBy actionWithDuration:.2 scale:2] rate:3]];
                
                [viewController.sequencer setEvent:event atPeriod:period forInstrument:instNum]; 
                //[sprite runAction:[ScaleBy actionWithDuration:.2 scale:2]];
            }
            
            
            // turn on or off 
            grid_values[xyToArray(y,x)] = !grid_values[xyToArray(y,x)];
            
            [event release];
            
            NSLog(@"%d %d", x, y);
        }        
    }
    
	return kEventHandled;
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        
    }
    
    return kEventIgnored;
}

@end

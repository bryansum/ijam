//
// Atlas Demo
// a cocos2d example
// http://www.cocos2d-iphone.org
//

// cocos import
#import "cocos2d.h"

// local import
#import "TileMapTest.h"

static int sceneIdx=-1;
static NSString *transitions[] = {
			@"TileMapTest",
			@"TileMapEditTest",
			@"TMXOrthoTest",
			@"TMXOrthoTest2",
			@"TMXOrthoTest3",
			@"TMXOrthoTest4",
			@"TMXIsoTest",
			@"TMXIsoTest1",
			@"TMXIsoTest2",
			@"TMXUncompressedTest",
			@"TMXHexTest",
			@"TMXReadWriteTest",
			@"TMXTilesetTest",
};

enum {
	kTagTileMap = 1,
};

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(transitions) / sizeof(transitions[0]) );
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(transitions) / sizeof(transitions[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;	
	
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = transitions[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

#pragma mark -
#pragma mark TileDmo

@implementation TileDemo
-(id) init
{
	if( (self=[super init] )) {

		self.isTouchEnabled = YES;

		CGSize s = [[Director sharedDirector] winSize];
			
		Label* label = [Label labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];
		Label* subtitle = [Label labelWithString:[self subtitle] fontName:@"Arial" fontSize:20];
		[self addChild: subtitle z:1];
		[subtitle setPosition: ccp(s.width/2, s.height-85)];
		
		
		MenuItemImage *item1 = [MenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		MenuItemImage *item2 = [MenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		MenuItemImage *item3 = [MenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		Menu *menu = [Menu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:1];	
	}

	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) registerWithTouchDispatcher
{
	[[TouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
	
	touchLocation = [[Director sharedDirector] convertToGL: touchLocation];
	prevLocation = [[Director sharedDirector] convertToGL: prevLocation];
	
	CGPoint diff = ccpSub(touchLocation,prevLocation);
	
	CocosNode *node = [self getChildByTag:kTagTileMap];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, diff)];
}

-(void) restartCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [restartAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [nextAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	Scene *s = [Scene node];
	[s addChild: [backAction() node]];
	[[Director sharedDirector] replaceScene: s];
}

-(NSString*) title
{
	return @"No title";
}
-(NSString*) subtitle
{
	return @"drag the screen";
}
@end


#pragma mark -
#pragma mark TileMapTest

@implementation TileMapTest
-(id) init
{
	if( (self=[super init]) ) {
	
		
		TileMapAtlas *map = [TileMapAtlas tileMapAtlasWithTileFile:@"tiles.png" mapFile:@"levelmap.tga" tileWidth:16 tileHeight:16];
		// Convert it to "alias" (GL_LINEAR filtering)
		[map.texture setAliasTexParameters];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		// If you are not going to use the Map, you can free it now
		// NEW since v0.7
		[map releaseMap];
		
		[self addChild:map z:0 tag:kTagTileMap];
		
		map.anchorPoint = ccp(0, 0.5f);
		
//		id s = [ScaleBy actionWithDuration:4 scale:0.8f];
//		id scaleBack = [s reverse];
//		
//		id seq = [Sequence actions: s,
//								scaleBack,
//								nil];
//		
//		[map runAction:[RepeatForever actionWithAction:seq]];
	}
	
	return self;
}

-(NSString *) title
{
	return @"TileMapAtlas";
}

@end

#pragma mark -
#pragma mark TileMapEditTest

@implementation TileMapEditTest
-(id) init
{
	if( (self=[super init]) ) {
		
		
		TileMapAtlas *map = [TileMapAtlas tileMapAtlasWithTileFile:@"tiles.png" mapFile:@"levelmap.tga" tileWidth:16 tileHeight:16];

		// Create an Aliased Atlas
		[map.texture setAliasTexParameters];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		// If you are not going to use the Map, you can free it now
		// [tilemap releaseMap];
		// And if you are going to use, it you can access the data with:
		[self schedule:@selector(updateMap:) interval:0.2f];
		
		[self addChild:map z:0 tag:kTagTileMap];
		
		map.anchorPoint = ccp(0, 0);
		map.position = ccp(-20,-200);
	}	
	return self;
}

-(void) updateMap:(ccTime) dt
{
	// IMPORTANT
	//   The only limitation is that you cannot change an empty, or assign an empty tile to a tile
	//   The value 0 not rendered so don't assign or change a tile with value 0

	TileMapAtlas *tilemap = (TileMapAtlas*) [self getChildByTag:kTagTileMap];
	
	//
	// For example you can iterate over all the tiles
	// using this code, but try to avoid the iteration
	// over all your tiles in every frame. It's very expensive
	//	for(int x=0; x < tilemap.tgaInfo->width; x++) {
	//		for(int y=0; y < tilemap.tgaInfo->height; y++) {
	//			ccColor3B c =[tilemap tileAt:ccg(x,y)];
	//			if( c.r != 0 ) {
	//				NSLog(@"%d,%d = %d", x,y,c.r);
	//			}
	//		}
	//	}
	
	// NEW since v0.7
	ccColor3B c =[tilemap tileAt:ccg(13,21)];		
	c.r++;
	c.r %= 50;
	if( c.r==0)
		c.r=1;
	
	// NEW since v0.7
	[tilemap setTile:c at:ccg(13,21)];			
	
}

-(NSString *) title
{
	return @"Editable TileMapAtlas";
}
@end

#pragma mark -
#pragma mark TMXOrthoTest

@implementation TMXOrthoTest

-(id) init
{
	if( (self=[super init]) ) {
		
		//
		// Test orthogonal with 3d camera and anti-alias textures
		//
		// it should not flicker. No artifacts should appear
		//
		ColorLayer *color = [ColorLayer layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];

		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"orthogonal-test2.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		for( AtlasSpriteManager* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}
		float x, y, z;
		[[map camera] eyeX:&x eyeY:&y eyeZ:&z];
		[[map camera] setEyeX:x-200 eyeY:y eyeZ:z+300];		
	}	
	return self;
}

-(void) onEnter
{
	[super onEnter];
	[[Director sharedDirector] setProjection:CCDirectorProjection3D];
}

-(void) onExit
{
	[[Director sharedDirector] setProjection:CCDirectorProjection2D];
	[super onExit];
}


-(NSString *) title
{
	return @"TMX Orthogonal test";
}
@end

#pragma mark -
#pragma mark TMXOrthoTest2

@implementation TMXOrthoTest2
-(id) init
{
	if( (self=[super init]) ) {		
		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"orthogonal-test1.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];

		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		for( AtlasSpriteManager* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}

		[map runAction:[ScaleBy actionWithDuration:2 scale:0.5f]];
		
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Ortho test2";
}
@end

#pragma mark -
#pragma mark TMXOrthoTest3

@implementation TMXOrthoTest3
-(id) init
{
	if( (self=[super init]) ) {		
		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"orthogonal-test3.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		for( AtlasSpriteManager* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}
		
		[map setScale:0.2f];
		[map setAnchorPoint:ccp(0.5f, 0.5f)];
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX anchorPoint test";
}
@end

#pragma mark -
#pragma mark TMXOrthoTest4

@implementation TMXOrthoTest4
-(id) init
{
	if( (self=[super init]) ) {		
		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"orthogonal-test4.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s1 = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s1.width,s1.height);
		
		for( AtlasSpriteManager* child in [map children] ) {
			[[child texture] setAntiAliasTexParameters];
		}
		
		[map setAnchorPoint:ccp(0, 0)];

		TMXLayer *layer = [map layerNamed:@"Layer 0"];
		CGSize s = [layer layerSize];
		
		AtlasSprite *sprite;
		sprite = [layer tileAt:ccp(0,0)];
		[sprite setScale:2];
		sprite = [layer tileAt:ccp(s.width-1,0)];
		[sprite setScale:2];
		sprite = [layer tileAt:ccp(0,s.height-1)];
		[sprite setScale:2];
		sprite = [layer tileAt:ccp(s.width-1,s.height-1)];
		[sprite setScale:2];
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX width/height test";
}
@end



#pragma mark -
#pragma mark TMXIsoTest

@implementation TMXIsoTest
-(id) init
{
	if( (self=[super init]) ) {
		ColorLayer *color = [ColorLayer layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];
		
		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"iso-test.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];		
		
		// move map to the center of the screen
		CGSize ms = [map mapSize];
		CGSize ts = [map tileSize];
		[map runAction:[MoveTo actionWithDuration:1.0f position:ccp( -ms.width * ts.width/2, -ms.height * ts.height/2 ) ]];
		
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Isometric test 0";
}
@end

#pragma mark -
#pragma mark TMXIsoTest1

@implementation TMXIsoTest1
-(id) init
{
	if( (self=[super init]) ) {
		ColorLayer *color = [ColorLayer layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];
		
		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"iso-test1.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		[map setAnchorPoint:ccp(0.5f, 0.5f)];
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Isometric test + anchorPoint";
}
@end

#pragma mark -
#pragma mark TMXIsoTest2

@implementation TMXIsoTest2
-(id) init
{
	if( (self=[super init]) ) {
		ColorLayer *color = [ColorLayer layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];
		
		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"iso-test2.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];	
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		// move map to the center of the screen
		CGSize ms = [map mapSize];
		CGSize ts = [map tileSize];
		[map runAction:[MoveTo actionWithDuration:1.0f position:ccp( -ms.width * ts.width/2, -ms.height * ts.height/2 ) ]];
		
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Isometric test 2";
}
@end

@implementation TMXUncompressedTest
-(id) init
{
	if( (self=[super init]) ) {
		ColorLayer *color = [ColorLayer layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];
		
		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"iso-test2-uncompressed.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];	
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		// move map to the center of the screen
		CGSize ms = [map mapSize];
		CGSize ts = [map tileSize];
		[map runAction:[MoveTo actionWithDuration:1.0f position:ccp( -ms.width * ts.width/2, -ms.height * ts.height/2 ) ]];
		
		// testing release map
		for( TMXLayer *layer in [map children])
			[layer releaseMap];
		
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Uncompressed test";
}
@end


#pragma mark -
#pragma mark TMXHexTest

@implementation TMXHexTest
-(id) init
{
	if( (self=[super init]) ) {
		ColorLayer *color = [ColorLayer layerWithColor:ccc4(64,64,64,255)];
		[self addChild:color z:-1];
		
		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"hexa-test.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Hex test";
}
@end

#pragma mark -
#pragma mark TMXReadWriteTest

@implementation TMXReadWriteTest
-(id) init
{
	if( (self=[super init]) ) {

		gid = 0;
		
		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"orthogonal-test2.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);

		
		TMXLayer *layer = [map layerNamed:@"Layer 0"];
		[layer.texture setAntiAliasTexParameters];

		AtlasSprite *tile0 = [layer tileAt:ccp(1,63)];
		AtlasSprite *tile1 = [layer tileAt:ccp(2,63)];
		AtlasSprite *tile2 = [layer tileAt:ccp(1,62)];
		AtlasSprite *tile3 = [layer tileAt:ccp(2,62)];
		tile0.anchorPoint = ccp(0.5f, 0.5f);
		tile1.anchorPoint = ccp(0.5f, 0.5f);
		tile2.anchorPoint = ccp(0.5f, 0.5f);
		tile3.anchorPoint = ccp(0.5f, 0.5f);

		id move = [MoveBy actionWithDuration:5 position:ccp(240,160)];
		id rotate = [RotateBy actionWithDuration:2 angle:360];
		id scale = [ScaleBy actionWithDuration:2 scale:5];
		id opacity = [FadeOut actionWithDuration:2];
		id fadein = [FadeIn actionWithDuration:2];
		id scaleback = [ScaleTo actionWithDuration:1 scale:1];
		id finish = [CallFuncN actionWithTarget:self selector:@selector(removeSprite:)];
		id seq0 = [Sequence actions:move, rotate, scale, opacity, fadein, scaleback, finish, nil];
		id seq1 = [[seq0 copy] autorelease];
		id seq2 = [[seq0 copy] autorelease];
		id seq3 = [[seq0 copy] autorelease];
		
		[tile0 runAction:seq0];
		[tile1 runAction:seq1];
		[tile2 runAction:seq2];
		[tile3 runAction:seq3];
		
		
		gid = [layer tileGIDAt:ccp(0,63)];
		NSLog(@"Tile GID at:(0,63) is: %d", gid);

		[self schedule:@selector(updateCol:) interval:0.5f];
		[self schedule:@selector(repaintWithGID:) interval:2];
		[self schedule:@selector(removeTiles:) interval:1];
		
		gid2 = 0;
		
	}	
	return self;
}

-(void) removeSprite:(id) sender
{
	NSLog(@"removing tile: %@", sender);
	id p = [sender parent];
	[p removeChild:sender cleanup:YES];
	NSLog(@"atlas quantity: %d", [[p textureAtlas] totalQuads]);
}

-(void) updateCol:(ccTime)dt
{	
	id map = [self getChildByTag:kTagTileMap];
	TMXLayer *layer = (TMXLayer*) [map getChildByTag:0];
		
	CGSize s = [layer layerSize];
	for( int y=0; y< s.height; y++ ) {
		[layer setTileGID:gid2 at:ccp(3,y)];
	}
	gid2 = (gid2 + 1) % 80;
}
-(void) repaintWithGID:(ccTime)dt
{
//	[self unschedule:_cmd];
	
	id map = [self getChildByTag:kTagTileMap];
	TMXLayer *layer = (TMXLayer*) [map getChildByTag:0];
	
	CGSize s = [layer layerSize];
	for( int x=0; x<s.width;x++) {
		int y = s.height-1;
		unsigned int tmpgid = [layer tileGIDAt:ccp(x,y)];
		[layer setTileGID:tmpgid+1 at:ccp(x,y)];
	}
}

-(void) removeTiles:(ccTime)dt
{
	[self unschedule:_cmd];

	id map = [self getChildByTag:kTagTileMap];
	TMXLayer *layer = (TMXLayer*) [map getChildByTag:0];
	CGSize s = [layer layerSize];
	for( int y=0; y< s.height; y++ ) {
		[layer removeTileAt:ccp(5,y)];
	}
}

-(NSString *) title
{
	return @"TMX Read/Write test";
}
@end

#pragma mark -
#pragma mark TMXTilesetTest

@implementation TMXTilesetTest
-(id) init
{
	if( (self=[super init]) ) {
				
		TMXTiledMap *map = [TMXTiledMap tiledMapWithTMXFile:@"orthogonal-test5.tmx"];
		[self addChild:map z:0 tag:kTagTileMap];
		
		CGSize s = map.contentSize;
		NSLog(@"ContentSize: %f, %f", s.width,s.height);
		
		TMXLayer *layer;
		layer = [map layerNamed:@"Layer 0"];
		[layer.texture setAntiAliasTexParameters];
		
		layer = [map layerNamed:@"Layer 1"];
		[layer.texture setAntiAliasTexParameters];

		layer = [map layerNamed:@"Layer 2"];
		[layer.texture setAntiAliasTexParameters];
		
	}	
	return self;
}

-(NSString *) title
{
	return @"TMX Tileset test";
}
@end



#pragma mark -
#pragma mark Application Delegate

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
	[Director setDirectorType:CCDirectorTypeDisplayLink];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:YES];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
	
	Scene *scene = [Scene node];
	[scene addChild: [nextAction() node]];
	
	//
	// Run all the test with 2d projection
	//
	[[Director sharedDirector] setProjection:CCDirectorProjection2D];

	

	[[Director sharedDirector] runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}
@end

//
//  AVController.h
//  iJam
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVController : NSObject {
    
    NSMutableDictionary      *soundPlayers;
}

-(void)playInstrument:(NSString *)instrument;
-(void)playInstrument:(NSString *)instrument withVolume:(float)volume;

@end

//
//  AVController.m
//  iJam
//
//  Created by Bryan Summersett on 10/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AVController.h"

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

NSString * const AUDIO_DIRECTORY = @"simple-kit";

@implementation AVController

- (void)awakeFromNib
{
    // Make the array to store our AVAudioPlayer objects
    NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:@"aif" inDirectory:nil];

    soundPlayers = [[NSMutableDictionary alloc] initWithCapacity:[paths count]];
    NSLog(@"Capacity %d", [paths count]);
    for (NSString *path in paths) {
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:path];
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        
        // set up AudioPlayer so it doesn't have to load it initially
        [player prepareToPlay];
        
        NSString *instrumentName = [[path lastPathComponent] stringByDeletingPathExtension];
        NSLog(@"audio file %@", instrumentName);
        // set every audio player's key to its last path component without the extension,
        // i.e., 'kick'
        [soundPlayers setObject:player forKey:instrumentName];
        [fileURL release];
        [player release];
    }
}

-(void)dealloc
{
    [soundPlayers release];
    [super dealloc];
}

-(void)playInstrument:(NSString *)instrument
{
    AVAudioPlayer *player = [soundPlayers objectForKey:instrument];
    if (player == nil) {
        NSLog(@"Couldn't find instrument '%@'\n",instrument);
        return;
    }
    if ([player isPlaying]) {
        [player stop];
        [player setCurrentTime:0];
    }
    [player play];
}

- (IBAction)kickButtonPressed:(UIButton *)sender
{
    [self playInstrument:@"kick"];
}
- (IBAction)snareButtonPressed:(UIButton *)sender
{
    [self playInstrument:@"snare"];    
}
- (IBAction)crashButtonPressed:(UIButton *)sender
{
    [self playInstrument:@"crash"];    
}
- (IBAction)hiHatButtonPressed:(UIButton *)sender
{
    [self playInstrument:@"hi-hat"];    
}
- (IBAction)lowTomButtonPressed:(UIButton *)sender
{
    [self playInstrument:@"low-tom"];    
}
- (IBAction)midTomButtonPressed:(UIButton *)sender
{
    [self playInstrument:@"mid-tom"];    
}
- (IBAction)highTomButtonPressed:(UIButton *)sender
{
    [self playInstrument:@"high-tom"];    
}
- (IBAction)rideButtonPressed:(UIButton *)sender
{
    [self playInstrument:@"ride"];    
}
- (IBAction)rideBellButtonPressed:(UIButton *)sender
{
    [self playInstrument:@"ride-bell"];    
}
- (IBAction)cowbellButtonPressed:(UIButton *)sender
{
    [self playInstrument:@"cowbell"];    
}

@end

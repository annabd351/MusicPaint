//
//  CoreAudioController.h
//  Music Paint
//
//  Created by Anna Dickinson on 6/12/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

#import <Spotify/Spotify.h>

static const NSInteger BufferSamples = 512;

typedef struct _SpectrumData {
    NSInteger samples;
    Float32 left[BufferSamples];
    Float32 right[BufferSamples];
    Float32 maxMagnitude;
    NSTimeInterval timestamp;
    
    // For Swift bridging (to prevent copies by value)
    Float32 *leftPtr;
    Float32 *rightPtr;
    Float32 *maxMagnitudePtr;
    NSTimeInterval *timestampPtr;
} SpectrumData;

@interface CoreAudioController : SPTCoreAudioController

@property (nonatomic) SPTCircularBuffer *leftSampleBuffer;
@property (nonatomic) SPTCircularBuffer *rightSampleBuffer;

@property (nonatomic) SpectrumData spectrumData;

- (void)processAudioFromLeftBuffer:(Float32 *)left rightBuffer:(Float32 *)right;

@end

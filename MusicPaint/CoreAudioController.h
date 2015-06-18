//
//  CoreAudioController.h
//  Music Paint
//
//  Created by Anna Dickinson on 6/12/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Streaming audio processing.

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

// FFT result for most recently processed audio frame
@property (nonatomic) SpectrumData spectrumData;

// Raw streaming audio data
@property (nonatomic) SPTCircularBuffer *leftSampleBuffer;
@property (nonatomic) SPTCircularBuffer *rightSampleBuffer;

// Process most recent frame (used internally)
- (void)processAudioFromLeftBuffer:(Float32 *)left rightBuffer:(Float32 *)right;

// Zero-out everything in spectrumData
- (void)resetSpectrumData;

@end

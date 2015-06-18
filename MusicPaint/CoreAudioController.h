//
//  CoreAudioController.h
//  Music Paint
//
//  Created by Anna Dickinson on 6/12/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// Streaming audio processing.

#import <Spotify/Spotify.h>
#import <Accelerate/Accelerate.h>

static const NSInteger SpectrumPoints = 512;

typedef struct _SpectrumData {
    NSInteger points;

    double left[SpectrumPoints];
    double right[SpectrumPoints];
    double maxMagnitude;
    double avgMagnitude;
    vDSP_Length maxIndex;
    NSTimeInterval timestamp;
    
    // For Swift bridging (to prevent copies by value)
    double *leftPtr;
    double *rightPtr;
    double *maxMagnitudePtr;
    double *avgMagnitudePtr;
    vDSP_Length *maxIndexPtr;
    NSTimeInterval *timestampPtr;
    
} SpectrumData;

@interface CoreAudioController : SPTCoreAudioController

// FFT result for most recently processed audio frame
@property (nonatomic) SpectrumData spectrumData;

// Raw streaming audio data
@property (nonatomic) SPTCircularBuffer *leftSampleBuffer;
@property (nonatomic) SPTCircularBuffer *rightSampleBuffer;

// Process most recent frame (used internally)
- (void)processAudioFromLeftBuffer:(Float32 *)left rightBuffer:(Float32 *)right frameCount:(UInt32)frameCount;

// Zero-out everything in spectrumData
- (void)resetSpectrumData;

@end

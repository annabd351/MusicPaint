//
//  CoreAudioController.m
//  Music Paint
//
//  Created by Anna Dickinson on 6/12/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//
// Derived from https://github.com/iKenndac/Viva/

#import "CoreAudioController.h"

static UInt32 const MaxInputAudioFrames = 1024;

// Function called when an audio sample is received
static OSStatus EQRenderCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags  *ioActionFlags,
                                 const AudioTimeStamp        *inTimeStamp,
                                 UInt32                      inBusNumber,
                                 UInt32                      inNumberFrames,
                                 AudioBufferList             *ioData) {
    
    CoreAudioController *controller = (__bridge CoreAudioController *)inRefCon;
    AudioUnitRenderActionFlags flags = *ioActionFlags;
    
    if ((flags & kAudioUnitRenderAction_PostRender) != kAudioUnitRenderAction_PostRender)
        return noErr;

    SPTCircularBuffer *leftCircularBuffer = controller.leftSampleBuffer;
    SPTCircularBuffer *rightCircularBuffer = controller.rightSampleBuffer;
    
    Float32 *leftInBuffer = ioData->mBuffers[0].mData;
    Float32 *rightInBuffer = ioData->mNumberBuffers > 1 ? ioData->mBuffers[1].mData : ioData->mBuffers[0].mData;
    
    if (leftInBuffer == NULL || rightInBuffer == NULL)
        return noErr;

    [controller.leftSampleBuffer attemptAppendData:leftInBuffer ofLength:inNumberFrames * sizeof(Float32) chunkSize:sizeof(Float32)];
    [controller.rightSampleBuffer attemptAppendData:rightInBuffer ofLength:inNumberFrames * sizeof(Float32) chunkSize:sizeof(Float32)];
    
    if (leftCircularBuffer.length == leftCircularBuffer.maximumLength &&
        rightCircularBuffer.length == rightCircularBuffer.maximumLength) {
        
        __block void *left = malloc(leftCircularBuffer.maximumLength);
        __block void *right = malloc(rightCircularBuffer.maximumLength);
        
        [controller.leftSampleBuffer readDataOfLength:leftCircularBuffer.maximumLength
                                             intoAllocatedBuffer:&left];
        
        [controller.rightSampleBuffer readDataOfLength:rightCircularBuffer.maximumLength
                                             intoAllocatedBuffer:&right];
        
        [leftCircularBuffer clear];
        [rightCircularBuffer clear];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [controller processAudioFromLeftBuffer:left rightBuffer:right frameCount:MaxInputAudioFrames];
            free(left); left = NULL;
            free(right); right = NULL;
        });
    }
    
    return noErr;
}


@implementation CoreAudioController {
    AUNode eqNode;
    AudioUnit eqUnit;
    
    double *_leftInputRealBuffer;
    double *_leftInputImagBuffer;
    double *_rightInputRealBuffer;
    double *_rightInputImagBuffer;
    vDSP_Length _fftSetupForSampleCount;
    FFTSetupD _fft_weights;
}

static NSUInteger const fftMagnitudeExponent = 9;

- (instancetype)init {
    if (self  = [super init]) {
        _leftSampleBuffer = [[SPTCircularBuffer alloc] initWithMaximumLength:MaxInputAudioFrames * sizeof(Float32)];
        _rightSampleBuffer = [[SPTCircularBuffer alloc] initWithMaximumLength:MaxInputAudioFrames * sizeof(Float32)];
        
        _fft_weights = vDSP_create_fftsetupD(fftMagnitudeExponent, kFFTRadix2);
        
        _spectrumData.points = SpectrumPoints;
        _spectrumData.leftPtr = _spectrumData.left;
        _spectrumData.rightPtr = _spectrumData.right;
        _spectrumData.maxMagnitudePtr = &_spectrumData.maxMagnitude;
        _spectrumData.avgMagnitudePtr = &_spectrumData.avgMagnitude;
        _spectrumData.maxIndexPtr = &_spectrumData.maxIndex;
        _spectrumData.timestampPtr = &_spectrumData.timestamp;
    }
    return self;
}

-(void)dealloc {
    vDSP_destroy_fftsetupD(_fft_weights);
}

- (void)processAudioFromLeftBuffer:(Float32 *)left rightBuffer:(Float32 *)right frameCount:(UInt32)frameCount {
    // Perform FFT
    [self performEightBitFFTWithWaveformsLeft:left
                                        right:right
                                   frameCount:frameCount
                                   leftResult:_spectrumData.left
                                  rightResult:_spectrumData.right];
    
    double maxMagnitudeL, maxMagnitudeR;
    vDSP_Length maxIndexL, maxIndexR;
    
    vDSP_maxmgviD(_spectrumData.left, 1, &maxMagnitudeL, &maxIndexL, SpectrumPoints);
    vDSP_maxmgviD(_spectrumData.right, 1, &maxMagnitudeR, &maxIndexR, SpectrumPoints);
    
    double avgMagnitudeL, avgMagnitudeR;
    
    vDSP_meanvD(_spectrumData.left, 1, &avgMagnitudeL, SpectrumPoints);
    vDSP_meanvD(_spectrumData.right, 1, &avgMagnitudeR, SpectrumPoints);

    _spectrumData.maxMagnitude = fmax(maxMagnitudeL, maxMagnitudeR);
    _spectrumData.maxIndex = MAX(maxIndexL, maxIndexR);
    _spectrumData.avgMagnitude = fmax(avgMagnitudeL, avgMagnitudeR);
    _spectrumData.timestamp = CACurrentMediaTime();
}

-(void)performEightBitFFTWithWaveformsLeft:(Float32 *)leftFrames
                                     right:(Float32 *)rightFrames
                                frameCount:(vDSP_Length)frameCount
                                leftResult:(double *)leftDestination
                               rightResult:(double *)rightDestination {
    
    if (leftDestination == NULL || rightDestination == NULL || leftFrames == NULL || rightFrames == NULL || frameCount == 0)
        return;
    
    if (frameCount != _fftSetupForSampleCount) {
        /* Allocate memory to store split-complex input and output data */
        
        if (_leftInputRealBuffer != NULL) free(_leftInputRealBuffer);
        if (_leftInputImagBuffer != NULL) free(_leftInputImagBuffer);
        
        _leftInputRealBuffer = (double *)malloc(frameCount * sizeof(double));
        _leftInputImagBuffer = (double *)malloc(frameCount * sizeof(double));
        
        if (_rightInputRealBuffer != NULL) free(_rightInputRealBuffer);
        if (_rightInputImagBuffer != NULL) free(_rightInputImagBuffer);
        
        _rightInputRealBuffer = (double *)malloc(frameCount * sizeof(double));
        _rightInputImagBuffer = (double *)malloc(frameCount * sizeof(double));
        
        _fftSetupForSampleCount = frameCount;
    }
    
    memset(_leftInputRealBuffer, 0, frameCount * sizeof(double));
    memset(_rightInputRealBuffer, 0, frameCount * sizeof(double));
    memset(_leftInputImagBuffer, 0, frameCount * sizeof(double));
    memset(_rightInputImagBuffer, 0, frameCount * sizeof(double));
    
    DSPDoubleSplitComplex leftInput = {_leftInputRealBuffer, _leftInputImagBuffer};
    DSPDoubleSplitComplex rightInput = {_rightInputRealBuffer, _rightInputImagBuffer};
    
    // Left
    for (int i = 0; i < frameCount; i++) {
        leftInput.realp[i] = (double)leftFrames[i];
        rightInput.realp[i] = (double)rightFrames[i];
    }
    
    /* 1D in-place complex FFT */
    vDSP_fft_zipD(_fft_weights, &leftInput, 1, fftMagnitudeExponent, FFT_FORWARD);
    // Get magnitudes
    vDSP_zvmagsD(&leftInput, 1, leftDestination, 1, exp2(fftMagnitudeExponent));
    
    /* 1D in-place complex FFT */
    vDSP_fft_zipD(_fft_weights, &rightInput, 1, fftMagnitudeExponent, FFT_FORWARD);
    // Get magnitudes
    vDSP_zvmagsD(&rightInput, 1, rightDestination, 1, exp2(fftMagnitudeExponent));
}

-(BOOL)connectOutputBus:(UInt32)sourceOutputBusNumber ofNode:(AUNode)sourceNode toInputBus:(UInt32)destinationInputBusNumber ofNode:(AUNode)destinationNode inGraph:(AUGraph)graph error:(NSError **)error {
    
    // Override this method to connect the source node to the destination node via an EQ node.
    
    // A description for the EQ Device
    AudioComponentDescription eqDescription;
    eqDescription.componentType = kAudioUnitType_Effect;
    eqDescription.componentSubType = kAudioUnitSubType_NBandEQ;
    eqDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    eqDescription.componentFlags = 0;
    eqDescription.componentFlagsMask = 0;
    
    // Add the EQ node to the AUGraph
    OSStatus status = AUGraphAddNode(graph, &eqDescription, &eqNode);
    if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't add EQ node");
        return NO;
    }
    
    // Get the EQ Audio Unit from the node so we can set bands directly later
    status = AUGraphNodeInfo(graph, eqNode, NULL, &eqUnit);
    if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't get EQ unit");
        return NO;
    }
    
    // Init the EQ
    status = AudioUnitInitialize(eqUnit);
    if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't init EQ!");
        return NO;
    }
    
    // Set EQ to 10-band
    status = AudioUnitSetParameter(eqUnit, 10000, kAudioUnitScope_Global, 0, 0.0, 0);
    if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't set EQ parameter");
        return NO;
    }
    
    // Connect the output of the source node to the input of the EQ node
    status = AUGraphConnectNodeInput(graph, sourceNode, sourceOutputBusNumber, eqNode, 0);
    if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't connect converter to eq");
        return NO;
    }
    
    // Connect the output of the EQ node to the input of the destination node, thus completing the chain.
    status = AUGraphConnectNodeInput(graph, eqNode, 0, destinationNode, destinationInputBusNumber);
    if (status != noErr) {
        NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), @"Couldn't connect eq to output");
        return NO;
    }
    
    AudioUnitAddRenderNotify(eqUnit, EQRenderCallback, (__bridge void *)self);
    
    return YES;
}

-(void)disposeOfCustomNodesInGraph:(AUGraph)graph {
    
    AudioUnitRemoveRenderNotify(eqUnit, EQRenderCallback, (__bridge void *)self);
    
    // Shut down our unit.
    AudioUnitUninitialize(eqUnit);
    eqUnit = NULL;
    
    // Remove the unit's node from the graph.
    AUGraphRemoveNode(graph, eqNode);
    eqNode = 0;
}

- (void)resetSpectrumData {
    // Clear out stale spectrum data
    _spectrumData.maxMagnitude = 0.0f;
    vDSP_vclrD(_spectrumData.left, 1, SpectrumPoints);
    vDSP_vclrD(_spectrumData.right, 1, SpectrumPoints);
}

@end

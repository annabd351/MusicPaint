//
//  SpriteRenderingView.h
//
//  Created by Anna Dickinson on 5/28/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "SpriteBuffer.h"

@interface SpriteRenderingView : GLKView

@property (nonatomic) BOOL clearFramebufferBeforeDrawing;
@property (nonatomic, readonly) SpriteBuffer *spriteBuffer;
@property (nonatomic, readonly) NSInteger spriteCapacity;

@property (nonatomic) UIImage *particleTextureImage;
@property (nonatomic) UIImage *sampleSourceTextureImage;

- (void)loadTestPattern;

@end

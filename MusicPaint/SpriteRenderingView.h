//
//  SpriteRenderingView.h
//
//  Created by Anna Dickinson on 5/28/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

// OpenGL view which stores and displays point sprites.

// TODO: Not currently handling view and image vs. device rotation.

#import <GLKit/GLKit.h>
#import "SpriteBuffer.h"

@interface SpriteRenderingView : GLKView

// All living (age <= lifespan) sprites in this buffer are rendered on each update.
@property (nonatomic, readonly) SpriteBuffer *spriteBuffer;
@property (nonatomic, readonly) NSInteger spriteBufferCapacity;

// Texture for each sprite (all sprites in the view use the same one)
@property (nonatomic) UIImage *particleTextureImage;

// Virtual "background" image.  Sprites get their color by sampling the point on this image
// directly behind them.
@property (nonatomic) UIImage *sampleSourceTextureImage;

// If set, clear the framebuffer on each update (normal case for moving objects); if not set,
// framebuffer retains its contents, creating trails.
@property (nonatomic) BOOL clearFramebufferBeforeDrawing;

- (void)clear;
- (void)loadTestPattern;

@end

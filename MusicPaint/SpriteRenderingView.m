//
//  SpriteRenderingView.m
//
//  Created by Anna Dickinson on 5/28/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

#import "SpriteRenderingView.h"

@implementation SpriteRenderingView {
    SpriteBuffer *_spriteBuffer;
    GLKVector4 _glkBackgroundColor;
    BOOL _firstDraw;
    GLuint _spriteVBO;
    GLKMatrix4 _projectionMatrix;
    
    GLKTextureInfo *_particleTexture;
    GLKTextureInfo *_sampleSourceTexture;
    
    BOOL _needsClearing;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:self.context];

        // Disable framebuffers we don't need (saves memory)
        self.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
        self.drawableStencilFormat = GLKViewDrawableStencilFormatNone;
        self.drawableMultisample = GLKViewDrawableMultisampleNone;
        
        // Create sprite buffer and load shader
        _spriteBuffer = [[SpriteBuffer alloc] init];
        [_spriteBuffer loadShaders];
        glUseProgram(_spriteBuffer.program);

        // Generate a virtual OpenGL buffer for the sprites
        glGenBuffers(1, &_spriteVBO);
        glBindBuffer(GL_ARRAY_BUFFER, _spriteVBO);
        [self enableAttributeArrays];
        
        // Set the blending function (normal w/ premultiplied alpha)
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        _needsClearing = true;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Set up the projectionMatrix to map CGPoints directly into GL coordinate space.
    // This allows us to specify all positions in terms of this view's frame (i.e. with CGPoints)

    // x_out = (x_in/width * 2) - 1
    // y_out = (-y_in/height * 2) + 1    <-- flipped in y

    GLfloat xScale = 2.0f/self.frame.size.width;
    GLfloat yScale = 2.0f/self.frame.size.height;
    
    _projectionMatrix = GLKMatrix4MakeWithRows(
                                                  GLKVector4Make(xScale,    0.0f, 0.0f, -1.0f),
                                                  GLKVector4Make(  0.0f, -yScale, 0.0f,  1.0f),
                                                  GLKVector4Make(  0.0f,    0.0f, 1.0f,  0.0f),
                                                  GLKVector4Make(  0.0f,    0.0f, 0.0f,  1.0f));

    glUniformMatrix4fv(_spriteBuffer.projectionMatrix, 1, 0, _projectionMatrix.m);
    glUniform2f(_spriteBuffer.windowSize, (GLfloat)self.drawableWidth, (GLfloat)self.drawableHeight);
    
    [self display];
}


// View properties

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    CGFloat r, b, g, a;
    [backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    
    _glkBackgroundColor = GLKVector4Make(r, g, b, a);
}

- (SpriteBuffer *)spriteBuffer {
    return _spriteBuffer;
}

- (NSInteger)spriteBufferCapacity {
    return SpriteBufferCapacity;
}

- (void)setParticleTextureImage:(UIImage *)particleTextureImage {
    [SpriteRenderingView checkGLError];
    
    if (_particleTexture) {
        [self deleteTexture:_particleTexture];
    }
    _particleTextureImage = particleTextureImage;
    _particleTexture = [self loadTexture:_particleTextureImage];
    
    if (_sampleSourceTexture) {
        [self connectTextures];
    }
}

- (void)setSampleSourceTextureImage:(UIImage *)sampleSourceTextureImage {
    if (_sampleSourceTexture) {
        [self deleteTexture:_sampleSourceTexture];
    }
    _sampleSourceTextureImage = sampleSourceTextureImage;
    _sampleSourceTexture = [self loadTexture:_sampleSourceTextureImage];

    if (_particleTexture) {
        [self connectTextures];
    }
}


// OpenGL setup

- (GLKTextureInfo *)loadTexture:(UIImage *)image {
    [EAGLContext setCurrentContext:self.context];

    NSError *error;
    GLKTextureInfo *texture = [GLKTextureLoader textureWithCGImage:image.CGImage options:@{GLKTextureLoaderOriginBottomLeft : @YES} error:&error];

    NSAssert(texture != nil, @"Error loading texture: %@", [error localizedDescription]);

    return texture;
}

- (void)deleteTexture:(GLKTextureInfo *)texture {
    [EAGLContext setCurrentContext:self.context];

    GLuint oldTextureHandle = texture.name;
    glDeleteTextures(1, &oldTextureHandle);
}

- (void)connectTextures {
    // Connect textures to the fragment shader
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(_particleTexture.target, _particleTexture.name);
    glUniform1i(_spriteBuffer.texture, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(_sampleSourceTexture.target, _sampleSourceTexture.name);
    glUniform1i(_spriteBuffer.image, 1);
}

- (void)enableAttributeArrays {
    glEnableVertexAttribArray(_spriteBuffer.position);
    glVertexAttribPointer(_spriteBuffer.position,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(Sprite),
                          (void *)(offsetof(Sprite, position)));
    
    glEnableVertexAttribArray(_spriteBuffer.color);
    glVertexAttribPointer(_spriteBuffer.color,
                          4,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(Sprite),
                          (void *)(offsetof(Sprite, color)));
    
    glEnableVertexAttribArray(_spriteBuffer.scale);
    glVertexAttribPointer(_spriteBuffer.scale,
                          1,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(Sprite),
                          (void *)(offsetof(Sprite, scale)));
    
    glEnableVertexAttribArray(_spriteBuffer.age);
    glVertexAttribPointer(_spriteBuffer.age,
                          1,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(Sprite),
                          (void *)(offsetof(Sprite, age)));
    
    glEnableVertexAttribArray(_spriteBuffer.lifespan);
    glVertexAttribPointer(_spriteBuffer.lifespan,
                          1,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(Sprite),
                          (void *)(offsetof(Sprite, lifespan)));
}


// Render loop

- (void)drawRect:(CGRect)rect {
    if (self.clearFramebufferBeforeDrawing || _needsClearing) {
        [self clearFramebuffer];
        _needsClearing = false;
    }

    // Draw particles
    glBufferData(
                 GL_ARRAY_BUFFER,
                 sizeof(Sprite) * SpriteBufferCapacity,
                 _spriteBuffer.sprites,
                 GL_STATIC_DRAW);

    glDrawArrays(GL_POINTS, 0, SpriteBufferCapacity);
    
}

- (void)clearFramebuffer {
    glClearColor(_glkBackgroundColor.r, _glkBackgroundColor.g, _glkBackgroundColor.b, _glkBackgroundColor.a);
    glClear(GL_COLOR_BUFFER_BIT);
}


// Debugging

- (void)loadTestPattern {
    
    // Clear sprite buffer
    for (int index = 0; index < SpriteBufferCapacity; index++) {
        _spriteBuffer.sprites[index].lifespan = 0.0f;
        _spriteBuffer.sprites[index].age = 1.0f;
    }
    
    GLfloat upperX = self.frame.size.width;
    GLfloat upperY = self.frame.size.height;
    
    // Generate gradient pattern
    for (float x = 0.0f; x <= upperX; x += 5.0f) {
        for (float y = 0.0f; y <= upperY; y += 10.0f) {
            Sprite *sprite = [_spriteBuffer newSprite];
            
            sprite->position = GLKVector2Make(x, y);
            sprite->age = 0.0f;
            sprite->lifespan = 1.0f;
            sprite->scale = 20.0f;

            sprite->color = GLKVector4Make(x/upperX, y/upperY, 0.0f, 1.0f);
        }
    }
}

+ (void)checkGLError {
    glFlush();
    
    GLenum error = glGetError();
    NSString *type;
    
    switch (error) {
        case GL_NO_ERROR:
            type = @"GL_NO_ERROR";
            break;
            
        case GL_INVALID_ENUM:
            type = @"GL_INVALID_ENUM";
            break;
            
        case GL_INVALID_VALUE:
            type = @"GL_INVALID_VALUE";
            break;
            
        case GL_INVALID_OPERATION:
            type = @"GL_INVALID_OPERATION";
            break;
            
        case GL_OUT_OF_MEMORY:
            type =  @"GL_OUT_OF_MEMORY";
            break;
            
        default:
            type =  @"<<unknown GL error>>";
            break;
    }
    
    NSAssert(error == GL_NO_ERROR, @"GL Error: %@", type);
}

@end

// This extension is used to "set" drawableProperties for our layer.  We need this because
// the GLKView itself normally controls these values itself -- there is no way to set them.
// This overrides the GLKView values.

@implementation CAEAGLLayer (ForceRetainedBacking)

- (NSDictionary*) drawableProperties {
    return @{kEAGLDrawablePropertyRetainedBacking : @(YES)};
}

@end

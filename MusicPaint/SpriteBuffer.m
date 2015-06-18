//
//  SpriteBuffer.m
//

#import "SpriteBuffer.h"
#import "ShaderProcessor.h"
#import "DebugMacro.h"

// Shaders

#define STRINGIFY(A) #A
#include "Sprite.vsh"
#include "Sprite.fsh"

@implementation SpriteBuffer {
    Sprite _allocatedSprites[SpriteBufferCapacity];
    NSInteger _nextAvailableSpriteIndex;
}

- (instancetype)init {
    if (self = [super init]) {
        _nextAvailableSpriteIndex = 0;
    }
    return self;
}

- (void)loadShaders {
    // Program
    ShaderProcessor *shaderProcessor = [[ShaderProcessor alloc] init];
    self.program = [shaderProcessor BuildProgram:SpriteVS with:SpriteFS];
    
    // Attributes
    self.color = (GLuint) glGetAttribLocation(self.program, "color");
    self.position = (GLuint) glGetAttribLocation(self.program, "position");
    self.scale = (GLuint) glGetAttribLocation(self.program, "scale");
    self.age = (GLuint) glGetAttribLocation(self.program, "age");
    self.lifespan = (GLuint) glGetAttribLocation(self.program, "lifespan");

    // Uniforms
    self.projectionMatrix = glGetUniformLocation(self.program, "projectionMatrix");
    self.texture = glGetUniformLocation(self.program, "texture");
    self.image = glGetUniformLocation(self.program, "image");
    self.windowSize = glGetUniformLocation(self.program, "windowSize");
}

- (Sprite *)newSprite {
    Sprite *retVal = _allocatedSprites + _nextAvailableSpriteIndex;
    _nextAvailableSpriteIndex = (_nextAvailableSpriteIndex + 1) % SpriteBufferCapacity;
    
    return retVal;
}

- (Sprite *)sprites {
    return _allocatedSprites;
}

@end

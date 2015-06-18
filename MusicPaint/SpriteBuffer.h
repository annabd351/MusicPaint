//
//  SpriteBuffer.h
//

#import <GLKit/GLKit.h>

// Fixed size for sprite buffer
#define SpriteBufferCapacity 8096

typedef struct _Sprite {
    GLKVector2 position;
    GLKVector4 color;
    GLfloat scale;
    GLfloat age;
    GLfloat lifespan;
} Sprite;

@interface SpriteBuffer : NSObject

// The raw buffer memory
@property (nonatomic, readonly) Sprite *sprites;

// Get the next sprite in the buffer.  Allocated circularly.
- (Sprite *)newSprite;

// Load the sprite shaders
- (void)loadShaders;

// References to OpenGL objects

// Program Handle
@property (nonatomic) GLuint program;

// Attribute Handles
@property (nonatomic) GLuint color;
@property (nonatomic) GLuint position;
@property (nonatomic) GLuint scale;
@property (nonatomic) GLuint age;
@property (nonatomic) GLuint lifespan;

// Uniform Handles
@property (nonatomic) GLint projectionMatrix;
@property (nonatomic) GLint texture;
@property (nonatomic) GLint image;
@property (nonatomic) GLint windowSize;


// Methods

@end

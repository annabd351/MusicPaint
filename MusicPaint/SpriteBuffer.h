//
//  SpriteBuffer.h
//

#import <GLKit/GLKit.h>

// For simplicity, use a fixed-size buffer
#define kSpriteBufferCapacity 7500

typedef struct _Sprite {
    GLKVector2 position;
    GLKVector4 color;
    GLfloat scale;
    GLfloat age;
    GLfloat lifespan;
} Sprite;

@interface SpriteBuffer : NSObject

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

// Sprites
@property (nonatomic, readonly) Sprite *sprites;

// Methods
- (instancetype)init;
- (void)loadShader;
- (Sprite *)newSprite;

@end

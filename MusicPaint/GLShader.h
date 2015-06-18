//
//  GLShader.h
//  Music Paint
//
//  Created by Anna Dickinson on 6/2/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GLShader : NSObject

typedef NS_ENUM(NSUInteger, ShaderVariableType) {
    ShaderVariableTypeUniform,
    ShaderVariableTypeAttribute
};

// Reference to this shader in the GL API
@property (nonatomic, readonly) GLuint programHandle;

// Reference to the texture input used by this shader (the image to filter)
@property (nonatomic, readonly) GLint textureHandle;

// Reference to the vertex input used by the vertex shader
@property (nonatomic, readonly) GLint vertexCoordinateHandle;

// Set up an instance using the given shaders
- (void)setupWithShaderFromPath:(NSString *)vertexShaderPath fragmentShaderPath:(NSString *)fragmentShaderPath;

@end

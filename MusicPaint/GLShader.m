//
//  GLShader.m
//  Music Paint
//
//  Created by Anna Dickinson on 6/2/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

#import "GLShader.h"

@implementation GLShader {
    NSData *_vertextShaderSource;
    NSData *_fragmentShaderSource;
}

static const int GLErrorLogSize = 1024;

- (void)setupWithShaderFromPath:(NSString *)vertexShaderPath fragmentShaderPath:(NSString *)fragmentShaderPath {
    NSError *error;
    NSString *fileContents;
    
    // Read files
    fileContents = [NSString stringWithContentsOfFile:vertexShaderPath encoding:NSUTF8StringEncoding error:&error];
    NSAssert(fileContents != nil, @"Could open file \"%@\" (%@)", vertexShaderPath, [error localizedDescription]);
    _vertextShaderSource = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    
    fileContents = [NSString stringWithContentsOfFile:fragmentShaderPath encoding:NSUTF8StringEncoding error:&error];
    NSAssert(fileContents != nil, @"Could open file \"%@\" (%@)", fragmentShaderPath, [error localizedDescription]);
    _fragmentShaderSource = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    
    // Load and compile shaders
    GLuint vertexShaderHandle = [GLShader compileShaderSource:_vertextShaderSource.bytes shaderType:GL_VERTEX_SHADER];
    GLuint fragmentShaderHandle = [GLShader compileShaderSource:_fragmentShaderSource.bytes shaderType:GL_FRAGMENT_SHADER];
    
    // Link the shaders into a program
    _programHandle = [GLShader createProgramForVertexShaderHandle:vertexShaderHandle fragmentShaderHandle:fragmentShaderHandle];
    
    // Get handles to shader variables
    _textureHandle = [GLShader handleForShaderVariableNamed:@"texture" programHandle:self.programHandle type:ShaderVariableTypeUniform];
    _vertexCoordinateHandle = [GLShader handleForShaderVariableNamed:@"vertexCoordinate" programHandle:self.programHandle type:ShaderVariableTypeAttribute];
}

// Load the source code of a shader into the GL API
+ (GLuint)compileShaderSource:(const GLchar *)shaderSource shaderType:(GLenum)type {
    
    // Reference to this shader in GL
    GLuint shaderHandle = glCreateShader(type);
    
    // Transfer the soure code to GL
    glShaderSource(shaderHandle, 1, &shaderSource, 0);
    
    // Compile and check for errors
    glCompileShader(shaderHandle);
    
    GLint status;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &status);
    
    if (status == GL_FALSE) {
        GLchar *errorLog = malloc(GLErrorLogSize);
        glGetShaderInfoLog(shaderHandle, GLErrorLogSize, 0, errorLog);
        NSAssert(false, @"Could not load shader.\n%s", errorLog);
    }
    
    return shaderHandle;
}

// Link previously loaded vertex and fragment shaders to form a GL program
+ (GLuint)createProgramForVertexShaderHandle:(GLuint)vertexShader fragmentShaderHandle:(GLuint)fragmentShader {
    
    // Reference to this program in GL
    GLuint programHandle = glCreateProgram();
    
    // Combine the shaders into a program and check for errors
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    
    glLinkProgram(programHandle);
    
    GLint status;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &status);
    
    if (status == GL_FALSE) {
        GLchar *errorLog = malloc(GLErrorLogSize);
        glGetProgramInfoLog(programHandle, GLErrorLogSize, 0, errorLog);
        NSAssert(false, @"Could not link program.\n%s", errorLog);
    }
    
    return programHandle;
}

+ (GLint)handleForShaderVariableNamed:(NSString *)variableName programHandle:(GLuint)programHandle type:(ShaderVariableType)type {
    GLuint retVal;
    
    switch (type) {
        case ShaderVariableTypeUniform:
            retVal = glGetUniformLocation(programHandle, variableName.UTF8String);
            break;
            
        case ShaderVariableTypeAttribute:
            retVal = glGetAttribLocation(programHandle, variableName.UTF8String);
            break;
            
        default:
            NSAssert(false, @"Unknown ShaderVariableType");
            break;
    }
    
    if (retVal == -1) {
        GLenum error = glGetError();
        NSAssert(false, @"Could not get handle for shader variable \"%@\" (error code %d)", variableName, error);
    }
    
    return retVal;
}

@end

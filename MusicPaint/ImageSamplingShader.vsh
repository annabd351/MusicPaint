
uniform sampler2D image;

// Attributes
attribute vec4 color;
attribute vec2 position;
attribute float scale;
attribute float age;
attribute float lifespan;

// Uniforms
uniform mat4 projectionMatrix;

// Output to Fragment Shader
varying vec4 fragmentColor;
varying float fragmentAge;
varying float fragmentLifespan;

void main(void) {
    gl_Position = projectionMatrix * vec4(position[0], position[1], 0, 1);
    gl_PointSize = scale;
    
    fragmentColor = 
    
    fragmentAge = age;
    fragmentLifespan = lifespan;
}

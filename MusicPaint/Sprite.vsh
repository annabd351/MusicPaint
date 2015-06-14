// Vertex Shader

static const char* SpriteVS = STRINGIFY
(
 
 // Attributes
 attribute vec4 color;
 attribute vec2 position;
 attribute float scale;
 attribute float age;
 attribute float lifespan;
 
 // Uniforms
 uniform mat4 projectionMatrix;
 uniform sampler2D image;
 
 // Output to Fragment Shader
 varying vec4 fragmentColor;
 varying float fragmentAge;
 varying float fragmentLifespan;
 
 void main(void) {
     gl_Position = projectionMatrix * vec4(position[0], position[1], 0, 1);
     gl_PointSize = scale;
     
     vec2 samplePoint = (gl_Position.xy + 1.0)/2.0;
     vec4 imageSample = texture2DLod(image, samplePoint, 1.0);
     
     fragmentColor = imageSample * color;
     
     fragmentAge = age;
     fragmentLifespan = lifespan;
 }
 
 );
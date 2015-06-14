// Fragment Shader

static const char* SpriteFS = STRINGIFY
(
 
 // Input from Vertex Shader
 varying highp vec4 fragmentColor;
 varying highp float fragmentAge;
 varying highp float fragmentLifespan;
 
 // Uniforms
 uniform sampler2D texture;
 // uniform sampler2D image;
 
 uniform lowp vec2 windowSize;
 
 void main(void) {
     if (fragmentAge > fragmentLifespan) {
         discard;
     }
     else {
         highp vec4 textureColor = texture2D(texture, gl_PointCoord);

//         highp vec2 samplePoint = vec2(gl_FragCoord[0]/windowSize[0], gl_FragCoord[1]/windowSize[1]);
//         
//         highp vec4 imageSample = texture2D(image, samplePoint);
         
         gl_FragColor = textureColor * fragmentColor;
     }

 }
 
 );
attribute vec3 texturePosition;
attribute vec2 textureCoordinate;

uniform float flipXFlag;

varying vec2 texCoord;

void main()
{
    texCoord = textureCoordinate;
    
    vec4 finalPosition = vec4(texturePosition, 1.0);
    if( flipXFlag > 0.5 ) {
        finalPosition.x = finalPosition.x * -1.0;
    }
    gl_Position = finalPosition;
}

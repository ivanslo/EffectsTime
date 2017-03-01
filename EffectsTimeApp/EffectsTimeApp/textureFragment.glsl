precision lowp float;

varying vec2 texCoord;
uniform float invertFlag;
uniform sampler2D myTexture;

void main(void) {
    vec4 finalColor = texture2D(myTexture, texCoord);
    if( invertFlag > 0.5 ) {
        finalColor = vec4(1.0) - finalColor;
    }
    gl_FragColor = finalColor;
}

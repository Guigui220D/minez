#version 130

#define PI 3.1415926538

uniform sampler2D textureSampler; // Our render texture

uniform bool glitch;

float rand(vec2 n, float i) { return fract(sin(n.x + i) * 43758.5453123 + cos(n.y * 3 + i) * 65851.256 + i);}

void main(void) 
{
    vec2 uv = gl_TexCoord[0].xy;
    if (glitch)
        uv.x = uv.x + uv.y;
    if (uv.x <= 1.0) {
        gl_FragColor = texture2D(textureSampler, uv);
    } else {
        gl_FragColor = vec4(rand(uv, 1), rand(uv, 2), rand(uv, 3), rand(uv, 4));
    }
}
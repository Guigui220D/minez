// Thanks to this tutorial
// https://babylonjs.medium.com/retro-crt-shader-a-post-processing-effect-study-1cb3f783afbc

#version 130

#define PI 3.1415926538

uniform sampler2D textureSampler; // Our render texture

uniform vec2 curvature;
uniform vec2 screenResolution;
uniform vec2 scanLineOpacity;

uniform float brightness;
uniform float distortion;
 
float distort(float x) 
{
    return cos((x - distortion) * 12) * exp(-abs(12 * (x - distortion)));
}

vec2 curveRemapUV(vec2 uv)
{
    vec2 offset = abs(uv.yx - vec2(0.5, 0.5)) / vec2(curvature.x, curvature.y);
    uv = uv + (uv - vec2(0.5, 0.5)) * offset * offset;
    return uv;
}

vec4 scanLineIntensity(float uv, float resolution, float opacity)
{
    float intensity = sin(uv * resolution * PI * 2.0);
    intensity = ((0.5 * intensity) + 0.5) * 0.9 + 0.1;
    return vec4(vec3(pow(intensity, opacity)), 1.0);
}

vec4 vignette(vec2 uv)
{
    uv = abs(uv - vec2(0.5, 0.5)) * 2;
    return vec4(vec3(1.0 - clamp(uv.x * uv.y, 0.0, 1.0)), 1.0);
}

vec4 lessBits(vec4 col) {
    return round(col * 16.0) / 16.0;
}

void main(void) 
{
    vec2 remappedUV = curveRemapUV(gl_TexCoord[0].st);
    

    if (remappedUV.x < 0.0 || remappedUV.y < 0.0 || remappedUV.x > 1.0 || remappedUV.y > 1.0){
        gl_FragColor = vec4(0.2, 0.2, 0.2, 1.0);
    } 
    else 
    {
        vec2 uv2 = remappedUV;
        //uv2.x = uv2.x + distort(uv2.y);
        vec4 baseColor = lessBits(texture2D(textureSampler, uv2));
        if (uv2.x > 1.0)
        {
            baseColor = vec4(vec3(0.0), 1.0);
        }
        baseColor *= scanLineIntensity(remappedUV.x, screenResolution.y, scanLineOpacity.x);
        baseColor *= scanLineIntensity(remappedUV.y, screenResolution.x, scanLineOpacity.y);
        baseColor *= vignette(remappedUV);
        baseColor *= vec4(vec3(brightness), 1.0);
        
        gl_FragColor = baseColor;
    }
}
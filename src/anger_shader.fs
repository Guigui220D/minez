// Thanks to this shadertoy shader
// https://www.shadertoy.com/view/MtGXWh

#version 130

#define PI 3.1415926538

uniform sampler2D textureSampler; // Our render texture
uniform float time;
uniform float dist;

float variation(vec2 v1, vec2 v2, float strength, float speed) {
	return sin(
        dot(normalize(v1), normalize(v2)) * strength + time * speed
    ) / 100.;
}

vec3 paintCircle (vec2 uv, vec2 center, float rad, float width, float index) {
    vec2 diff = center-uv;
    float len = length(diff);
    float scale = rad;
	float mult = mod(index, 2.) == 0. ? 1. : -1.; 
    len += variation(diff, vec2(rad*mult, 1.0), 7.0*scale, 2.0);
    len -= variation(diff, vec2(1.0, rad*mult), 7.0*scale, 2.0);
    float circle = smoothstep((rad-width)*scale, (rad)*scale, len) - smoothstep((rad)*scale, (rad+width)*scale, len);
    return vec3(circle);
}

vec3 paintRing(vec2 uv, vec2 center, float radius, float index){
    vec3 color = paintCircle(uv, center, radius, 0.075, index);
    color *= vec3(1.0,0,1.0);
    color += paintCircle(uv, center, radius, 0.015, index);
    return color;
}

void main(void) 
{
    vec2 uv = gl_TexCoord[0].xy;
    vec4 color = texture2D(textureSampler, uv);

    if (color == vec4(0, 1, 0, 1)) {
        uv = uv - vec2(0.25, 0.25);

        const float numRings = 10.;
        const vec2 center = vec2(0.5);
        const float spacing = 1. / numRings;
        const float slow = 30.;
        const float cycleDur = 1.;
        const float tunnelElongation = .25;

        float radius = mod(time/slow, cycleDur);
        vec3 col;

        float border = 0.25;
        vec2 bl = smoothstep(0., border, uv);
        vec2 tr = smoothstep(0., border, 1.-uv);
        float edges = bl.x * bl.y * tr.x * tr.y;
        
        for(float i=0.; i<numRings; i++){
            col += paintRing(uv, center, tunnelElongation*log(mod(radius + i * spacing, cycleDur)), i ); //these are the fast circles
            col += paintRing(uv, center, log(mod(radius + i * spacing, cycleDur)), i); //these are essentially the same but move at a slower pace
        }
        col = mix(col, vec3(0.), 1.-edges); 
        col = mix(col, vec3(0., 1., 0.), distance(uv, center));

        color = vec4(col, 1.0);
    } 

    if (color != vec4(1, 0, 1, 1))
        color.a *= clamp(1 - (dist / 200), 0., 1.);

    gl_FragColor = color;
}
#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
    #define PRECISION highp
#else
    #define PRECISION mediump
#endif

extern PRECISION vec2 veiled;
extern PRECISION number dissolve;
extern PRECISION number time;
extern PRECISION vec4 texture_details;
extern PRECISION vec2 image_details;
extern bool shadow;
extern PRECISION vec4 burn_colour_1;
extern PRECISION vec4 burn_colour_2;

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv);

vec4 dissolve_mask(vec4 tex, vec2 texture_coords, vec2 uv)
{
   if (dissolve < 0.001) {
       return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, shadow ? tex.a*0.3: tex.a);
   }

   float adjusted_dissolve = (dissolve*dissolve*(3.-2.*dissolve))*1.02 - 0.01;

   float t = time * 10.0 + 2003.;
   vec2 floored_uv = (floor((uv*texture_details.ba)))/max(texture_details.b, texture_details.a);
   vec2 uv_scaled_centered = (floored_uv - 0.5) * 2.3 * max(texture_details.b, texture_details.a);
   
   vec2 field_part1 = uv_scaled_centered + 50.*vec2(sin(-t / 143.6340), cos(-t / 99.4324));
   vec2 field_part2 = uv_scaled_centered + 50.*vec2(cos( t / 53.1532),  cos( t / 61.4532));
   vec2 field_part3 = uv_scaled_centered + 50.*vec2(sin(-t / 87.53218), sin(-t / 49.0000));

   float field = (1.+ (
       cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) +
       cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92) ))/2.;
   vec2 borders = vec2(0.2, 0.8);

   float res = (.5 + .5* cos( (adjusted_dissolve) / 82.612 + ( field + -.5 ) *3.14))
   - (floored_uv.x > borders.y ? (floored_uv.x - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve)
   - (floored_uv.y > borders.y ? (floored_uv.y - borders.y)*(5. + 5.*dissolve) : 0.)*(dissolve)
   - (floored_uv.x < borders.x ? (borders.x - floored_uv.x)*(5. + 5.*dissolve) : 0.)*(dissolve)
   - (floored_uv.y < borders.x ? (borders.x - floored_uv.y)*(5. + 5.*dissolve) : 0.)*(dissolve);

   if (tex.a > 0.01 && burn_colour_1.a > 0.01 && !shadow && res < adjusted_dissolve + 0.8*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
       if (!shadow && res < adjusted_dissolve + 0.5*(0.5-abs(adjusted_dissolve-0.5)) && res > adjusted_dissolve) {
           tex.rgba = burn_colour_1.rgba;
       } else if (burn_colour_2.a > 0.01) {
           tex.rgba = burn_colour_2.rgba;
       }
   }

   return vec4(shadow ? vec3(0.,0.,0.) : tex.xyz, res > adjusted_dissolve ? (shadow ? tex.a*0.3: tex.a) : .0);
}

vec4 effect(vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords)
{
   vec4 tex = Texel(texture, texture_coords);
   vec2 uv = (((texture_coords)*(image_details)) - texture_details.xy*texture_details.ba)/texture_details.ba;

   float noise = 3.0;
   float amplitude = 7.0;
   float frequency = 1.0;
   float t = time * 1.2;
   vec2 st = uv * 3.0;

    for(int i = 0; i < 3; i++) {
       float angle = t * (0.1 + 0.2 * float(i));
       vec2 rotated = vec2(
           st.x * cos(angle) - st.y * sin(angle),
           st.x * sin(angle) + st.y * cos(angle)
       );
       noise += amplitude * sin(rotated.x * frequency) * sin(rotated.y * frequency);
       frequency *= 2.17;
       amplitude *= 0.5;
   }
   
   // UV distortion similar to foil
   vec2 rotater = vec2(cos(t*0.1221), sin(t*0.3512));
   float angle = dot(rotater, uv)/(length(rotater)*length(uv));
   
   // Multiple layered wave patterns
   float wave1 = sin(angle*3.14*(2.2 + 0.9*sin(t*1.65)));
   float wave2 = sin(10.0*length(uv) + t);
   float wave3 = cos(20.0*uv.x + 15.0*uv.y + t*0.5);
   
   // Combine waves
   float pattern = (wave1 + wave2 + wave3) * (0.5 + 0.3*veiled.x);
   
   // Sample original texture with UV offset for depth
   vec2 distorted_uv = uv + 0.02*vec2(wave1, wave2);
   vec4 shifted_tex = Texel(texture, texture_coords + distorted_uv*0.1);
   
   // Color transformation
   vec3 highlight = vec3(1.2, 0.9, 1.1);
   vec3 shadow = vec3(0.4, 0.6, 0.8);
   vec3 effect = mix(shadow, highlight, pattern);
   
   // Blend with original using luminance
   float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
   tex.rgb = mix(tex.rgb, tex.rgb * effect, 0.6 + 0.2*lum);
   
   return dissolve_mask(tex*colour, texture_coords, uv);
}

extern PRECISION vec2 mouse_screen_pos;
extern PRECISION float hovering;
extern PRECISION float screen_scale;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
   if (hovering <= 0.){
       return transform_projection * vertex_position;
   }
   float mid_dist = length(vertex_position.xy - 0.5*love_ScreenSize.xy)/length(love_ScreenSize.xy);
   vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy)/screen_scale;
   float scale = 0.2*(-0.03 - 0.3*max(0., 0.3-mid_dist))
               *hovering*(length(mouse_offset)*length(mouse_offset))/(2. -mid_dist);

   return transform_projection * vertex_position + vec4(0,0,0,scale);
}
#endif
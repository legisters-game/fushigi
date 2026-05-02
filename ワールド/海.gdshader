shader_type spatial;

// ===== TEXTURES =====
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// ===== COLORS =====
uniform vec3 base_tint_color : source_color = vec3(0.25, 0.7, 0.9);
uniform vec3 deep_color      : source_color = vec3(0.0, 0.2, 0.35);

// ===== WAVE =====
uniform float sea_height = 0.6;
uniform float sea_speed  = 1.0;
uniform float sea_freq   = 0.1;

// ===== REFRACTION =====
uniform float refraction_strength = 0.03;

// ===== NOISE =====
uniform float noise_scale = 2.0;
uniform float noise_speed = 0.5;

// ===== PBR =====
uniform float roughness = 0.05;
uniform float specular  = 0.9;


uniform samplerCube sky_cubemap;

uniform float reflection_strength = 0.6;
uniform float fresnel_power = 5.0;

uniform float specular_intensity = 1.5;
uniform float specular_sharpness = 64.0;

// ===== NOISE FUNCTIONS =====
float hash(vec2 p){
    return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453);
}

float noise(vec2 p){
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f*f*(3.0-2.0*f);

    float a = hash(i);
    float b = hash(i + vec2(1.0,0.0));
    float c = hash(i + vec2(0.0,1.0));
    float d = hash(i + vec2(1.0,1.0));

    return mix(mix(a,b,f.x), mix(c,d,f.x), f.y);
}

// ===== VERTEX =====
varying vec3 world_pos;

void vertex(){
    vec3 wp = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;

    float wave =
        sin(wp.x * sea_freq + TIME * sea_speed) +
        cos(wp.z * sea_freq + TIME * sea_speed);

    wave *= sea_height;

    VERTEX.y += wave;
    world_pos = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
}

// ===== FRAGMENT =====
void fragment(){
	float dist = length(VERTEX);
	float lod = clamp(dist * 0.2, 0.0, 1.0);
	
    // ===== ノイズ追加 =====
    vec2 n_uv = world_pos.xz * noise_scale + TIME * noise_speed;

    float n1 = noise(n_uv);
    float n2 = noise(n_uv * mix(2.0, 1.0, lod));
	float n3 = noise(n_uv * mix(4.0, 1.0, lod));
	
	float detail =
      n1 * 0.6
    + n2 * mix(0.3, 0.15, lod)
    + n3 * mix(0.1, 0.0, lod);

// コントラストも抑える
	detail = pow(detail, mix(1.2, 1.0, lod));
	detail *= ( lod);

	float normal_strength = mix(1.5, 0.6, lod);
	
    // ===== 法線 =====
    vec3 normal = normalize(vec3(
    dFdx(world_pos.y + detail * normal_strength),
    1.0,
    dFdy(world_pos.y + detail * normal_strength)
));

    NORMAL = (VIEW_MATRIX * vec4(normal,0.0)).xyz;

    // ===== 屈折 =====
    vec2 offset = NORMAL.xy * refraction_strength;
    vec2 uv = SCREEN_UV + offset;

    vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;

    // ===== フレネル =====
    float fresnel = pow(1.0 - dot(normalize(VIEW), NORMAL), 5.0);

    // ===== 水カラー =====
    vec3 water_color = mix(base_tint_color, deep_color, fresnel * 0.4);

    // ===== 合成 =====
    vec3 final_color = mix(screen_color, water_color, 0.2 + fresnel * 0.3);

    // ===== 視線ベクトル =====
vec3 view_dir = normalize(-VIEW);

// ===== フレネル（反射用に再計算）=====
float fresnel_ref = pow(1.0 - dot(view_dir, NORMAL), fresnel_power);

// ===== 反射ベクトル =====
vec3 refl_dir = reflect(view_dir, NORMAL);

// ===== 環境反射 =====
vec3 reflection = texture(sky_cubemap, refl_dir).rgb;

// ===== スペキュラ =====
vec3 light_dir = normalize(vec3(0.3, 1.0, 0.2)); // 仮の太陽方向
float spec = pow(max(dot(reflect(-light_dir, NORMAL), view_dir), 0.0), specular_sharpness);
spec *= (1.0 - lod);

// ノイズでキラキラさせる（重要）
spec *= 0.7 + detail * 0.6;

vec3 specular_highlight = vec3(spec * specular_intensity);

// ===== 合成 =====
vec3 combined =
    mix(final_color, reflection, fresnel_ref * reflection_strength)
    + specular_highlight * fresnel_ref;

ALBEDO = combined;

// ===== PBR =====
ROUGHNESS = roughness;
SPECULAR  = specular;
}
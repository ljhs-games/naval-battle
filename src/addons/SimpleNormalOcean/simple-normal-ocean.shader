shader_type spatial;
render_mode cull_back, blend_mix;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_white;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel;
uniform sampler2D texture_normal_1 : hint_normal;
uniform vec2 normal_1_time;
uniform sampler2D texture_normal_2 : hint_normal;
uniform vec2 normal_2_time;
uniform sampler2D texture_normal_3 : hint_normal;
uniform vec2 normal_3_time;
uniform float normal_scale : hint_range(-16,16);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform vec3 uv3_scale;
uniform vec3 uv3_offset;


void vertex() {
//	UV=UV*uv1_scale.xy+uv1_offset.xy+UV*uv2_scale.xy+uv2_offset.xy+UV*uv3_scale.xy+uv3_offset.xy;
	UV=UV*(uv1_scale.xy + vec2(sin(UV.x/20.0)*100.0, 0.0))+uv1_offset.xy+UV*uv2_scale.xy+uv2_offset.xy+UV*uv3_scale.xy+uv3_offset.xy;
//	VERTEX.y += sin(TIME + VERTEX.x);
}




void fragment() {
	float time = 2.0*TIME + sin(TIME*0.5);
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	vec2 normal_1_uv = base_uv + vec2(time * normal_1_time.x, time * normal_1_time.y);
	vec2 normal_2_uv = base_uv + vec2(time * normal_2_time.x, time * normal_2_time.y);
//	vec2 normal_1_uv = base_uv + vec2(TIME * normal_1_time.x + (abs(sin(base_uv.y*0.2))*sin(base_uv.x*0.5))*4.0, TIME * normal_1_time.y);
//	vec2 normal_2_uv = base_uv + vec2(TIME * normal_2_time.x + cos(base_uv.x*0.5 + (TIME/5.0))*50.0, TIME * normal_2_time.y);
	vec2 normal_3_uv = base_uv + vec2(time * normal_3_time.x, time * normal_3_time.y);
	NORMALMAP = texture(texture_normal_1,normal_1_uv).rgb + texture(texture_normal_2,normal_2_uv).rgb + texture(texture_normal_3,normal_3_uv).rgb;
//	NORMALMAP = texture(texture_normal_1,normal_1_uv).rgb + texture(texture_normal_2,normal_2_uv).rgb;
	
	NORMALMAP_DEPTH = normal_scale;
}

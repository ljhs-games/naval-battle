shader_type spatial;
render_mode skip_vertex_transform, cull_front, blend_mix;

uniform vec4 albedo : hint_color;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_normal_1 : hint_normal;
uniform vec2 normal_1_time;
uniform sampler2D texture_normal_2 : hint_normal;
uniform vec2 normal_2_time;
uniform sampler2D texture_normal_3 : hint_normal;
uniform vec2 normal_3_time;
uniform float normal_scale : hint_range(-16,16);
uniform vec3 uv1_scale;
uniform vec3 uv2_scale;
uniform vec3 uv3_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_offset;
uniform vec3 uv3_offset;
uniform sampler2D texture_metallic : hint_white;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel;

//uniform sampler2D waves;

//uniform float fade_normal_distance = 900.0;
uniform float resolution = 10.0;
//uniform float n_max = 1.5;
//uniform float n_min = 1.0;
//uniform float fresnel_bias = 1.0;
//uniform float fresnel_scale = 1.0;
//uniform float fresnel_power = 1.0;

//uniform float speed = 7.81;

uniform float alpha = 0.9;
uniform float PI = 3.14159;

//uniform sampler2D noise;
//uniform vec4 noise_params;

/*This uniform contains data that changes noise.
X- The amplitude of the noise.
Y- The frequency of the noise.
Z- The propagation speed of the noise.
W- Whether to use noise. Values greater than 0 means yes.
*/
//uniform vec4 sky_color: hint_color;
//uniform vec4 horizon_color: hint_color;
//uniform float horizon_falloff_dist = 50.0;
//uniform vec4 water_color: hint_color;

uniform float project_bias = 1.2;

mat3 getRotation(mat4 camera) {
	return mat3(
		camera[0].xyz,
		camera[1].xyz,
		camera[2].xyz
	);
}
vec3 getPosition(mat4 camera) {
	return -camera[3].xyz * getRotation(camera);
}

vec2 getImagePlan(mat4 projection, vec2 uv) {
	float focal = projection[0].x * project_bias;
	float aspect = projection[1].y * project_bias;
	
	return vec2((uv.x - 0.5) * aspect, (uv.y - 0.5) * focal);}
vec3 getCamRay(mat4 projection, mat3 rotation, vec2 screenUV) {
	return vec3(screenUV.xy, projection[0].x) * rotation;}
vec3 interceptPlane(vec3 source, vec3 dir, vec4 plane) {
	float dist = (-plane.w - dot(plane.xyz, source)) / dot(plane.xyz, dir);
	if(dist < 0.0) {
		return source + dir * dist;
	} else {
		return -(vec3(source.x, plane.w, source.z) + vec3(dir.x, plane.w, dir.z) * 100000.0);
	}
}

vec3 computeProjectedPosition(in vec3 cam_pos, in mat3 cam_rot, in mat4 projection, in vec2 uv) {
	vec2 screenUV = getImagePlan(projection, uv);
	
	vec3 ray = getCamRay(projection, cam_rot, screenUV);
	return interceptPlane(cam_pos, ray, vec4(0.0,-1.0,0.0,0.0));
}

//float noise3D(vec3 p) {
//	float iz = floor(p.z);
//	float fz = fract(p.z);
//	vec2 a_off = vec2(0.852, 29.0) * iz*0.643;
//	vec2 b_off = vec2(0.852, 29.0) * (iz+1.0)*0.643;
//	float a = texture(noise, p.xy + a_off).r;
//	float b = texture(noise, p.xy + b_off).r;
//
//	return mix(a, b, fz);
//}

//vec3 wave_interpolated(vec2 pos, float time, float grid_distance) {
//	vec3 new_p = vec3(pos.x, 0.0, pos.y);
//
//	float w, amp, steep, phase;
//	vec2 dir;
//	for(int i = 0; i < textureSize(waves, 0).y; i++) {
//		amp = texelFetch(waves, ivec2(0, i), 0).r;
//		if(amp == 0.0) continue;
//
//		dir = vec2(texelFetch(waves, ivec2(2, i), 0).r, texelFetch(waves, ivec2(3, i), 0).r);
//		w = texelFetch(waves, ivec2(4, i), 0).r;
//		steep = texelFetch(waves, ivec2(1, i), 0).r /(w*amp);
//		phase = 2.0 * w;
//
//		float W = dot(w*dir, pos) + phase*time;
//
//		float dim_factor;
//		{
//			float x = (((2.0*PI)/w)/grid_distance);
//			float a = n_min;
//			float b = n_max;
//			float x_bar = clamp( (x-a)/(b-a), 0.0, 1.0);
//			dim_factor = 3.0*pow(x_bar, 2.0) - 2.0*pow(x_bar, 3.0);
//		}
//
//
//		new_p.xz += (steep*amp * dir * cos(W))*dim_factor;
//		new_p.y += (amp * sin(W))*dim_factor;
//	}
////	if(noise_params.w > 0.0)
////		new_p.y += noise3D(vec3(pos.xy*noise_params.y, time*noise_params.z))*noise_params.x;
//	return new_p;
//}

//vec3 wave(vec2 pos, float time) {
//	vec3 new_p = vec3(pos.x, 0.0, pos.y);
//
//	float w, amp, steep, phase;
//	vec2 dir;
//	for(int i = 0; i < textureSize(waves, 0).y; i++) {
//		amp = texelFetch(waves, ivec2(0, i), 0).r;
//		if(amp == 0.0) continue;
//
//		dir = vec2(texelFetch(waves, ivec2(2, i), 0).r, texelFetch(waves, ivec2(3, i), 0).r);
//		w = texelFetch(waves, ivec2(4, i), 0).r;
//		steep = texelFetch(waves, ivec2(1, i), 0).r /(w*amp);
//		phase = 2.0 * w;
//
//		float W = dot(w*dir, pos) + phase*time;
//
//		new_p.xz += steep*amp * dir * cos(W);
//		new_p.y += amp * sin(W);
//	}
//	if(noise_params.w > 0.0)
//		new_p.y += noise3D(vec3(pos.xy*noise_params.y, time*noise_params.z))*noise_params.x;
//	return new_p;
//}

//vec3 wave_normal(vec2 pos, float time, float res) {
//
//	vec3 right = wave(pos + vec2(res, 0.0), time);
//	vec3 left = wave(pos - vec2(res, 0.0), time);
//	vec3 down = wave(pos - vec2(0.0, res), time);
//	vec3 up = wave(pos + vec2(0.0, res), time);
//
//	return -normalize(cross(right-left, down-up));
//}

varying vec2 vert_coord;
varying float vert_dist;

varying vec3 eyeVector;
//varying float grid_distance;

void vertex() {
	vec2 screen_uv = VERTEX.xz + 0.5;

	mat4 projected_cam_matrix = INV_CAMERA_MATRIX;

	mat3 camRotation = getRotation(projected_cam_matrix);
	vec3 camPosition = getPosition(projected_cam_matrix);

	VERTEX = computeProjectedPosition(camPosition, camRotation, PROJECTION_MATRIX, screen_uv);

	vec2 pre_displace = VERTEX.xz;
	vec3 next_point = computeProjectedPosition(camPosition, camRotation, PROJECTION_MATRIX, screen_uv + vec2(1.0 / resolution));
	float grid_distance = distance(VERTEX, next_point);
//	VERTEX = wave_interpolated(VERTEX.xz, TIME * speed, grid_distance);
//	VERTEX = wave(VERTEX.xz, TIME * speed);
	if( any(lessThan(screen_uv, vec2(0.0))) || any(greaterThan(screen_uv, vec2(1.0))) )
		VERTEX.xz = pre_displace;

	eyeVector = normalize(VERTEX - camPosition);
	vert_coord = VERTEX.xz;
	VERTEX = (INV_CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vert_dist = length(VERTEX);
	UV=UV*(uv1_scale.xy + vec2(sin(UV.x/20.0)*100.0, 0.0))+uv1_offset.xy+UV*uv2_scale.xy+uv2_offset.xy+UV*uv3_scale.xy+uv3_offset.xy;
}

//float fresnel(float n1, float n2, float eye_dot_normm) {
//	float R0 = pow((n1 - n2) / (n1+n2), 2);
//	return max(0.0, min(1.0, fresnel_bias + fresnel_scale * pow(1.0 + eye_dot_normm, fresnel_power)));
////	return R0 + (1.0 - R0)*pow(1.0 - cos_theta, 5);
//}

void fragment() {
//	if(vert_dist >= fade_normal_distance) {
//		NORMAL = vec3(0.0, -1.0, 0.0);
//	} else {
//		NORMAL = wave_normal(vert_coord, TIME * speed, vert_dist/80.0);
//		NORMAL = mix(NORMAL, vec3(0, -1.0, 0), min(vert_dist/fade_normal_distance, 1));
//	}
	
//	float eye_dot_norm = dot(eyeVector, NORMAL);
//	float n1 = 1.0, n2 = 1.3333;
	
//	float reflectiveness = fresnel(n1, n2, eye_dot_norm);
	
	// manually create reflect map, 
//	vec3 reflect_global = mix(sky_color.rgb, horizon_color.rgb, min(vert_dist/fade_normal_distance, 1)/horizon_falloff_dist);
//	vec3 refract_global = water_color.rgb;
	
//	ALBEDO = mix(refract_global, reflect_global, reflectiveness);
	float time = 2.0*TIME + sin(TIME*0.5);
	vec2 base_uv = UV;
//	vec4 albedo_tex = texture(texture_albedo,base_uv);
//	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALBEDO = albedo.rgb;
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
	ALPHA = alpha;
}
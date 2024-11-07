#version 300 es

#define MAX_LIGHTS 16

// struct definitions
struct AmbientLight {
    vec3 color;
    float intensity;
};

struct DirectionalLight {
    vec3 direction;
    vec3 color;
    float intensity;
};

struct PointLight {
    vec3 position;
    vec3 color;
    float intensity;
};

struct Material {
    vec3 kA;
    vec3 kD;
    vec3 kS;
    float shininess;
};


// an attribute will receive data from a buffer
in vec3 a_position;
in vec3 a_normal;

// camera position
uniform vec3 u_eye;

// transformation matrices
uniform mat4x4 u_m;
uniform mat4x4 u_v;
uniform mat4x4 u_p;


// lights and materials
uniform AmbientLight u_lights_ambient[MAX_LIGHTS];
uniform DirectionalLight u_lights_directional[MAX_LIGHTS];
uniform PointLight u_lights_point[MAX_LIGHTS];

uniform Material u_material;

// shading output
out vec4 o_color;

// Shades an ambient light and returns this light's contribution
vec3 shadeAmbientLight(Material material, AmbientLight light) {

    return material.kA * light.color * light.intensity;
}

// Shades a directional light and returns its contribution
vec3 shadeDirectionalLight(Material material, DirectionalLight light, vec3 normal, vec3 eye, vec3 vertex_position) {

    vec3 A = normalize(normal);
    vec3 B = normalize(light.direction);
    vec3 C = normalize(eye - vertex_position);
    
    float AB = max(dot(A, B), 0.0);  

    vec3 D = material.kD * light.color * light.intensity * AB;
    
    
    // Specular 
    vec3 ref = reflect(B, A);
    vec3 S = material.kS * light.color * light.intensity * pow(max(dot(ref, C), 0.0), material.shininess);

    return D + S;

}

// Shades a point light and returns its contribution
vec3 shadePointLight(Material material, PointLight light, vec3 normal, vec3 eye, vec3 vertex_position) {
    vec3 A = normalize(normal); 
    vec3 B = normalize(vertex_position - light.position);
    vec3 C = normalize(eye - vertex_position);
    float d = length(light.position - vertex_position);   
    float at = 1.0 / (1.0 + 0.32 * d + 0.77 * d * d);

    float AB = max(dot(A, -B), 0.0);  
    vec3 D = material.kD * light.color * light.intensity * AB * at;
    
    
    vec3 ref = reflect(B, A);
    float RC = max(dot(ref, C), 0.0);  

    vec3 S = material.kS * light.color * light.intensity * pow(RC, material.shininess) * at;

    return D + S;
}

void main() {

    mat3 n_m = transpose(inverse(mat3(u_m)));
    vec3 normal = (n_m * a_normal);
    vec3 vertex_position = (u_m * vec4(a_position, 1.0)).xyz;
    vec3 color = vec3(0.0);
    

    for (int i = 0; i < MAX_LIGHTS; i++) {
        color += shadeAmbientLight(u_material, u_lights_ambient[i]);
    }

    // Accumulate directional lights
    for (int i = 0; i < MAX_LIGHTS; i++) {
        color += shadeDirectionalLight(u_material, u_lights_directional[i], normal, u_eye, vertex_position);
    }

    // Accumulate point lights
    for (int i = 0; i < MAX_LIGHTS; i++) {
        color += shadePointLight(u_material, u_lights_point[i], normal, u_eye, vertex_position);
    }
    
    o_color = vec4(color, 1.0);
    gl_Position = u_p * u_v * u_m * vec4(a_position, 1.0);
}
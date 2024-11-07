#version 300 es

// an attribute will receive data from a buffer
in vec3 a_position;
in vec3 a_normal;

// transformation matrices
uniform mat4x4 u_m;
uniform mat4x4 u_v;
uniform mat4x4 u_p;

// output to fragment stage
// TODO: Create any needed `out` variables here
out vec3 normal;
out vec3 vertex_position;


void main() {

    // TODO: PHONG SHADING
    // TODO: Implement the vertex stage
    // TODO: Transform positions and normals
    // NOTE: Normals are transformed differently from positions. Check the book and resources.
    // TODO: Create new `out` variables above outside of main() to store any results

    mat3 n_matrix = transpose(inverse(mat3(u_m)));
    normal = n_matrix * a_normal; // Transform normal
    vertex_position = vec3(u_m * vec4(a_position, 1.0)); // Transform position
    gl_Position = u_p * u_v * u_m * vec4(a_position, 1.0);
}

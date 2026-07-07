#version 300 es
// Rounded screen corners — final-pass screen shader.
// Fades the framebuffer to black outside a rounded rect, giving the panel
// soft "bezel" corners. Applies over everything, fullscreen included.
// Must be GLSL ES 3.00: Hyprland links it against its #version 300 es
// vertex shader (tex300.vert) and the versions have to match.
// fullSize = monitor size in physical pixels (per monitor, set by Hyprland).
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
uniform vec2 fullSize;

out vec4 fragColor;

void main() {
    float radius = 24.0; // corner radius in physical pixels

    vec2 pos  = v_texcoord * fullSize;
    vec2 edge = min(pos, fullSize - pos); // distance to the two nearest edges

    vec4 pixColor = texture(tex, v_texcoord);

    if (edge.x < radius && edge.y < radius) {
        float d = length(vec2(radius) - edge);
        // ~1.5px antialiased falloff to black
        pixColor *= smoothstep(radius + 0.5, radius - 1.0, d);
    }

    fragColor = pixColor;
}

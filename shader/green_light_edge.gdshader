shader_type spatial;

// 方法1：使用统一的纹理采样方式（推荐）
uniform sampler2D albedo_texture : source_color;
uniform vec4 glow_color : source_color = vec4(0, 1, 0, 1);
uniform float glow_width = 0.1;

void fragment() {
    // 正确的纹理采样方式
    vec4 tex_color = texture(albedo_texture, UV);
    float edge = smoothstep(0.5 - glow_width, 0.5 + glow_width, tex_color.a);
    ALBEDO = tex_color.rgb;
    EMISSION = glow_color.rgb * edge;
}
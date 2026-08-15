shader_type canvas_item;
//该文件由AI辅助完成
uniform vec2 circle_center = vec2(0.5, 0.5);
uniform float circle_radius = 0.15;
uniform vec4 outside_color : source_color = vec4(0.5, 0.0, 0.0, 0.5);

void fragment() {
    float dist = distance(UV, circle_center);
    if (dist > circle_radius) {
        COLOR = outside_color;
    } else {
        COLOR = vec4(0.0);
        discard;
    }
}
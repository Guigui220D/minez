const Vector2f = @import("sfml").system.Vector2f;

name: []const u8,
dig_time: f32,
texture_name: [:0]const u8,
score: i32 = 0,

text_a: Vector2f = undefined,
text_b: Vector2f = undefined,
text_c: Vector2f = undefined,
text_d: Vector2f = undefined,

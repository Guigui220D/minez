const Vector2f = @import("sfml").system.Vector2f;
const block_reg = @import("block_register.zig");

const WFCWeights = [block_reg.BLOCK_COUNT]f64;
pub const default_weights = [1]f64{1.0} ** block_reg.BLOCK_COUNT;

name: []const u8,
dig_time: f32,
texture_name: [:0]const u8,
score: i32 = 0,

// WFC weights
wfc: WFCWeights,

text_a: Vector2f = undefined,
text_b: Vector2f = undefined,
text_c: Vector2f = undefined,
text_d: Vector2f = undefined,

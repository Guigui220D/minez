const std = @import("std");

const Vector2f = @import("sfml").system.Vector2f;
const block_reg = @import("block_register.zig");

const wfc = @import("wfc").Wfc(block_reg.BLOCK_COUNT, f64);

name: []const u8,
dig_time: f32,
texture_name: [:0]const u8,
score: i32 = 0,

// WFC weights
wfc_up: wfc.VecT,
wfc_down: wfc.VecT,
wfc_diagup: wfc.VecT,
wfc_diagdown: wfc.VecT,
wfc_left: wfc.VecT,
wfc_right: wfc.VecT,

text_a: Vector2f = undefined,
text_b: Vector2f = undefined,
text_c: Vector2f = undefined,
text_d: Vector2f = undefined,

pub fn format(
    self: @This(),
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    _ = options;
    _ = fmt;
    try writer.print("Block {s}({any}{any}{any}{any}{any}{any})", .{
        self.name,
        self.wfc_up,
        self.wfc_down,
        self.wfc_diagup,
        self.wfc_diagdown,
        self.wfc_left,
        self.wfc_right,
    });
}

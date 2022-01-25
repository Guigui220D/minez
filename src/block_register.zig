const std = @import("std");

const Block = @import("Block.zig");
const atlas = @import("atlas.zig");

pub var ALL_BLOCKS = [_]Block{ AIR, DIRT, STONE, IRON, DIAMOND, STRONK };

pub const AIR = Block { .dig_time = -1, .texture_name = "res/air.png" };
pub const DIRT = Block { .dig_time = 0.2, .texture_name = "res/dirt.png" };
pub const STONE = Block { .dig_time = 0.5, .texture_name = "res/stone.png" };
pub const IRON = Block { .dig_time = 0.6, .texture_name = "res/iron.png", .score = 100 };
pub const DIAMOND = Block { .dig_time = 1, .texture_name = "res/diamond.png", .score = 300 };
pub const STRONK = Block { .dig_time = std.math.f32_max, .texture_name = "res/stronk.png" };

pub fn loadAllBlockTextures(builder: *atlas.Builder) !void {
    for (ALL_BLOCKS) |*block| {
        var rect = try builder.registerLoadAndGetTextureRect(block.*.texture_name);
        block.*.text_a = .{ .x = rect.left, .y = rect.top };
        block.*.text_b = .{ .x = rect.left + rect.width, .y = rect.top };
        block.*.text_c = .{ .x = rect.left + rect.width, .y = rect.top + rect.height };
        block.*.text_d = .{ .x = rect.left, .y = rect.top + rect.height };
    }
}
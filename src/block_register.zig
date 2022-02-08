const std = @import("std");

const Block = @import("Block.zig");
const atlas = @import("atlas.zig");

pub var ALL_BLOCKS = [_]Block{ AIR, DIRT, STONE1, STONE2, STONE3, STONE4, IRON, GOLD, DIAMOND, STRONK };

pub const AIR = Block { .dig_time = -1, .texture_name = "air.png" };
pub const DIRT = Block { .dig_time = 0.2, .texture_name = "dirt.png" };
pub const STONE1 = Block { .dig_time = 0.5, .texture_name = "stone1.png" };
pub const STONE2 = Block { .dig_time = 0.6, .texture_name = "stone2.png" };
pub const STONE3 = Block { .dig_time = 0.9, .texture_name = "stone3.png" };
pub const STONE4 = Block { .dig_time = 1.2, .texture_name = "stone4.png" };
pub const IRON = Block { .dig_time = 0.6, .texture_name = "iron.png", .score = 100 };
pub const GOLD = Block { .dig_time = 0.7, .texture_name = "gold.png", .score = 200 };
pub const DIAMOND = Block { .dig_time = 1, .texture_name = "diamond.png", .score = 400 };
pub const STRONK = Block { .dig_time = std.math.f32_max, .texture_name = "stronk.png" };

pub fn loadAllBlockTextures(builder: *atlas.Builder) !void {
    for (ALL_BLOCKS) |*block| {
        var rect = try builder.registerLoadAndGetTextureRect(block.texture_name);
        block.text_a = .{ .x = rect.left, .y = rect.top };
        block.text_b = .{ .x = rect.left + rect.width, .y = rect.top };
        block.text_c = .{ .x = rect.left + rect.width, .y = rect.top + rect.height };
        block.text_d = .{ .x = rect.left, .y = rect.top + rect.height };
    }
}
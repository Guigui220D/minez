const std = @import("std");

const Block = @import("Block.zig");
const atlas = @import("atlas.zig");

pub var ALL_BLOCKS = blk: {
    const blocks = @import("blocks/blocks.zig");
    const block_decls = @typeInfo(blocks).Struct.decls;

    var ret: [block_decls.len]Block = undefined;

    for (block_decls, 0..) |block, i| {
        const decl = @field(blocks, block.name);

        ret[i].name = block.name;
        ret[i].dig_time = decl.dig_time;
        ret[i].texture_name = decl.texture;

        if (@hasDecl(decl, "score"))
            ret[i].score = decl.score;
    }

    break :blk ret;
};

pub fn loadAllBlockTextures(builder: *atlas.Builder) !void {
    for (&ALL_BLOCKS) |*block| {
        const rect = try builder.registerLoadAndGetTextureRect(block.texture_name);
        block.text_a = .{ .x = rect.left, .y = rect.top };
        block.text_b = .{ .x = rect.left + rect.width, .y = rect.top };
        block.text_c = .{ .x = rect.left + rect.width, .y = rect.top + rect.height };
        block.text_d = .{ .x = rect.left, .y = rect.top + rect.height };
    }
}

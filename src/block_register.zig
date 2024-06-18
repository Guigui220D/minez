const std = @import("std");

const Block = @import("Block.zig");
const atlas = @import("atlas.zig");

pub const BLOCK_COUNT: usize = @typeInfo(@import("blocks/blocks.zig")).Struct.decls.len;

pub var ALL_BLOCKS: [BLOCK_COUNT]Block = blk: {
    const blocks = @import("blocks/blocks.zig");
    const block_decls = @typeInfo(blocks).Struct.decls;

    var ret: [BLOCK_COUNT]Block = undefined;

    // Create list of blocks
    for (block_decls, 0..) |block, i| {
        const decl = @field(blocks, block.name);

        ret[i].name = block.name;
        ret[i].dig_time = decl.dig_time;
        ret[i].texture_name = decl.texture;

        if (@hasDecl(decl, "score"))
            ret[i].score = decl.score;
    }

    // Assign the WFC weights
    for (block_decls, 0..) |block, i| {
        const decl = @field(blocks, block.name);

        ret[i].wfc_horizontal = Block.default_weights;
        ret[i].wfc_vertical = Block.default_weights;

        if (@hasDecl(decl, "wfc")) {
            const wfc = decl.wfc;
            if (@hasDecl(wfc, "any")) {
                const weights = wfc.any;
                for (@typeInfo(weights).Struct.decls) |weight| {
                    var name = weight.name;

                    const wvalue: f64 = @field(weights, name);

                    if (std.ascii.eqlIgnoreCase("self", name))
                        name = block.name;

                    // Find the id for the name
                    const id: usize = for (&ret, 0..) |b, j| {
                        if (std.ascii.eqlIgnoreCase(b.name, name))
                            break j;
                    } else @panic("Block with name " ++ name ++ " doesn't exist");

                    ret[i].wfc_horizontal[id] = wvalue;
                    ret[i].wfc_vertical[id] = wvalue;
                }
            }
        }
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

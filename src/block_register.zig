const std = @import("std");

const Block = @import("Block.zig");
const atlas = @import("atlas.zig");

pub const BLOCK_COUNT: usize = @typeInfo(@import("blocks/blocks.zig")).Struct.decls.len;

pub const BLOCK_NAMES = blk: {
    const blocks = @import("blocks/blocks.zig");
    const block_decls = @typeInfo(blocks).Struct.decls;

    var fields: []const std.builtin.Type.EnumField = &.{};

    for (block_decls, 0..) |block, i| {
        fields = fields ++ [_]std.builtin.Type.EnumField{.{
            .name = block.name,
            .value = i,
        }};
    }

    break :blk @Type(.{ .Enum = .{
        .tag_type = usize,
        .fields = fields,
        .decls = &.{},
        .is_exhaustive = true,
    } });
};

pub var ALL_BLOCKS: [BLOCK_COUNT]Block = blk: {
    const groups = @import("groups.zig");
    const blocks = @import("blocks/blocks.zig");
    const block_decls = @typeInfo(blocks).Struct.decls;

    var ret: [BLOCK_COUNT]Block = undefined;

    // Create list of blocks
    for (block_decls, 0..) |block, i| {
        const decl = @field(blocks, block.name);

        ret[i].name = block.name;
        // Temporary (TODO)
        ret[i].dig_time = @as(f32, decl.dig_time) / 10000.0;
        ret[i].texture_name = decl.texture;

        if (@hasDecl(decl, "score"))
            ret[i].score = decl.score;

        for (groups.any) |class|
            @field(ret[i], "wfc_" ++ class) = Block.default_weights;
    }

    // Assign the WFC weights
    for (block_decls, 0..) |block, i| {
        const decl = @field(blocks, block.name);

        if (@hasDecl(decl, "wfc")) {
            const wfc = decl.wfc;
            for (@typeInfo(wfc).Struct.decls) |group_decl| {
                const group = @field(wfc, group_decl.name);

                if (!@hasDecl(groups, group_decl.name))
                    @compileError("Unknown weight group: " ++ group_decl.name);

                for (@typeInfo(group).Struct.decls) |weight| {
                    var name = weight.name;

                    const wvalue: f64 = @field(group, name);

                    if (std.ascii.eqlIgnoreCase("self", name))
                        name = block.name;

                    // Find the id for the name
                    const id: usize = for (&ret, 0..) |b, j| {
                        if (std.ascii.eqlIgnoreCase(b.name, name))
                            break j;
                    } else {
                        if (std.ascii.eqlIgnoreCase("all", name)) {
                            for (@field(groups, group_decl.name)) |weight_vec| {
                                const full_name = "wfc_" ++ weight_vec;
                                const opp_full_name = "wfc_" ++ @field(groups, "opp_" ++ weight_vec);

                                for (&@field(ret[i], full_name)) |*w|
                                    w.* = wvalue;
                                for (&ret) |*b|
                                    @field(b, opp_full_name)[i] = wvalue;
                            }
                            continue;
                        } else @panic("Block with name " ++ name ++ " doesn't exist");
                    };

                    for (@field(groups, group_decl.name)) |weight_vec| {
                        const full_name = "wfc_" ++ weight_vec;
                        const opp_full_name = "wfc_" ++ @field(groups, "opp_" ++ weight_vec);

                        //if (@field(ret[i], full_name)[id] != 1.0 or @field(ret[id], full_name)[i] != 1.0)
                        //    @compileError("Neighbors " ++ ret[i].name ++ " and " ++ ret[id].name ++ " have redundant weights!");

                        //if (@field(ret[i], full_name)[id] != 0.0 or @field(ret[id], full_name)[i] != 0.0)
                        //    @compileError("Neighbors " ++ ret[i].name ++ " and " ++ ret[id].name ++ " have redundant weights!");

                        @field(ret[i], full_name)[id] = wvalue;
                        @field(ret[id], opp_full_name)[i] = wvalue;
                    }
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

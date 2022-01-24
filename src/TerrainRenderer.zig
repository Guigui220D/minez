/// A terrain has a reference to this structure to handle its rendering

const Terrain = @import("Terrain.zig");
const block_register = @import("block_register.zig");
const atlas = @import("atlas.zig");
const std = @import("std");
const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.graphics;
    usingnamespace sf.system;
};

pub const TERRAIN_QUAD_SIZE = 32;
const vcount = 4 * Terrain.TERRAIN_WIDTH * Terrain.TERRAIN_HEIGHT;

buffer: sf.VertexBuffer,
vdata: [vcount]sf.Vertex,
scroll: f32,

/// Creates a new renderer (needs to be destroyed)
pub fn create() !@This() {
    var new: @This() = undefined;
    const vslice = &new.vdata;

    for (vslice) |*v|
        v.color = sf.Color.White;

    new.buffer = try sf.VertexBuffer.createFromSlice(vslice, .Quads, .Dynamic);
    errdefer new.buffer.destroy();

    new.scroll = 0;

    return new;
}
/// Destroys the renderer
pub fn destroy(self: *@This()) void {
    self.buffer.destroy();
}

/// Updates all the vertices when the terrain changes
pub fn updateVertices(self: *@This(), data: Terrain.DataT) void {
    const pslice = sf.Vertex.verticesAsPrimitives(&self.vdata, .Quads);

    for (pslice) |*quad, i| {
        const x = i % Terrain.TERRAIN_WIDTH;
        const y = i / Terrain.TERRAIN_WIDTH;

        quad.a.position = sf.Vector2f{ .x = @intToFloat(f32, x + 0) * TERRAIN_QUAD_SIZE, .y = @intToFloat(f32, y + 0) * TERRAIN_QUAD_SIZE };
        quad.b.position = sf.Vector2f{ .x = @intToFloat(f32, x + 1) * TERRAIN_QUAD_SIZE, .y = @intToFloat(f32, y + 0) * TERRAIN_QUAD_SIZE };
        quad.c.position = sf.Vector2f{ .x = @intToFloat(f32, x + 1) * TERRAIN_QUAD_SIZE, .y = @intToFloat(f32, y + 1) * TERRAIN_QUAD_SIZE };
        quad.d.position = sf.Vector2f{ .x = @intToFloat(f32, x + 0) * TERRAIN_QUAD_SIZE, .y = @intToFloat(f32, y + 1) * TERRAIN_QUAD_SIZE };

        const block = block_register.ALL_BLOCKS[data[y][x]];
        quad.a.tex_coords = block.text_a;
        quad.b.tex_coords = block.text_b;
        quad.c.tex_coords = block.text_c;
        quad.d.tex_coords = block.text_d;
    }

    self.buffer.updateFromSlice(&self.vdata) catch @panic("updateFromSlice");
}

/// Draws the terrain on screen
pub fn draw(self: @This(), target: anytype) void {
    var transform = sf.Transform.Identity;
    transform.translate(sf.Vector2f{ .x = 0, .y = -self.scroll * TERRAIN_QUAD_SIZE });

    target.draw(self.buffer, .{ .transform = transform, .texture = atlas.texture });
}
//! A terrain has a reference to this structure to handle its rendering

const Terrain = @import("Terrain.zig");
const block_register = @import("block_register.zig");
const atlas = @import("atlas.zig");
const gui = @import("gui.zig");

const std = @import("std");
const sf = struct {
    const sfml = @import("sfml");
    pub usingnamespace sfml;
    pub usingnamespace sfml.graphics;
    pub usingnamespace sfml.system;
};

pub const QUAD_SIZE = 32;
const vcount = 4 * Terrain.WIDTH * Terrain.HEIGHT;

buffer: sf.VertexBuffer,
vdata: [vcount]sf.Vertex,
scroll: f32,
depth: f32,
texture: sf.Texture,

/// Creates a new renderer (needs to be destroyed)
pub fn create() !@This() {
    var new: @This() = undefined;
    const vslice = &new.vdata;

    for (vslice) |*v|
        v.color = sf.Color.White;

    new.buffer = try sf.VertexBuffer.createFromSlice(vslice, .Quads, .Dynamic);
    errdefer new.buffer.destroy();

    new.scroll = 0;
    new.depth = 0;

    new.texture = atlas.getTexture();

    return new;
}
/// Destroys the renderer
pub fn destroy(self: *@This()) void {
    self.buffer.destroy();
}

/// Updates all the vertices when the terrain changes
pub fn updateVertices(self: *@This(), data: Terrain.DataT) void {
    const pslice = sf.Vertex.verticesAsPrimitives(&self.vdata, .Quads);

    for (pslice, 0..) |*quad, i| {
        const x = i % Terrain.WIDTH;
        const y = i / Terrain.WIDTH;

        quad.a.position = sf.vector2f(@as(f32, @floatFromInt(x + 0)) * QUAD_SIZE, @as(f32, @floatFromInt(y + 0)) * QUAD_SIZE);
        quad.b.position = sf.vector2f(@as(f32, @floatFromInt(x + 1)) * QUAD_SIZE, @as(f32, @floatFromInt(y + 0)) * QUAD_SIZE);
        quad.c.position = sf.vector2f(@as(f32, @floatFromInt(x + 1)) * QUAD_SIZE, @as(f32, @floatFromInt(y + 1)) * QUAD_SIZE);
        quad.d.position = sf.vector2f(@as(f32, @floatFromInt(x + 0)) * QUAD_SIZE, @as(f32, @floatFromInt(y + 1)) * QUAD_SIZE);

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
    transform.translate(sf.Vector2f{ .x = 0, .y = -self.scroll * QUAD_SIZE });
    target.draw(self.buffer, .{ .transform = transform, .texture = self.texture });
}

pub fn getScroll(self: @This()) f32 {
    return self.depth + self.scroll;
}

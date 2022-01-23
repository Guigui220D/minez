/// A terrain has a reference to this structure to handle its rendering

const Terrain = @import("Terrain.zig");
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
        quad.b.position = sf.Vector2f{ .x = @intToFloat(f32, x + 0) * TERRAIN_QUAD_SIZE, .y = @intToFloat(f32, y + 1) * TERRAIN_QUAD_SIZE };
        quad.c.position = sf.Vector2f{ .x = @intToFloat(f32, x + 1) * TERRAIN_QUAD_SIZE, .y = @intToFloat(f32, y + 1) * TERRAIN_QUAD_SIZE };
        quad.d.position = sf.Vector2f{ .x = @intToFloat(f32, x + 1) * TERRAIN_QUAD_SIZE, .y = @intToFloat(f32, y + 0) * TERRAIN_QUAD_SIZE };

        switch (data[y][x]) {
            0 => {
                quad.a.color = sf.Color.Transparent;
                quad.b.color = sf.Color.Transparent;
                quad.c.color = sf.Color.Transparent;
                quad.d.color = sf.Color.Transparent;
            },
            1 => {
                quad.a.color = sf.Color.Red;
                quad.b.color = sf.Color.Blue;
                quad.c.color = sf.Color.Red;
                quad.d.color = sf.Color.Blue;
            },
            2 => {
                quad.a.color = sf.Color.Yellow;
                quad.b.color = sf.Color.Yellow;
                quad.c.color = sf.Color.Green;
                quad.d.color = sf.Color.Green;
            },
            else => {
                quad.a.color = sf.Color.Magenta;
                quad.b.color = sf.Color.Magenta;
                quad.c.color = sf.Color.Magenta;
                quad.d.color = sf.Color.Magenta;
            }
        }
    }

    self.buffer.updateFromSlice(&self.vdata) catch @panic("updateFromSlice");
}

/// Draws the terrain on screen
pub fn draw(self: @This(), target: anytype) void {
    var transform = sf.Transform.Identity;
    transform.translate(sf.Vector2f{ .x = 0, .y = -self.scroll * TERRAIN_QUAD_SIZE });

    target.draw(self.buffer, .{ .transform = transform });
}
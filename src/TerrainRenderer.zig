//! A terrain has a reference to this structure to handle its rendering

const Terrain = @import("Terrain.zig");
const block_register = @import("block_register.zig");
const atlas = @import("atlas.zig");
const gui = @import("gui.zig");

const std = @import("std");
const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.graphics;
    usingnamespace sf.system;
};

pub const QUAD_SIZE = 32;
const vcount = 4 * Terrain.WIDTH * Terrain.HEIGHT;

buffer: sf.VertexBuffer,
house_texture: sf.Texture,
house_sprite: sf.Sprite,
vdata: [vcount]sf.Vertex,
scroll: f32,
depth: f32,

/// Creates a new renderer (needs to be destroyed)
pub fn create() !@This() {
    var new: @This() = undefined;
    const vslice = &new.vdata;

    for (vslice) |*v|
        v.color = sf.Color.White;

    new.buffer = try sf.VertexBuffer.createFromSlice(vslice, .Quads, .Dynamic);
    errdefer new.buffer.destroy();

    new.house_texture = try sf.Texture.createFromFile("res/house.png");
    errdefer new.house_texture.destroy();

    new.house_sprite = try sf.Sprite.createFromTexture(new.house_texture);
    errdefer new.house_sprite.destroy();
    new.house_sprite.setScale(.{ .x = 2, .y = 2 });

    new.scroll = 0;
    new.depth = 0;

    return new;
}
/// Destroys the renderer
pub fn destroy(self: *@This()) void {
    self.buffer.destroy();
    self.house_texture.destroy();
    self.house_sprite.destroy();
}

/// Updates some stuff
pub fn update(self: *@This(), dt: f32) void {
    _ = dt;
    self.house_sprite.setPosition(.{ .x = 0, .y = -(self.depth + self.scroll) * QUAD_SIZE });
}

/// Updates all the vertices when the terrain changes
pub fn updateVertices(self: *@This(), data: Terrain.DataT) void {
    const pslice = sf.Vertex.verticesAsPrimitives(&self.vdata, .Quads);

    for (pslice) |*quad, i| {
        const x = i % Terrain.WIDTH;
        const y = i / Terrain.WIDTH;

        quad.a.position = sf.Vector2f{ .x = @intToFloat(f32, x + 0) * QUAD_SIZE, .y = @intToFloat(f32, y + 0) * QUAD_SIZE };
        quad.b.position = sf.Vector2f{ .x = @intToFloat(f32, x + 1) * QUAD_SIZE, .y = @intToFloat(f32, y + 0) * QUAD_SIZE };
        quad.c.position = sf.Vector2f{ .x = @intToFloat(f32, x + 1) * QUAD_SIZE, .y = @intToFloat(f32, y + 1) * QUAD_SIZE };
        quad.d.position = sf.Vector2f{ .x = @intToFloat(f32, x + 0) * QUAD_SIZE, .y = @intToFloat(f32, y + 1) * QUAD_SIZE };

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

    target.draw(self.house_sprite, null);
    target.draw(self.buffer, .{ .transform = transform, .texture = atlas.texture });
}
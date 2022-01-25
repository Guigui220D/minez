const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.system;
    usingnamespace sf.graphics;
};

const TerrainRenderer = @import("TerrainRenderer.zig");
const Terrain = @import("Terrain.zig");

position: sf.Vector2f = .{ .x = 0, .y = 0 },
sprite: sf.Sprite,
world: *Terrain,

pub fn update(self: *@This(), delta: f32) void {
    _ = delta;
    self.sprite.setPosition(self.position.substract(.{ .x = 0, .y = self.world.renderer.getScroll() * TerrainRenderer.QUAD_SIZE }));
}

pub fn draw(self: @This(), target: anytype) void {
    target.draw(self.sprite, null);
}
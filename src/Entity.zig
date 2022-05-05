const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.system;
    usingnamespace sf.graphics;
};

const game = @import("game.zig");
const TerrainRenderer = @import("TerrainRenderer.zig");
const Terrain = @import("Terrain.zig");

pub const SpecificData = union {
    Decoration: void,
    Angerman: struct { angry: bool, clk: sf.Clock },
    Silverfish: void,

    // TODO: destroy fn because this leaks
};

position: sf.Vector2f,
sprite: sf.Sprite,
updateFn: fn(self: *@This(), delta: f32) void,
data: SpecificData,
shader: ?sf.Shader,
active: bool,
visible: bool,
to_remove: bool,

pub fn create(comptime Class: type, position: sf.Vector2f) !@This() {
    var new: @This() = undefined;

    new.position = position;

    new.active = true;
    new.visible = true;
    new.to_remove = false;

    new.sprite = try Class.prepareSprite();
    errdefer new.sprite.destroy();
    new.sprite.setPosition(new.position);
    new.shader = Class.getShader();

    new.updateFn = Class.updateFn;
    new.data = try Class.prepareData();

    return new;
}

pub fn destroy(self: *@This()) void {
    self.sprite.destroy();
    self.* = undefined;
}

pub fn update(self: *@This(), delta: f32) void {
    if (self.active)
        self.updateFn(self, delta);
    self.sprite.setPosition(self.position.substract(.{ .x = 0, .y = game.world.renderer.getScroll() * TerrainRenderer.QUAD_SIZE }));
}

pub fn draw(self: @This(), target: anytype) void {
    if (!self.visible)
        return;
    target.draw(self.sprite, .{ .shader = self.shader });
}
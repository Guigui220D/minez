const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.system;
    usingnamespace sf.graphics;
};

const TerrainRenderer = @import("TerrainRenderer.zig");
const Terrain = @import("Terrain.zig");
const entity_strategies = @import("entity_strategies.zig");
const entity_resources = @import("entity_resources.zig");

pub const Type = enum {
    Decoration,
    Silverfish
};

position: sf.Vector2f,
sprite: sf.Sprite,
world: *Terrain,
updateFn: fn(self: *@This(), delta: f32) void,

pub fn create(world: *Terrain, entity_type: Type, position: sf.Vector2f) !@This() {
    var new: @This() = undefined;

    new.position = position;
    new.world = world;

    switch (entity_type) {
        .Decoration => {
            var spr = try sf.Sprite.createFromTexture(entity_resources.house_texture);
            spr.setScale(.{ .x = 2, .y = 2 });
            new.sprite = spr;
        },
        .Silverfish => {
            var spr = try sf.Sprite.createFromTexture(entity_resources.silverfish_texture);
            spr.setOrigin(.{ .x = spr.getGlobalBounds().width / 2, .y = 0 });
            new.sprite = spr;
        },
    }
    errdefer new.sprite.destroy();
    new.sprite.setPosition(new.position);

    new.updateFn = switch (entity_type) {
        .Decoration => entity_strategies.doNothing,
        .Silverfish => entity_strategies.backAndForth,
    };

    return new;
}

pub fn destroy(self: *@This()) void {
    self.sprite.destroy();
}

pub fn update(self: *@This(), delta: f32) void {
    self.updateFn(self, delta);
    self.sprite.setPosition(self.position.substract(.{ .x = 0, .y = self.world.renderer.getScroll() * TerrainRenderer.QUAD_SIZE }));
}

pub fn draw(self: @This(), target: anytype) void {
    target.draw(self.sprite, null);
}
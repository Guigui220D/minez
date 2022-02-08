const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.system;
    usingnamespace sf.graphics;
};

const game = @import("game.zig");
const TerrainRenderer = @import("TerrainRenderer.zig");
const Terrain = @import("Terrain.zig");
const entity_strategies = @import("entity_strategies.zig");
const entity_resources = @import("entity_resources.zig");

pub const Type = enum {
    Decoration,
    Angerman,
    Silverfish
};

pub const SpecificData = union(Type) {
    Decoration: void,
    Angerman: struct { angry: bool, clk: sf.Clock },
    Silverfish: void,
};

position: sf.Vector2f,
sprite: sf.Sprite,
updateFn: fn(self: *@This(), delta: f32) void,
data: SpecificData,
shader: ?sf.Shader,
active: bool,
visible: bool,
to_remove: bool,

pub fn create(entity_type: Type, position: sf.Vector2f) !@This() {
    var new: @This() = undefined;

    new.position = position;

    new.active = true;
    new.visible = true;
    new.to_remove = false;

    switch (entity_type) {
        .Decoration => {
            var spr = try sf.Sprite.createFromTexture(entity_resources.house_texture);
            spr.setScale(.{ .x = 2, .y = 2 });
            new.sprite = spr;
        },
        .Angerman => {
            var spr = try sf.Sprite.createFromTexture(entity_resources.angerman_texture);
            spr.setTextureRect(.{ .left = 0, .top = 0, .width = 8, .height = 12 });
            spr.setScale(.{ .x = 7.5, .y = 7.5 });
            spr.setOrigin(.{ .x = spr.getLocalBounds().width / 2, .y = spr.getLocalBounds().height * 0.7 });
            new.sprite = spr;
        },
        .Silverfish => {
            var spr = try sf.Sprite.createFromTexture(entity_resources.silverfish_texture);
            spr.setOrigin(.{ .x = spr.getLocalBounds().width / 2, .y = 0 });
            new.sprite = spr;
        },
    }
    errdefer new.sprite.destroy();
    new.sprite.setPosition(new.position);

    new.updateFn = switch (entity_type) {
        .Decoration => entity_strategies.doNothing,
        .Angerman => entity_strategies.angerman,
        .Silverfish => entity_strategies.backAndForth,
    };

    switch (entity_type) {
        .Decoration => new.data = .{ .Decoration = {} },
        .Angerman => new.data = .{ .Angerman = .{ .angry = true, .clk = sf.Clock.create() catch unreachable } },
        .Silverfish => new.data = .{ .Silverfish = {} },
    }

    new.shader = switch (entity_type) {
        .Angerman => try sf.Shader.createFromMemory(null, null, @embedFile("anger_shader.fs")),
        else => null,
    };
    errdefer {
        if (new.shader) |s|
            s.destroy();
    }
    if (new.shader) |*s| {
        s.setUniform("textureSampler", sf.Shader.CurrentTexture);
    }
        

    return new;
}

pub fn destroy(self: *@This()) void {
    self.sprite.destroy();
    if (self.shader) |*s|
        s.destroy();
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
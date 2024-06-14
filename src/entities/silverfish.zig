const std = @import("std");
const sf = @import("sfml").graphics;

const Entity = @import("../Entity.zig");
const crt = @import("../crt.zig");
const game = @import("../game.zig");

var texture: sf.Texture = undefined;

pub fn loadResources() !void {
    texture = try sf.Texture.createFromFile("res/entity/silverfish.png");
    errdefer texture.destroy();
}

pub fn destroyResources() void {
    texture.destroy();
}

pub fn prepareSprite() !sf.Sprite {
    var spr = try sf.Sprite.createFromTexture(texture);
    spr.setOrigin(.{ .x = spr.getLocalBounds().width / 2, .y = 0 });
    return spr;
}

pub fn updateFn(self: *Entity, delta: f32) void {
    self.position.x += delta * self.sprite.getScale().x * -64;
    const w = self.sprite.getGlobalBounds().width / 2;
    if (self.position.x < w) {
        self.position.x = w;
        self.sprite.setScale(.{ .x = -1, .y = 1 });
    }
    if (self.position.x > crt.WIDTH - w) {
        self.position.x = crt.WIDTH - w;
        self.sprite.setScale(.{ .x = 1, .y = 1 });
    }
}

pub fn getShader() ?sf.Shader {
    return null;
}

pub fn prepareData() !Entity.SpecificData {
    return Entity.SpecificData{ .Silverfish = .{} };
}

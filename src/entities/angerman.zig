const std = @import("std");
const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.graphics;
    usingnamespace sf.system;
};

const Entity = @import("../Entity.zig");
const crt = @import("../crt.zig");
const game = @import("../game.zig");
const gui = @import("../gui.zig");

var texture: sf.Texture = undefined;
var shader: sf.Shader = undefined;

pub fn loadResources() !void {
    shader = try sf.Shader.createFromFile(null, null, "res/shader/anger_shader.fs");
    errdefer shader.destroy();
    texture = try sf.Texture.createFromFile("res/entity/angerman.png");
    errdefer texture.destroy();
}

pub fn destroyResources() void {
    shader.destroy();
    texture.destroy();
}

pub fn prepareSprite() !sf.Sprite {
    var spr = try sf.Sprite.createFromTexture(texture);
    spr.setTextureRect(.{ .left = 0, .top = 0, .width = 8, .height = 12 });
    spr.setScale(.{ .x = 7.5, .y = 7.5 });
    spr.setOrigin(.{ .x = spr.getLocalBounds().width / 2, .y = spr.getLocalBounds().height * 0.7 });
    return spr;
}

pub fn updateFn(self: *Entity, delta: f32) void {
    const player_pos = game.player.getGlobalPosition();
    var diff = player_pos.substract(self.position);

    self.shader.?.setUniform("dist", diff.y - 100);

    const len = std.math.sqrt(diff.x * diff.x + diff.y * diff.y);
    diff = diff.scale(1 / len);
    diff = diff.scale(delta * 3000);

    //const left: c_int = if (self.data.Angerman.angry) 8 else 0;
    const left: c_int = if (len < 100) 8 else 0;
    self.sprite.setTextureRect(.{ .left = left, .top = 0, .width = 8, .height = 12 });

    if (len < 16) {
        game.player.mining_speed = 0;
        self.data.Angerman.angry = false;
    }

    // Animation
    const rotation = std.math.sin(self.data.Angerman.clk.getElapsedTime().asSeconds());
    self.sprite.setRotation(rotation * 10);

    self.shader.?.setUniform("time", self.data.Angerman.clk.getElapsedTime().asSeconds());

    if (gui.getScore() < 10000) {
        if (!game.player.doing)
            return;
        if (!self.data.Angerman.angry)
            return;

        // Go towards player
        self.position = self.position.add(diff.scale(delta));
    } else {
        if (self.sprite.getPosition().y < -100)
            return;

        self.position.y -= delta * 96;
    }
}

pub fn getShader() ?sf.Shader {
    return shader;
}

pub fn prepareData() !Entity.SpecificData {
    var clock = try sf.Clock.create();
    errdefer clock.destroy();

    return Entity.SpecificData{ .Angerman = .{ .angry = true, .clk = clock } };
}
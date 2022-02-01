const std = @import("std");

const Entity = @import("Entity.zig");
const crt = @import("crt.zig");
const game = @import("game.zig");

pub fn doNothing(self: *Entity, delta: f32) void {
    _ = self;
    _ = delta;
}

pub fn backAndForth(self: *Entity, delta: f32) void {
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

pub fn angerman(self: *Entity, delta: f32) void {
    const player_pos = game.player.getGlobalPosition();
    var diff = player_pos.substract(self.position);

    self.shader.?.setUniform("dist", diff.y - 100);

    const len = std.math.sqrt(diff.x * diff.x + diff.y * diff.y);
    diff = diff.scale(1 / len);
    diff = diff.scale(delta * 3000);

    //const left: c_int = if (self.data.Angerman.angry) 8 else 0;
    const left: c_int = if (len < 100) 8 else 0;
    self.sprite.setTextureRect(.{ .left = left, .top = 0, .width = 8, .height = 12 });

    // Animation
    const rotation = std.math.sin(self.data.Angerman.clk.getElapsedTime().asSeconds());
    self.sprite.setRotation(rotation * 10);

    self.shader.?.setUniform("time", self.data.Angerman.clk.getElapsedTime().asSeconds());

    if (!game.player.doing)
        return;

    // Go towards player
    self.position = self.position.add(diff.scale(delta));
}
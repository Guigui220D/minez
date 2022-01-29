const Entity = @import("Entity.zig");
const crt = @import("crt.zig");

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
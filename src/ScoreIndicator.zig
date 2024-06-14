const std = @import("std");
const sf = struct {
    const sfml = @import("sfml");
    pub usingnamespace sfml;
    pub usingnamespace sfml.graphics;
    pub usingnamespace sfml.system;
};

const gui = @import("gui.zig");

text: sf.Text,
clock: sf.Clock,
rect: sf.RectangleShape,

pub fn create() !@This() {
    var new: @This() = undefined;

    new.text = try sf.Text.create();
    errdefer new.text.destroy();
    new.text.setFont(gui.font);
    new.text.setCharacterSize(12);
    new.text.setPosition(.{ .x = -100, .y = -100 });
    new.text.setFillColor(sf.Color.Yellow);

    new.clock = try sf.Clock.create();
    errdefer new.clock.destroy();

    new.rect = try sf.RectangleShape.create(.{ .x = 0, .y = 0 });
    errdefer new.rect.destroy();
    new.rect.setFillColor(sf.Color.Black);
    new.rect.setPosition(.{ .x = -100, .y = -100 });

    return new;
}

pub fn showScore(self: *@This(), pos: sf.Vector2f, score: i32) void {
    _ = self.clock.restart();

    self.text.setStringFmt("{}", .{score}) catch unreachable;
    self.text.setPosition(pos.add(.{ .x = 0, .y = -30 }));
    self.rect.setPosition(pos.add(.{ .x = 0, .y = -30 }));

    const bounds = self.text.getGlobalBounds();
    self.rect.setSize(.{ .x = bounds.width, .y = bounds.height });
}

pub fn destroy(self: *@This()) void {
    self.text.destroy();
    self.clock.destroy();
    self.rect.destroy();
}

pub fn draw(self: @This(), target: anytype) void {
    if (self.clock.getElapsedTime().asSeconds() < 0.5) {
        target.draw(self.rect, null);
        target.draw(self.text, null);
    }
}

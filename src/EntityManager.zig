const std = @import("std");

const Entity = @import("Entity.zig");  

entities: std.ArrayList(Entity),

pub fn init(allocator: std.mem.Allocator) @This() {
    return @This(){
        .entities = std.ArrayList(Entity).init(allocator)
    };
}

pub fn deinit(self: *@This()) void {
    self.entities.deinit();
}

pub fn updateAll(self: *@This(), delta: f32) void {
    for (self.entities.items) |*ent|
        ent.update(delta);
}

pub fn drawAll(self: @This(), target: anytype) void {
    for (self.entities.items) |ent|
        ent.draw(target);
}


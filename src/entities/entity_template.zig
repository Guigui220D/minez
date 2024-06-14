const std = @import("std");
const sf = @import("sfml").graphics;

const Entity = @import("Entity.zig");

pub fn loadResources() !void {
    // load global variables of this file here
}

pub fn destroyResources() void {
    // unload global variables of this file here
}

pub fn prepareSprite() !sf.Sprite {
    // prepare the sprite of the entity here
}

pub fn updateFn(self: *Entity, delta: f32) void {
    // update the entity here
}

pub fn getShader() ?sf.Shader {
    // return the shader of the entity here
}

pub fn prepareData() !Entity.SpecificData {
    // constructs the specific data of the entity here
}

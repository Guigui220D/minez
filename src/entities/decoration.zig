const std = @import("std");
const sf = @import("sfml").graphics;

const Entity = @import("../Entity.zig");

var texture: sf.Texture = undefined;

pub fn Decoration(comptime texture_path: [:0]const u8) type {
    return struct {
        pub fn loadResources() !void {
            texture = try sf.Texture.createFromFile(texture_path);
            errdefer texture.destroy();
        }

        pub fn destroyResources() void {
            texture.destroy();
        }

        pub fn prepareSprite() !sf.Sprite {
            var spr = try sf.Sprite.createFromTexture(texture);
            spr.setScale(.{ .x = 2, .y = 2 });
            return spr;
        }

        pub fn updateFn(self: *Entity, delta: f32) void {
            _ = self;
            _ = delta;
        }

        pub fn getShader() ?sf.Shader {
            return null;
        }

        pub fn prepareData() !Entity.SpecificData {
            return Entity.SpecificData{ .Decoration = void{} };
        }
    };
}

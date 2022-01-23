/// This module makes a an atlas of all the tiles

const std = @import("std");
const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.graphics;
    usingnamespace sf.system;
};

const TILE_SIZE = 16;

pub const AtlasBuilder = struct {
    const AtlasDataT = std.hash_map.StringHashMap(sf.FloatRect);

    rects: AtlasDataT,
    canvas: sf.RenderTexture,
    width: c_uint,
    height: c_uint,
    x: c_uint,
    y: c_uint,
    vertical: bool,

    pub fn start(allocator: *std.mem.Allocator) !@This() {
        var ret: @This() = .{
            .rects = undefined,
            .canvas = undefined,
            .width = 1,
            .height = 1,
            .x = 0,
            .y = 0,
            .vertical = false
        };

        ret.rects = AtlasDataT.init(allocator);
        errdefer ret.rects.deinit();

        ret.canvas = try sf.RenderTexture.create(.{ .x = TILE_SIZE, .y = TILE_SIZE });
        errdefer ret.canvas.destroy();

        return ret;
    }

    pub fn registerLoadAndGetTextureRect(self: *@This(), name: [:0]const u8) !sf.FloatRect {
        if (self.rects.get(name)) |ret|
            return ret;

        var tile = try sf.Texture.createFromFile(name);
        defer tile.destroy();

        defer self.moveToNextTile();
        try self.resizeCanvasIfNeeded();

        var choosen_place = sf.FloatRect{ 
            .left = @intToFloat(f32, self.x * TILE_SIZE),
            .top = @intToFloat(f32, self.y * TILE_SIZE),
            .width = @as(f32, TILE_SIZE),
            .height = @as(f32, TILE_SIZE)
        };

        var sprite = try sf.Sprite.createFromTexture(tile);
        defer sprite.destroy();
        sprite.setPosition(.{ .x = choosen_place.left, .y = choosen_place.top });

        self.canvas.draw(sprite, null);

        try self.rects.put(name, choosen_place);
        return choosen_place;
    }

    fn resizeCanvasIfNeeded(self: *@This()) !void {
        const size = self.canvas.getSize();
        const needed_size = (sf.Vector2u{ .x = self.width, .y = self.height }).scale(TILE_SIZE);

        if (size.x < needed_size.x or size.y < needed_size.y) {
            
            self.canvas.display();
            var cpy = try self.canvas.getTexture().copy();
            defer cpy.destroy();

            self.canvas.destroy();
            self.canvas = sf.RenderTexture.create(needed_size) catch @panic("idk");
            
            var sprite = sf.Sprite.createFromTexture(cpy) catch @panic("idk");
            defer sprite.destroy();

            self.canvas.draw(sprite, null);
        }
    }

    fn moveToNextTile(self: *@This()) void {
        if (self.vertical) {
            self.y += 1;
            if (self.y >= self.height) {
                self.x = 0;
                self.height += 1;
                self.vertical = false;
            }
        } else {
            self.x += 1;
            if (self.x >= self.width) {
                self.y = 0;
                self.width += 1;
                self.vertical = true;
            }
        }
    }

    pub fn finish(self: *@This()) !void {
        texture = try self.canvas.getTexture().copy();

        self.canvas.destroy();
        self.rects.deinit();

        // For debugging
        var img = texture.copyToImage();
        defer img.destroy();

        img.flipVertically();
        try img.saveToFile("atlas.png");
    }
};

pub var texture: sf.Texture = undefined;

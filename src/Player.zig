/// A player

const Terrain = @import("Terrain.zig");
const TerrainRenderer = @import("TerrainRenderer.zig");
const std = @import("std");
const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.graphics;
    usingnamespace sf.system;
    usingnamespace sf.window;
};

const DIG_TIME = sf.Time.seconds(0.5);

hpos: f32,
texture: sf.Texture,
sprite: sf.Sprite,
world: *Terrain,
dig_clk: sf.Clock,

/// Creates the player
pub fn create(terrain: *Terrain) !@This() {
    var texture = try sf.Texture.createFromFile("res/char.png");
    errdefer texture.destroy();

    var sprite = try sf.Sprite.createFromTexture(texture);
    errdefer sprite.destroy();
    sprite.setPosition(.{ .x = 0, .y = 256 });

    var dig_clk = try sf.Clock.create();
    errdefer dig_clk.destroy();

    return @This(){
        .hpos = 0,
        .texture = texture,
        .sprite = sprite,
        .world = terrain,
        .dig_clk = dig_clk,
    };
}
/// Destroys the player
pub fn destroy(self: *@This()) void {
    self.texture.destroy();
    self.sprite.destroy();
}

/// Updates the player, handles the controls
pub fn update(self: *@This(), delta: f32) void {
    var digging = false;

    if (sf.keyboard.isKeyPressed(.Right)) {
        if (self.tryGoRight(delta))
            digging = true;
    }

    if (sf.keyboard.isKeyPressed(.Left)) {
        if (self.tryGoLeft(delta))
            digging = true;
    }

    if (sf.keyboard.isKeyPressed(.Down)) {
        if (self.tryGoDown(delta))
            digging = true;
    }

    if (!digging)
        _ = self.dig_clk.restart();

    self.hpos = std.math.clamp(self.hpos, 0, Terrain.TERRAIN_WIDTH - 1);
    self.sprite.setPosition(.{ .x = self.hpos * TerrainRenderer.TERRAIN_QUAD_SIZE, .y = 256 });
}

/// Draws the player on the specified target
pub fn draw(self: @This(), target: anytype) void {
    target.draw(self.sprite, null);
}

/// Move down, dig the ground if impossible
/// Returns true if the player is digging now
fn tryGoDown(self: *@This(), delta: f32) bool {
    // Reset the horizontal position
    self.hpos = std.math.round(self.hpos);

    // Scroll the whole terrain
    self.world.scroll(delta * 10);

    const x = @floatToInt(usize, self.hpos);
    if (self.world.terrain[9][x] != 0) {
        // There's a block below
        // Reset the scroll
        _ = self.world.snapScroll();
        // Dig down
        if (self.dig_clk.getElapsedTime().us > DIG_TIME.us) {
            self.world.setBlock(x, 9, 0);
            _ = self.dig_clk.restart();
        }

        return true;
    }
    return false;
}
/// Move right, break the wall if impossible
/// Returns true if the player is digging now
fn tryGoRight(self: *@This(), delta: f32) bool {
    // Reset the vertical position
    if (!self.world.snapScroll())
        return false;

    self.hpos += delta * 10;

    const x = @floatToInt(usize, self.hpos + 1);
    if (x >= Terrain.TERRAIN_WIDTH) {
        // Avoid going too far right
        self.hpos = std.math.round(self.hpos);
        return false;
    }

    if (self.world.terrain[8][x] != 0) {
        // There's a block to the right
        self.hpos = std.math.round(self.hpos);
        // Dig right
        if (self.dig_clk.getElapsedTime().us > DIG_TIME.us) {
            self.world.setBlock(x, 8, 0);
            _ = self.dig_clk.restart();
        }

        return true;
    }
    return false;
}
/// Move left, break the wall if impossible
/// Returns true if the player is digging now
fn tryGoLeft(self: *@This(), delta: f32) bool {
    // Reset the vertical position
    if (!self.world.snapScroll())
        return false;

    self.hpos -= delta * 10;

    if (self.hpos < 0) {
        // Avoid going too far left
        self.hpos = 0;
        return false;
    }

    const x = @floatToInt(usize, self.hpos);

    if (self.world.terrain[8][x] != 0) {
        // There's a block to the left
        self.hpos = std.math.round(self.hpos);
        // Dig left
        if (self.dig_clk.getElapsedTime().us > DIG_TIME.us) {
            self.world.setBlock(x, 8, 0);
            _ = self.dig_clk.restart();
        }

        return true;
    }
    return false;
}
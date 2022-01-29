//! A player

const Terrain = @import("Terrain.zig");
const TerrainRenderer = @import("TerrainRenderer.zig");
const ScoreIndicator = @import("ScoreIndicator.zig");
const gui = @import("gui.zig");

const std = @import("std");
const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.graphics;
    usingnamespace sf.system;
    usingnamespace sf.window;
};

hpos: f32,
texture: sf.Texture,
sprite: sf.Sprite,
shader: sf.Shader,
score: ScoreIndicator,
world: *Terrain,
dig_clk: sf.Clock,
dig_texture: sf.Texture,
dig_sprite: sf.Sprite,

/// Creates the player
pub fn create(terrain: *Terrain) !@This() {
    var texture = try sf.Texture.createFromFile("res/char.png");
    errdefer texture.destroy();

    var sprite = try sf.Sprite.createFromTexture(texture);
    errdefer sprite.destroy();
    sprite.setPosition(.{ .x = 0, .y = 256 });
    sprite.setOrigin(.{ .x = 16, .y = 16 });

    var shader = try sf.Shader.createFromMemory(null, null, @embedFile("char_shader.fs"));
    errdefer shader.destroy();
    shader.setUniform("textureSampler", sf.Shader.CurrentTexture);
    shader.setUniform("glitch", false);

    var dig_clk = try sf.Clock.create();
    errdefer dig_clk.destroy();

    var score = try ScoreIndicator.create();
    errdefer score.destroy();

    var dig_texture = try sf.Texture.createFromFile("res/breaking.png");
    errdefer dig_texture.destroy();

    var dig_sprite = try sf.Sprite.createFromTexture(dig_texture);
    errdefer dig_sprite.destroy();
    dig_sprite.setTextureRect(.{ .left = 0, .top = 0, .width = 16, .height = 16 });
    dig_sprite.setColor(sf.Color.Transparent);
    dig_sprite.setScale(.{ .x = 2, .y = 2 });

    return @This(){
        .hpos = 0,
        .texture = texture,
        .sprite = sprite,
        .shader = shader,
        .score = score,
        .world = terrain,
        .dig_clk = dig_clk,
        .dig_texture = dig_texture,
        .dig_sprite = dig_sprite,
    };
}
/// Destroys the player
pub fn destroy(self: *@This()) void {
    self.texture.destroy();
    self.sprite.destroy();
    self.dig_clk.destroy();
    self.shader.destroy();
    self.score.destroy();
}

/// Updates the player, handles the controls
pub fn update(self: *@This(), delta: f32) void {
    var digging = false;

    if (sf.keyboard.isKeyPressed(.Right)) {
        if (self.tryGoRight(delta))
            digging = true;
    } else if (sf.keyboard.isKeyPressed(.Left)) {
        if (self.tryGoLeft(delta))
            digging = true;
    } else if (sf.keyboard.isKeyPressed(.Down)) {
        if (self.tryGoDown(delta))
            digging = true;
    }

    if (!digging) {
        _ = self.dig_clk.restart();
        self.dig_sprite.setColor(sf.Color.Transparent);
    }

    self.hpos = std.math.clamp(self.hpos, 0, Terrain.WIDTH - 1);
    self.sprite.setPosition(.{ .x = self.hpos * TerrainRenderer.QUAD_SIZE + 16, .y = 256 + 16 });

    if (gui.getScore() > 10000)
        self.shader.setUniform("glitch", true);
}

/// Draws the player on the specified target
pub fn draw(self: @This(), target: anytype) void {
    target.draw(self.sprite, .{ .shader = self.shader });
    target.draw(self.dig_sprite, null);
    self.score.draw(target);
}

/// Move down, dig the ground if impossible
/// Returns true if the player is digging now
fn tryGoDown(self: *@This(), delta: f32) bool {
    // Reset the horizontal position
    self.hpos = std.math.round(self.hpos);

    //self.sprite.setScale(.{ .x = 1, .y = 1 });
    self.sprite.setRotation(-90 * self.sprite.getScale().x);

    // Scroll the whole terrain
    self.world.scroll(delta * 10);

    const x = @floatToInt(usize, self.hpos);
    const block = self.world.getBlock(x, 9);
    if (block.dig_time >= 0) {
        // There's a block below
        // Reset the scroll
        _ = self.world.snapScroll();
        // Dig down
        if (self.dig_clk.getElapsedTime().asSeconds() > block.dig_time) {
            self.breakBlock(x, 9);
            _ = self.dig_clk.restart();
        }

        self.dig_sprite.setPosition(.{ .x = @intToFloat(f32, x * TerrainRenderer.QUAD_SIZE), .y = 256 + 32 });
        self.dig_sprite.setColor(sf.Color.White);
        var dig_stage = @floatToInt(c_int, (self.dig_clk.getElapsedTime().asSeconds() / block.dig_time) * 4);
        self.dig_sprite.setTextureRect(.{ .left = 0, .top = dig_stage * 16, .width = 16, .height = 16 });

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

    self.sprite.setScale(.{ .x = -1, .y = 1 });
    self.sprite.setRotation(0);

    self.hpos += delta * 10;

    const x = @floatToInt(usize, self.hpos + 1);
    if (x >= Terrain.WIDTH) {
        // Avoid going too far right
        self.hpos = std.math.round(self.hpos);
        return false;
    }

    const block = self.world.getBlock(x, 8);
    if (block.dig_time >= 0) {
        // There's a block to the right
        self.hpos = std.math.round(self.hpos);
        // Dig right
        if (self.dig_clk.getElapsedTime().asSeconds() > block.dig_time) {
            self.breakBlock(x, 8);
            _ = self.dig_clk.restart();
        }

        self.dig_sprite.setPosition(.{ .x = @intToFloat(f32, x * TerrainRenderer.QUAD_SIZE), .y = 256 });
        self.dig_sprite.setColor(sf.Color.White);
        var dig_stage = @floatToInt(c_int, (self.dig_clk.getElapsedTime().asSeconds() / block.dig_time) * 4);
        self.dig_sprite.setTextureRect(.{ .left = 0, .top = dig_stage * 16, .width = 16, .height = 16 });

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

    self.sprite.setScale(.{ .x = 1, .y = 1 });
    self.sprite.setRotation(0);

    self.hpos -= delta * 10;

    if (self.hpos < 0) {
        // Avoid going too far left
        self.hpos = 0;
        return false;
    }

    const x = @floatToInt(usize, self.hpos);
    const block = self.world.getBlock(x, 8);
    if (block.dig_time >= 0) {
        // There's a block to the left
        self.hpos = std.math.round(self.hpos);
        // Dig left
        if (self.dig_clk.getElapsedTime().asSeconds() > block.dig_time) {
            self.breakBlock(x, 8);
        }

        self.dig_sprite.setPosition(.{ .x = @intToFloat(f32, x * TerrainRenderer.QUAD_SIZE), .y = 256 });
        self.dig_sprite.setColor(sf.Color.White);
        var dig_stage = @floatToInt(c_int, (self.dig_clk.getElapsedTime().asSeconds() / block.dig_time) * 4);
        self.dig_sprite.setTextureRect(.{ .left = 0, .top = dig_stage * 16, .width = 16, .height = 16 });

        return true;
    }
    return false;
}

/// Break a block, show the score and update the score
fn breakBlock(self: *@This(), x: usize, y: usize) void {
    const score = self.world.getBlock(x, y).score;
    self.world.setBlock(x, y, 0);
    _ = self.dig_clk.restart();
    if (score > 0) {
        self.score.showScore(self.sprite.getPosition(), score);
        gui.addScore(score);
    }
}
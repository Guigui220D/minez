//! Holds the data of a terrain, handles its generation
// No rendering here

const std = @import("std");
const block_register = @import("block_register.zig");
const TerrainRenderer = @import("TerrainRenderer.zig");

pub const TERRAIN_WIDTH = 12;
pub const TERRAIN_HEIGHT = 20;

// Terrain data
pub const DataT = [TERRAIN_HEIGHT][TERRAIN_WIDTH]u8;
terrain: DataT,
depth: usize = 0,
renderer: *TerrainRenderer,
rand: *std.rand.Random,

/// Initializes the terrain, generates all layers
pub fn init(renderer: *TerrainRenderer, random: *std.rand.Random) @This() {
    var new: @This() = undefined;

    new.rand = random;
    new.renderer = renderer;
    // Reset depth
    new.depth = 0;
    // Generate each layer
    for (&new.terrain) |_, i|
        new.generateLayer(i);

    renderer.updateVertices(new.terrain);
    
    return new;
}

/// Scrolls down the terrain visually by a certain amount
pub fn scroll(self: *@This(), amount: f32) void {
    self.renderer.scroll += amount;

    while (self.renderer.scroll > 1.0) {
        self.renderer.scroll -= 1.0;
        self.shiftBlocks();
    }
}
/// Resets the scroll if possible
/// Returns false if it's too far
pub fn snapScroll(self: *@This()) bool {
    if (self.renderer.scroll > 0.6) {
        self.shiftBlocks();
        self.renderer.scroll = 0;
        return true;
    } else if (self.renderer.scroll < 0.4) {
        self.renderer.scroll = 0;
        return true;
    } else
        return false;
}

/// Scrolls down the whole terrain by one layer (not a visual effect)
/// Updates the vertices of the renderer
fn shiftBlocks(self: *@This()) void {
    const mem = @import("std").mem;

    // Move all layers up once
    mem.copy([TERRAIN_WIDTH]u8, self.terrain[0..], self.terrain[1..]);
    // Fill in deepest layer
    self.depth += 1;
    self.generateLayer(TERRAIN_HEIGHT - 1);

    // Update renderer
    self.renderer.updateVertices(self.terrain);
}

/// Generates a new layer of terrain
pub fn generateLayer(self: *@This(), layer: usize) void {
    // Generate a layer (overrides data)
    const y = layer + self.depth;
    // TODO: Make actual generation
    for (&self.terrain[layer]) |*val, x| {
        if (y < 15) {
            val.* = 0;
        } else if (y < 20) {
            val.* = @truncate(u8, (x + y) % 2 + 1);
        } else {
            val.* = @truncate(u8, self.rand.uintLessThan(u8, 3));
        }

        if (y == 0 and x == 0) {
            val.* = 2;
        }
    }
}

/// Sets a block at the given position
/// The height y is relative to the current depth
pub fn setBlock(self: *@This(), x: usize, y: usize, block: u8) void {
    const old = self.terrain[y][x];
    std.debug.print("Block at {}, {}, was {}, now {}\n", .{ x, y, old, block });
    std.debug.print("{} is a {s}\n", .{ old, block_register.ALL_BLOCKS[old].texture_name });
    std.debug.print("{} is a {s}\n", .{ block, block_register.ALL_BLOCKS[block].texture_name });
    self.terrain[y][x] = block;
    self.renderer.updateVertices(self.terrain);
}
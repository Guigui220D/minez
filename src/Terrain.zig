//! Holds the data of a terrain, handles its generation
// No rendering here

const std = @import("std");
const block_register = @import("block_register.zig");
const gui = @import("gui.zig");
const Block = @import("Block.zig");
const TerrainRenderer = @import("TerrainRenderer.zig");
const EntityManager = @import("EntityManager.zig");

pub const WIDTH = 12;
pub const HEIGHT = 20;

// Terrain data
pub const LayerT = [WIDTH]u8;
pub const DataT = std.ArrayList(LayerT);
terrain: DataT,
depth: usize = 0,
renderer: *TerrainRenderer,

/// Initializes the terrain, generates all layers
pub fn init(alloc: std.mem.Allocator, renderer: *TerrainRenderer) !@This() {
    var new: @This() = undefined;

    new.renderer = renderer;
    // Reset depth
    new.depth = 0;
    // Alloc the terrain
    new.terrain = try DataT.initCapacity(alloc, HEIGHT);
    errdefer new.terrain.deinit();
    // Generate each layer
    for (0..HEIGHT) |i|
        new.generateLayer(i);

    renderer.updateVertices(new.terrain);

    return new;
}

pub fn deinit(self: *@This()) void {
    self.terrain.deinit();
}

/// Scrolls the terrain visually by a certain amount
pub fn scroll(self: *@This(), amount: f32) void {
    self.renderer.scroll += amount;

    while (self.renderer.scroll > 1.0) {
        self.renderer.scroll -= 1.0;
        self.shiftBlocks();
    }

    while (self.renderer.scroll < -1.0) {
        self.renderer.scroll += 1.0;
        //self.shiftBlocks();
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
    } else return false;
}

/// Scrolls down the whole terrain by one layer (not a visual effect)
/// Updates the vertices of the renderer
fn shiftBlocks(self: *@This()) void {
    // Move all layers up once
    _ = self.terrain.orderedRemove(0);
    // Fill in deepest layer
    self.depth += 1;
    self.renderer.depth += 1;
    self.generateLayer(HEIGHT - 1);

    // Update renderer
    self.renderer.updateVertices(self.terrain);
}

/// Generates a new layer of terrain
pub fn generateLayer(self: *@This(), layer: usize) void {
    const rand = @import("game.zig").random;
    // Generate a layer (overrides data)
    const y = layer + self.depth;

    // TODO: Make actual generation
    var new_layer: LayerT = undefined;
    for (&new_layer) |*val| {
        if (y < 9) {
            val.* = 0;
        } else if (y <= 11) {
            val.* = 1;
        } else {
            const stone_id: u8 = @intFromFloat(std.math.clamp(rand.floatNorm(f32) * 0.5 + (@as(f32, @floatFromInt(y)) / 50), 0, 4));
            val.* = stone_id + 1;

            if (rand.float(f32) < (5.0 / 100.0)) {
                val.* = 6;
            } else if (y > 100) {
                if (rand.float(f32) < (4.0 / 100.0)) {
                    val.* = 7;
                } else if (y > 200) {
                    if (rand.float(f32) < (3.0 / 100.0))
                        val.* = 8;
                }
            }
        }
    }

    self.terrain.append(new_layer) catch @panic("Couldn't alloc new layers! OOM");
}

/// Sets a block at the given position
/// The height y is relative to the current depth
pub fn setBlock(self: *@This(), x: usize, y: usize, block: u8) void {
    //const old = self.terrain[y][x];
    self.terrain.items[y][x] = block;
    self.renderer.updateVertices(self.terrain);
}

pub fn getBlock(self: @This(), x: usize, y: usize) Block {
    return block_register.ALL_BLOCKS[self.terrain.items[y][x]];
}

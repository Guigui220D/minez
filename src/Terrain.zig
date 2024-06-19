//! Holds the data of a terrain, handles its generation
// No rendering here

const std = @import("std");
const br = @import("block_register.zig");
const gui = @import("gui.zig");
const Block = @import("Block.zig");
const TerrainRenderer = @import("TerrainRenderer.zig");
const EntityManager = @import("EntityManager.zig");
const wfc = @import("wfc/wfc_block.zig");
const game = @import("game.zig");

pub const WIDTH = 12;
pub const MIN_HEIGHT = 20;

// Terrain data
pub const LayerT = [WIDTH]u8;
pub const DataT = std.ArrayList(LayerT);
terrain: DataT,
depth: usize = 0,
renderer: *TerrainRenderer,
wfc_gen: wfc.WfcChunk,

/// Initializes the terrain, generates all layers
pub fn init(alloc: std.mem.Allocator, renderer: *TerrainRenderer) !@This() {
    //std.debug.print("{any}\n", .{br.ALL_BLOCKS});
    var new: @This() = undefined;

    new.renderer = renderer;
    // Reset depth
    new.depth = 0;
    // Alloc the terrain
    new.terrain = try DataT.initCapacity(alloc, MIN_HEIGHT);
    errdefer new.terrain.deinit();

    return new;
}

pub fn genSome(self: *@This()) void {
    // Generate each layer
    while (self.terrain.items.len < MIN_HEIGHT)
        self.generateSomeLayers();

    self.renderer.updateVertices(self.terrain);
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

    if (self.terrain.items.len < MIN_HEIGHT)
        self.generateSomeLayers();

    // Update renderer
    self.renderer.updateVertices(self.terrain);
}

/// Generates a few or one layer of terrain
pub fn generateSomeLayers(self: *@This()) void {
    //const rand = @import("game.zig").random;
    // Generate a layer (overrides data)
    //const y = self.terrain.items.len + self.depth;

    while (!self.wfc_gen.isReady())
        self.wfc_gen.collapse() catch unreachable;

    const new_layer = self.wfc_gen.popLayer();

    self.terrain.append(new_layer) catch @panic("Couldn't alloc new layers! OOM");
}

pub fn getBottomY(self: @This()) usize {
    return self.depth + self.terrain.items.len;
}

fn only(comptime name: []const u8) wfc.ChoicesT {
    var zeros = [1]f64{0.0} ** (br.BLOCK_COUNT);
    zeros[@intFromEnum(@field(br.BLOCK_NAMES, name))] = 1.0;
    return zeros;
}

pub fn getWfcContextualWeights(self: @This()) wfc.ChoicesT {
    const y = self.getBottomY();

    var ret = wfc.default_weights;
    ret[@intFromEnum(br.BLOCK_NAMES.err_block)] = 0;

    if (y < 9)
        return only("air");

    if (y < 11)
        return only("dirt");

    //ret[@intFromEnum(br.BLOCK_NAMES.err_block)]

    return ret;

    //const stone_id: u8 = @intFromFloat(std.math.clamp(rand.floatNorm(f32) * 0.5 + (@as(f32, @floatFromInt(y)) / 50), 0, 4));
}

/// Sets a block at the given position
/// The height y is relative to the current depth
pub fn setBlock(self: *@This(), x: usize, y: usize, block: u8) void {
    //const old = self.terrain[y][x];
    self.terrain.items[y][x] = block;
    self.renderer.updateVertices(self.terrain);
}

pub fn getBlock(self: @This(), x: usize, y: usize) Block {
    return br.ALL_BLOCKS[self.terrain.items[y][x]];
}

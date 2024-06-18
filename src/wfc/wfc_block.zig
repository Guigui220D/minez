const std = @import("std");
const wfc = @import("wfc");

const Terrain = @import("../Terrain.zig");
const block_reg = @import("../block_register.zig");

// TODO: normalize this format in the lib
const ChoicesT = [block_reg.BLOCK_COUNT]f64;
pub const default_weights = [1]f64{1.0} ** block_reg.BLOCK_COUNT;

pub const WfcChunk = struct {
    pub const HEIGHT = 3;
    rand: std.Random,
    blocks: std.BoundedArray(WfcBlockRow, HEIGHT),
    terrain: *Terrain,

    pub fn init(rand: std.Random, terrain: *Terrain) WfcChunk {
        var ret: WfcChunk = undefined;
        ret.rand = rand;
        ret.blocks = std.BoundedArray(WfcBlockRow, HEIGHT).init(0) catch unreachable;
        ret.terrain = terrain;

        ret.blocks.appendNTimes(defaultRow, HEIGHT) catch unreachable;
        ret.prepareAll();

        return ret;
    }

    pub fn isReady(self: WfcChunk) bool {
        for (self.blocks.get(0)) |block| {
            if (block != .decided)
                return false;
        }
        return true;
    }

    pub fn popLayer(self: *WfcChunk) Terrain.LayerT {
        std.debug.assert(self.isReady());

        const collapsed = self.blocks.orderedRemove(0);
        self.blocks.append(defaultRow) catch unreachable;

        self.prepareAll();

        return wfcRowToBlockLayer(collapsed);
    }

    pub fn prepareAll(self: *WfcChunk) void {
        for (self.blocks.buffer, 0..) |layer, y| {
            for (layer, 0..) |wfc_block, x| {
                if (wfc_block == .not_ready) {
                    // Update the choices of the unready block
                    updateChoices(self, @intCast(x), @intCast(y));
                }
            }
        }
    }

    fn updateChoices(self: *WfcChunk, x: isize, y: isize) void {
        if (x < 0 or x >= Terrain.WIDTH)
            return;
        if (y < 0 or y >= HEIGHT)
            return;

        const ptr = &self.blocks.buffer[@intCast(y)][@intCast(x)];
        if (ptr.* == .decided)
            return;
        if (ptr.* == .impossible)
            return;

        const wr = self.getWeights(x + 1, y, "left");
        const wl = self.getWeights(x - 1, y, "right");
        const wd = self.getWeights(x, y + 1, "up");
        const wu = self.getWeights(x, y - 1, "down");
        const wru = self.getWeights(x + 1, y - 1, "diagdown");
        const wrd = self.getWeights(x + 1, y + 1, "diagup");
        const wlu = self.getWeights(x - 1, y - 1, "diagdown");
        const wld = self.getWeights(x - 1, y + 1, "diagup");

        var choices = default_weights;
        mulInPlace(&choices, wr);
        mulInPlace(&choices, wl);
        mulInPlace(&choices, wd);
        mulInPlace(&choices, wu);
        mulInPlace(&choices, wru);
        mulInPlace(&choices, wrd);
        mulInPlace(&choices, wlu);
        mulInPlace(&choices, wld);

        wfc.normalize(&choices) catch unreachable;
        ptr.* = WfcBlock{ .undecided = choices };
    }

    // TODO: move to lib
    fn mulInPlace(a: *ChoicesT, b: ?ChoicesT) void {
        if (b) |c| {
            for (a, c) |*aa, cc|
                aa.* *= cc;
        }
    }

    // TODO: actual way to tell direction instead of v bool
    fn getWeights(self: WfcChunk, x: isize, y: isize, comptime group: []const u8) ?ChoicesT {
        //std.debug.print("x: {}, y: {}\n", .{ x, y });
        if (x < 0 or x >= Terrain.WIDTH)
            return null;
        if (y >= HEIGHT)
            return null;
        if (y < 0) {
            std.debug.assert(y == -1);
            //std.debug.print("{p}\n", .{&self.terrain.terrain.items});
            // Get decided block from the terrain
            if (self.terrain.terrain.items.len == 0)
                return null;

            const layer = self.terrain.terrain.getLast();
            const b = layer[@intCast(x)];

            return @field(block_reg.ALL_BLOCKS[b], "wfc_" ++ group);
        } else {
            const wfcb = self.blocks.buffer[@intCast(y)][@intCast(x)];
            if (wfcb != .decided)
                return null;
            // Get decided block from the WFC chunk
            return @field(block_reg.ALL_BLOCKS[wfcb.decided], "wfc_" ++ group);
        }
    }

    // TODO: use vectors

    pub fn collapse(self: *WfcChunk) !void {
        // Find the block of lowest entropy
        // TODO: keep track of *several* blocks of least entropy and choose at random
        var min_entropy: f64 = std.math.floatMax(f64);
        var min_x: isize = undefined;
        var min_y: isize = undefined;
        for (self.blocks.buffer, 0..) |layer, y| {
            for (&layer, 0..) |*wfc_block, x| {
                if (wfc_block.* == .decided)
                    continue;
                const h = try wfc_block.getEntropy();
                if (h < min_entropy) {
                    min_entropy = h;
                    min_x = @intCast(x);
                    min_y = @intCast(y);
                }
            }
        }

        // Collapse the selected block
        const ret = try self.blocks.buffer[@intCast(min_y)][@intCast(min_x)].choose(self.rand);
        // At this point collapse should always succeed (the selected block has to be an undecided)
        //std.debug.assert(ret);
        _ = ret;

        // Update neighbor's options
        updateChoices(self, min_x + 1, min_y);
        updateChoices(self, min_x - 1, min_y);
        updateChoices(self, min_x, min_y + 1);
        updateChoices(self, min_x, min_y - 1);
    }

    // Needs a fully collapsed row
    fn wfcRowToBlockLayer(row: WfcBlockRow) Terrain.LayerT {
        var ret: Terrain.LayerT = undefined;
        for (&row, &ret) |a, *b| {
            b.* = a.decided;
        }
        return ret;
    }

    const defaultRow = [_]WfcBlock{WfcBlock{ .not_ready = void{} }} ** Terrain.WIDTH;
};

pub const WfcBlockRow = [Terrain.WIDTH]WfcBlock;

pub const WfcBlock = union(enum) {
    not_ready: void,
    undecided: ChoicesT,
    decided: u8,
    impossible: void,

    pub fn getEntropy(self: WfcBlock) !f64 {
        return switch (self) {
            .not_ready => |_| error.NotReady,
            .undecided => |s| wfc.entropy(&s),
            .decided => |_| 0.0,
            .impossible => |_| error.Impossible,
        };
    }

    pub fn choose(self: *WfcBlock, rand: std.Random) !bool {
        if (self.* != .undecided)
            return false;

        var buf: [@sizeOf(ChoicesT) * 2]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buf);
        const alloc = fba.allocator();

        const result = try wfc.pick(rand, alloc, &self.undecided);
        self.* = WfcBlock{ .decided = @intCast(result) };

        return true;
    }
};

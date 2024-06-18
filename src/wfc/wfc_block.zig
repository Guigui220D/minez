const std = @import("std");
const wfc = @import("wfc");

const Terrain = @import("../terrain.zig");
const block_reg = @import("../block_register.zig");

const ChoicesT = [block_reg.BLOCK_COUNT]f64;

pub const WfcChunk = struct {
    rand: std.Random,
    blocks: std.BoundedArray(WfcBlockRow, 3),

    pub fn init(rand: std.Random) WfcChunk {
        var ret: WfcChunk = undefined;
        ret.rand = rand;
        ret.blocks = std.BoundedArray(WfcBlockRow, 3).init(0);

        ret.blocks.appendNTimes(defaultRow, 3) catch unreachable;

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

        return wfcRowToBlockLayer(collapsed);
    }

    pub fn prepareAll(self: *WfcChunk) !void {
        for (self.blocks.buffer) |layer| {
            for (layer) |*wfc_block| {
                if (wfc_block == .not_ready) {
                    // TODO: update its options
                }
            }
        }
    }

    pub fn collapse(self: *WfcChunk) !void {
        // Find the block of lowest entropy
        // TODO: keep track of *several* blocks of least entropy and choose at random
        var min_entropy: f64 = std.math.floatMax(f64);
        var min_block: ?*WfcBlock = null;
        for (self.blocks.buffer) |layer| {
            for (layer) |*wfc_block| {
                if (wfc_block == .decided)
                    continue;
                const h = wfc_block.getEntropy();
                if (h < min_entropy) {
                    min_entropy = h;
                    min_block = wfc_block;
                }
            }
        }

        if (min_block) |block| {
            // Collapse the selected block
            const ret = block.choose(self.rand);
            // At this point collapse should always succeed (the selected block has to be an undecided)
            std.debug.assert(ret);

            // TODO: update neighbor's options
        } else {
            return error.FullyCollapsed;
        }
    }

    // Needs a fully collapsed row
    fn wfcRowToBlockLayer(row: WfcBlockRow) Terrain.LayerT {
        var ret: Terrain.LayerT = undefined;
        for (&row, &ret) |a, *b| {
            b.* = a.decided;
        }
        return ret;
    }

    const defaultRow: WfcBlock = [_]WfcBlock{.{.not_ready}} ** Terrain.WIDTH;
};

pub const WfcBlockRow = [Terrain.WIDTH]WfcBlock;

pub const WfcBlock = union(enum) {
    not_ready: void,
    undecided: struct {
        choices: ChoicesT,
    },
    decided: u8,
    impossible: void,

    pub fn getEntropy(self: WfcBlock) !f64 {
        return switch (self) {
            .not_ready => |_| error.NotReady,
            .undecided => |s| wfc.entropy(s.choices),
            .decided => |_| 0.0,
            .impossible => |_| error.Impossible,
        };
    }

    pub fn choose(self: WfcBlock, rand: std.Random) bool {
        if (self.* != .undecided)
            return false;

        const buf: [@sizeOf(ChoicesT) * 2]u8 = undefined;
        const alloc = std.heap.FixedBufferAllocator.init(buf);

        const result = wfc.pick(rand, alloc, self.undecided.choices);
        self.* = WfcBlock{ .decided = @intCast(result) };

        return true;
    }
};

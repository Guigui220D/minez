const std = @import("std");
const time = std.time;
const log = std.log;
const game = @import("game.zig");

pub fn main() !void {
    var init_clk = try time.Timer.start();

    log.info("Initializing the game...", .{});
    try game.init();
    log.info("Init finished in {}ms!", .{init_clk.read() / time.ns_per_ms});

    game.run();

    game.deinit();
}

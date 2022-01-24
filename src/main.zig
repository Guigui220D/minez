const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.graphics;
    usingnamespace sf.window;
    usingnamespace sf.system;
};
const std = @import("std");
const atlas = @import("atlas.zig");
const block_register = @import("block_register.zig");
const Terrain = @import("Terrain.zig");
const TerrainRenderer = @import("TerrainRenderer.zig");
const Player = @import("Player.zig");

pub fn main() !void {
    // Random, for terrain generation
    var xoro = std.rand.DefaultPrng.init(@bitCast(u64, std.time.timestamp()));
    var rand = xoro.random();

    // Atlas builder
    var atlas_builder = try atlas.Builder.start(std.heap.page_allocator);
    try block_register.loadAllBlockTextures(&atlas_builder);
    try atlas_builder.finish();

    // Window
    var window = try sf.RenderWindow.createDefault(.{ .x = 800, .y = 600 }, "SFML works!");
    defer window.destroy();
    window.setFramerateLimit(60);

    var view = window.getView();
    view.setCenter(.{ .x = (Terrain.TERRAIN_WIDTH * TerrainRenderer.TERRAIN_QUAD_SIZE) / 2, .y = 300 });
    window.setView(view);

    // Game clock
    var clk = try sf.Clock.create();
    defer clk.destroy();

    // Terrain
    var renderer = try TerrainRenderer.create();
    defer renderer.destroy();
    var terrain = Terrain.init(&renderer, &rand);

    // Player
    var player = try Player.create(&terrain);
    defer player.destroy();

    // Main loop
    while (window.isOpen()) {
        while (window.pollEvent()) |event| {
            switch (event) {
                .closed => window.close(),
                else => continue,
            }
        }

        var delta = std.math.min(clk.restart().asSeconds(), 0.04);
        player.update(delta);

        window.clear(sf.Color.Black);
        renderer.draw(&window);
        player.draw(&window);
        window.display();
    }
}

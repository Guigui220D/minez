const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.graphics;
    usingnamespace sf.window;
    usingnamespace sf.system;
};
const std = @import("std");

const atlas = @import("atlas.zig");
const crt = @import("crt.zig");
const gui = @import("gui.zig");
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
    defer atlas.texture.destroy();

    // Window
    var window = try sf.RenderWindow.createDefault(.{ .x = crt.WIDTH, .y = crt.HEIGHT }, "Minemine");
    defer window.destroy();
    window.setFramerateLimit(60);

    var crt_screen = try sf.RenderTexture.create(.{ .x = crt.WIDTH, .y = crt.HEIGHT });
    defer crt_screen.destroy();
    crt_screen.setSmooth(true);
    var crt_sprite = try sf.Sprite.createFromTexture(crt_screen.getTexture());
    defer crt_sprite.destroy();
    //crt_sprite.setPosition(.{ .x = crt.WIDTH / 2, .y = 0 });

    var crt_shader = try sf.Shader.createFromMemory(null, null, @embedFile("crt_shader.fs"));
    defer crt_shader.destroy();
    crt_shader.setUniform("textureSampler", sf.Shader.CurrentTexture);
    crt_shader.setUniform("curvature", sf.Vector2f{ .x = 2.5, .y = 2.5 });
    crt_shader.setUniform("screenResolution", sf.Vector2f{ .x = crt.WIDTH / 4, .y = crt.HEIGHT / 4 });
    crt_shader.setUniform("scanLineOpacity", sf.Vector2f{ .x = 0.5, .y = 0.2 });
    crt_shader.setUniform("brightness", @as(f32, 1.8));

    // GUI
    try gui.init();
    defer gui.deinit();

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
        renderer.update(delta);

        crt_screen.clear(sf.Color.Black);
        renderer.draw(&crt_screen);
        player.draw(&crt_screen);
        gui.draw(&crt_screen);
        crt_screen.display();

        window.clear(sf.Color.Black);
        window.draw(crt_sprite, .{ .shader = crt_shader });
        window.display();
    }
}

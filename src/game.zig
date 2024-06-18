const sf = struct {
    const sfml = @import("sfml");
    pub usingnamespace sfml;
    pub usingnamespace sfml.graphics;
    pub usingnamespace sfml.system;
    pub usingnamespace sfml.window;
};
const std = @import("std");

const atlas = @import("atlas.zig");
const crt = @import("crt.zig");
const gui = @import("gui.zig");
const block_register = @import("block_register.zig");
const entity_resources = @import("entities/entity_resources.zig");
const EC = @import("entities/entity_classes.zig");

const wfc = @import("wfc/wfc_block.zig");

const Terrain = @import("Terrain.zig");
const TerrainRenderer = @import("TerrainRenderer.zig");
const Player = @import("Player.zig");
const EntityManager = @import("EntityManager.zig");
const Entity = @import("Entity.zig");

pub var player: Player = undefined;
pub var random: std.rand.Random = undefined;
pub var world: Terrain = undefined;

var gpa: std.heap.GeneralPurposeAllocator(.{}) = undefined;
var prng: std.rand.DefaultPrng = undefined;
var renderer: TerrainRenderer = undefined;
var entity_manager: EntityManager = undefined;

var window: sf.RenderWindow = undefined;
var crt_screen: sf.RenderTexture = undefined;
var crt_sprite: sf.Sprite = undefined;
var crt_shader: sf.Shader = undefined;
var crt_view: sf.View = undefined;
var crt_window_view: sf.View = undefined;

var background_enabled: bool = false;
var background_view: sf.View = undefined;
var background_sprite: sf.Sprite = undefined;
var background_texture: sf.Texture = undefined;

pub fn init() !void {
    // Allocator
    gpa = .{};
    errdefer _ = gpa.deinit();
    const allocator = gpa.allocator();
    // Random
    prng = std.rand.DefaultPrng.init(@bitCast(std.time.timestamp()));
    random = prng.random();
    // Atlas builder
    {
        var atlas_builder = try atlas.Builder.start(allocator);
        try block_register.loadAllBlockTextures(&atlas_builder);
        try atlas_builder.finish();
    }
    errdefer atlas.destroy();
    // Gui
    try gui.init();
    errdefer gui.deinit();
    // Terrain
    renderer = try TerrainRenderer.create();
    errdefer renderer.destroy();
    world = try Terrain.init(allocator, &renderer);
    errdefer world.deinit();

    world.wfc_gen = wfc.WfcChunk.init(random, &world);
    world.genSome();

    // Entities
    try entity_resources.loadAllResources();
    errdefer entity_resources.destroyAllRessources();
    entity_manager = EntityManager.init(allocator);
    errdefer entity_manager.deinit();
    try entity_manager.entities.append(try Entity.create(EC.House, .{ .x = 0, .y = 0 }));
    try entity_manager.entities.append(try Entity.create(EC.Angerman, .{ .x = 96, .y = 512 }));
    // Player
    player = try Player.create();
    errdefer player.destroy();
    // Crt
    try initCrt();
    errdefer deinitCrt();
}

fn initCrt() !void {
    // Window
    window = try sf.RenderWindow.createDefault(.{ .x = crt.WIDTH, .y = crt.HEIGHT }, "Minemine");
    errdefer window.destroy();
    window.setFramerateLimit(60);
    // Render target
    crt_screen = try sf.RenderTexture.create(.{ .x = crt.WIDTH, .y = crt.HEIGHT });
    errdefer crt_screen.destroy();
    crt_screen.setSmooth(true);
    // View
    crt_view = crt_screen.getView();
    crt_view.setCenter(.{ .x = crt.WIDTH / 2, .y = -crt.HEIGHT / 2 });
    crt_screen.setView(crt_view);
    // Target sprite
    crt_sprite = try sf.Sprite.createFromTexture(crt_screen.getTexture());
    errdefer crt_sprite.destroy();
    // Crt shader
    crt_shader = try sf.Shader.createFromFile(null, null, "res/shader/crt_shader.fs");
    errdefer crt_shader.destroy();
    crt_shader.setUniform("textureSampler", sf.Shader.CurrentTexture);
    crt_shader.setUniform("curvature", sf.Vector2f{ .x = 2.5, .y = 2.5 });
    crt_shader.setUniform("screenResolution", sf.Vector2f{ .x = crt.WIDTH / 4, .y = crt.HEIGHT / 4 });
    crt_shader.setUniform("scanLineOpacity", sf.Vector2f{ .x = 0.5, .y = 0.2 });
    crt_shader.setUniform("brightness", @as(f32, 1.8));
    crt_shader.setUniform("distortion", @as(f32, 0));
    // Background
    background_texture = try sf.Texture.createFromFile("res/other/arcade.jpg");
    errdefer background_texture.destroy();
    background_sprite = try sf.Sprite.createFromTexture(background_texture);
    errdefer background_sprite.destroy();
}

fn deinitCrt() void {
    window.destroy();
    crt_screen.destroy();
    crt_sprite.destroy();
    crt_shader.destroy();
    background_texture.destroy();
    background_sprite.destroy();
}

pub fn run() void {
    var clk = sf.Clock.create() catch @panic("Clock couldn't be created.");
    var global_clk = sf.Clock.create() catch unreachable;
    defer clk.destroy();
    defer global_clk.destroy();
    // Main loop
    while (window.isOpen()) {
        while (window.pollEvent()) |event| {
            switch (event) {
                .closed => window.close(),
                .keyPressed => |k| {
                    if (k.code == .Space)
                        gui.leaveTitle();
                },
                .resized => |s| handleResized(s.size),
                else => continue,
            }
        }

        // Update
        crt_shader.setUniform("distortion", @as(f32, global_clk.getElapsedTime().asSeconds() * 3));
        const delta = @min(clk.restart().asSeconds(), 0.04);
        gui.updateView(&crt_view);
        crt_screen.setView(crt_view);

        if (gui.isReady()) {
            player.update(delta);
            entity_manager.updateAll(delta);
        }

        // Draw crt
        crt_screen.clear(sf.Color.Black);
        renderer.draw(&crt_screen);
        entity_manager.drawAll(&crt_screen);
        player.draw(&crt_screen);
        gui.draw(&crt_screen);
        crt_screen.display();

        // Render crt with shader
        window.clear(sf.Color.Black);
        // Draw background
        if (background_enabled) {
            window.setView(background_view);
            window.draw(background_sprite, .{});
            window.setView(crt_window_view);
        }
        window.draw(crt_sprite, .{ .shader = crt_shader });
        window.display();
    }
}

pub fn deinit() void {
    world.deinit();
    atlas.destroy();
    gui.deinit();
    renderer.destroy();
    entity_resources.destroyAllRessources();
    entity_manager.deinit();
    player.destroy();

    deinitCrt();

    _ = gpa.deinit();
}

fn handleResized(size: sf.Vector2u) void {
    const size_f = sf.vector2f(@floatFromInt(size.x), @floatFromInt(size.y));
    const ratio: f32 = size_f.x / size_f.y;
    const ratio_goal: f32 = @as(f32, crt.WIDTH) / @as(f32, crt.HEIGHT);

    if (ratio > ratio_goal * 1.1) {
        // The window is too wide: add padding on the sides
        const view_x = @as(f32, @floatFromInt(size.y)) * ratio_goal;
        // Fix the viewport
        const viewport_width = view_x / size_f.x;
        const padding_required = 1 - viewport_width;
        // Set it
        crt_window_view = window.getView();
        crt_window_view.viewport = sf.FloatRect.init(padding_required / 2, 0, viewport_width, 1);
        window.setView(crt_window_view);

        // Padding needs background
        background_enabled = true;
        background_view = sf.View.fromRect(sf.FloatRect.init(0, 0, 1, 1));
        background_view.setSize(sf.vector2f(1920, 1920 / ratio));
        background_view.setCenter(background_view.size.scale(0.5));
    } else {
        // The window is too high: crop the window
        const view_y = @as(f32, @floatFromInt(size.x)) / ratio_goal;
        // Snap the window dimensions to the aspect ratio
        window.setSize(.{ .x = size.x, .y = @intFromFloat(view_y) });
        crt_window_view = window.getView();
        crt_window_view.viewport = sf.FloatRect.init(0, 0, 1, 1);
        window.setView(crt_window_view);

        // CRT fills the screen, no background needed
        background_enabled = false;
    }
}

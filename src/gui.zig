const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.graphics;
    usingnamespace sf.window;
    usingnamespace sf.system;
};

const crt = @import("crt.zig");

const BAR_WIDTH = 30;

var header_rect: sf.RectangleShape = undefined;
var footer_rect: sf.RectangleShape = undefined;

pub var font: sf.Font = undefined;
var top_text: sf.Text = undefined;
var bottom_text: sf.Text = undefined;

var title_texture: sf.Texture = undefined;
var title_sprite: sf.Sprite = undefined;

var score: i32 = 0;

var on_title: bool = true;
var ready: bool = false;
var scroll_clk: sf.Clock = undefined;

pub fn init() !void {
    header_rect = try sf.RectangleShape.create(.{ .x = crt.WIDTH, .y = BAR_WIDTH });
    errdefer header_rect.destroy();
    header_rect.setFillColor(sf.Color.Black);

    footer_rect = try sf.RectangleShape.create(.{ .x = crt.WIDTH, .y = BAR_WIDTH });
    errdefer footer_rect.destroy();
    footer_rect.setFillColor(sf.Color.Black);
    footer_rect.setPosition(.{ .x = 0, .y = crt.HEIGHT - BAR_WIDTH });

    font = try sf.Font.createFromFile("res/font/ARCADE_R.TTF");
    errdefer font.destroy();

    top_text = try sf.Text.createWithText("Score: 0", font, 24);
    errdefer top_text.destroy();

    bottom_text = try sf.Text.createWithText("Time to get mining :)\n Press down", font, 12);
    errdefer bottom_text.destroy();
    bottom_text.setPosition(.{ .x = 0, .y = crt.HEIGHT - BAR_WIDTH });

    title_texture = try sf.Texture.createFromFile("res/gui/title.png");
    errdefer title_texture.destroy();

    title_sprite = try sf.Sprite.createFromTexture(title_texture);
    errdefer title_sprite.destroy();
    title_sprite.setOrigin(.{ .x = 0, .y = 600 });

    scroll_clk = try sf.Clock.create();
    errdefer scroll_clk.destroy();
}

pub fn deinit() void {
    header_rect.destroy();
    footer_rect.destroy();

    top_text.destroy();
    bottom_text.destroy();
    font.destroy();
}

pub fn draw(target: anytype) void {
    if (ready) {
        target.draw(header_rect, null);
        target.draw(footer_rect, null);

        target.draw(top_text, null);
        target.draw(bottom_text, null);
    } else {
        target.draw(title_sprite, null);
    }
    
}

pub fn addScore(amount: i32) void {
    score += amount;
    top_text.setStringFmt("Score: {}", .{ score} ) catch unreachable;
}

pub fn getScore() i32 {
    return score;
}

pub fn updateView(view: *sf.View) void {
    if (!ready and !on_title) {
        if (scroll_clk.getElapsedTime().asSeconds() >= 1) {
            ready = true;
            view.setCenter(.{ .x = crt.WIDTH / 2, .y = crt.HEIGHT / 2 });
            return;
        }
        view.setCenter(.{ .x = crt.WIDTH / 2, .y = scroll_clk.getElapsedTime().asSeconds() * crt.HEIGHT - crt.HEIGHT / 2 });
    }
}

pub fn leaveTitle() void {
    on_title = false;
    _ = scroll_clk.restart();
}

pub fn isReady() bool {
    return ready;
}
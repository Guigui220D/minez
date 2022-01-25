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

var score: i32 = 0;

pub fn init() !void {
    header_rect = try sf.RectangleShape.create(.{ .x = crt.WIDTH, .y = BAR_WIDTH });
    errdefer header_rect.destroy();
    header_rect.setFillColor(sf.Color.Black);

    footer_rect = try sf.RectangleShape.create(.{ .x = crt.WIDTH, .y = BAR_WIDTH });
    errdefer footer_rect.destroy();
    footer_rect.setFillColor(sf.Color.Black);
    footer_rect.setPosition(.{ .x = 0, .y = crt.HEIGHT - BAR_WIDTH });

    font = try sf.Font.createFromFile("res/ARCADE_R.TTF");
    errdefer font.destroy();

    top_text = try sf.Text.createWithText("Score: 0", font, 24);
    errdefer top_text.destroy();

    bottom_text = try sf.Text.createWithText("Time to get mining :)\n Press down", font, 12);
    errdefer bottom_text.destroy();
    bottom_text.setPosition(.{ .x = 0, .y = crt.HEIGHT - BAR_WIDTH });
}

pub fn deinit() void {
    header_rect.destroy();
    footer_rect.destroy();

    top_text.destroy();
    bottom_text.destroy();
    font.destroy();
}

pub fn draw(target: anytype) void {
    target.draw(header_rect, null);
    target.draw(footer_rect, null);

    target.draw(top_text, null);
    target.draw(bottom_text, null);
}

pub fn addScore(amount: i32) void {
    score += amount;
    top_text.setStringFmt("Score: {}", .{ score} ) catch unreachable;

    if (score >= 1000 and score - amount < 1000) {
        bottom_text.setString("You reached the diamond caves");
    }
    if (score >= 6000 and score - amount < 6000) {
        bottom_text.setString("You reached\nthe deep dark");
    }
}

pub fn getScore() i32 {
    return score;
}
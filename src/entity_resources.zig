const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.graphics;
};

pub fn loadAll() !void {
    house_texture = try sf.Texture.createFromFile("res/house.png");
    errdefer house_texture.destroy();

    silverfish_texture = try sf.Texture.createFromFile("res/silverfish.png");
    errdefer silverfish_texture.destroy();
}

pub fn unloadAll() void {
    house_texture.destroy();
    silverfish_texture.destroy();
}

pub var house_texture: sf.Texture = undefined;
pub var silverfish_texture: sf.Texture = undefined;
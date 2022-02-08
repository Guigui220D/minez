const sf = struct {
    usingnamespace @import("sfml");
    usingnamespace sf.graphics;
};

pub fn loadAll() !void {
    house_texture = try sf.Texture.createFromFile("res/other/house.png");
    errdefer house_texture.destroy();

    angerman_texture = try sf.Texture.createFromFile("res/entity/angerman.png");
    errdefer angerman_texture.destroy();

    silverfish_texture = try sf.Texture.createFromFile("res/entity/silverfish.png");
    errdefer silverfish_texture.destroy();
}

pub fn unloadAll() void {
    house_texture.destroy();
    angerman_texture.destroy();
    silverfish_texture.destroy();
}

pub var house_texture: sf.Texture = undefined;
pub var angerman_texture: sf.Texture = undefined;
pub var silverfish_texture: sf.Texture = undefined;
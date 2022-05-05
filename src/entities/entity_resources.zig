const entity_classes = @import("entity_classes.zig");

const meta = @import("std").meta;

pub fn loadAllResources() !void {
    inline for (comptime meta.declarations(entity_classes)) |Class| {
        if (Class.is_pub)
            try @field(entity_classes, Class.name).loadResources();
    }
}

pub fn destroyAllRessources() void {
    inline for (comptime meta.declarations(entity_classes)) |Class| {
        if (Class.is_pub)
            @field(entity_classes, Class.name).destroyResources();
    }
}
const std = @import("std");
const sfml = @import("sfml");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "minez",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = mode,
    });

    exe.root_module.addImport("sfml", b.dependency("sfml", .{}).module("sfml"));
    exe.root_module.addImport("wfc", b.dependency("wfc", .{}).module("wfc"));
    sfml.link(exe);

    const run = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the game");
    run_step.dependOn(&run.step);
}

const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("minez", "src/main.zig");
    exe.linkLibC();
    exe.addPackagePath("sfml", "zig-sfml-wrapper/src/sfml/sfml.zig");
    exe.addLibPath("csfml/lib/msvc/");
    exe.linkSystemLibrary("csfml-graphics");
    exe.linkSystemLibrary("csfml-system");
    exe.linkSystemLibrary("csfml-window");
    exe.linkSystemLibrary("csfml-audio");
    exe.addIncludeDir("csfml/include/");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_step = b.step("run", "Run the game");
    run_step.dependOn(&exe.run().step);
}

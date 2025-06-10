// build.zig
const std = @import("std");

pub fn build(b: *std.Build) {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "aoc-zig",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Add the aoc module, pointing to the new flattened location
    const aoc_module = b.addModule("aoc", .{
        .source_file = .{ .path = "src/aoc.zig" },
    });
    exe.addModule("aoc", aoc_module);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    // --- Add Unit Tests ---
    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    // Link the aoc module to the tests as well
    main_tests.addModule("aoc", aoc_module);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&main_tests.step);
}

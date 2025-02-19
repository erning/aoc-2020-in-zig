const std = @import("std");
const lib = @import("lib.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try lib.readFile(allocator, "inputs/01-input.txt");
    defer allocator.free(input);

    const puzzle = @import("day01.zig");
    const p1 = try puzzle.partOne(allocator, input);
    const p2 = try puzzle.partTwo(allocator, input);

    std.debug.print("Day {d}: {s}\n", .{ 1, "Historian Hysteria" });
    std.debug.print("Part One: {}\n", .{p1});
    std.debug.print("Part Two: {}\n", .{p2});
    std.debug.print("\n", .{});
}

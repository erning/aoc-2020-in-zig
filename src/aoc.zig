//! src/aoc.zig
const std = @import("std");

/// A tagged union to represent the result of a puzzle part.
/// It can hold various types that a puzzle might return (e.g., numbers, strings).
/// It also includes a custom `format` function to allow direct printing with `std.debug.print`.
pub const Solution = union(enum) {
    i32: i32,
    string: []const u8,

    pub fn format(
        self: Solution,
        comptime fmt_str: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        // These are unused in this simple formatter but are required by the function signature.
        _ = fmt_str;
        _ = options;

        switch (self) {
            .i32 => |value| try writer.print("{d}", .{value}),
            .string => |value| try writer.print("{s}", .{value}),
        }
    }
};

// A helper function to read the puzzle input file into a string.
// pub fn readAsString(allocator: std.mem.Allocator, day: u8, filename: []const u8) ![]u8 {
pub fn readAsString(allocator: std.mem.Allocator, filename: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const stats = try file.stat();
    const size = stats.size;

    const buffer = try allocator.alloc(u8, size);
    _ = try file.reader().readAll(buffer);

    return buffer;
}

/// Splits a string into lines and returns an array of slices.
/// Caller owns the returned ArrayList and must deinit it.
/// Each line excludes the line ending (\n, \r\n, or \r).
pub fn splitLines(allocator: std.mem.Allocator, text: []const u8) ![][]const u8 {
    var lines = std.ArrayList([]const u8).init(allocator);
    errdefer lines.deinit();
    const trimmed = std.mem.trim(u8, text, " \r\n\t");
    var line_iterator = std.mem.splitScalar(u8, trimmed, '\n');
    while (line_iterator.next()) |line| {
        // Remove carriage return if present
        const trimmed_line = if (std.mem.endsWith(u8, line, "\r"))
            line[0 .. line.len - 1]
        else
            line;
        try lines.append(trimmed_line);
    }

    return lines.toOwnedSlice();
}

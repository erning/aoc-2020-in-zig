const std = @import("std");

// A helper function to read the puzzle input file into a string.
pub fn readAsString(allocator: std.mem.Allocator, day: u8, filename: []const u8) ![]u8 {
    const path = try std.fmt.allocPrint(allocator, "inputs/{d:0>2}-{s}.txt", .{ day, filename });
    std.debug.print("{s}\n", .{path});
    defer allocator.free(path);

    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const stats = try file.stat();
    const size = stats.size;

    const buffer = try allocator.alloc(u8, size);
    _ = try file.reader().readAll(buffer);

    return buffer;
}

pub fn readInput(allocator: std.mem.Allocator, day: u8) ![]u8 {
    return readAsString(allocator, day, "input");
}

pub fn readExample(allocator: std.mem.Allocator, day: u8) ![]u8 {
    return readAsString(allocator, day, "example");
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

/// Generic map function that transforms an array of type T to an array of type U
/// using the provided transformation function.
pub fn map(
    comptime T: type,
    comptime U: type,
    allocator: std.mem.Allocator,
    items: []const T,
    transform: fn (T) U,
) ![]U {
    var result = try allocator.alloc(U, items.len);
    errdefer allocator.free(result);
    for (items, 0..) |item, i| {
        result[i] = transform(item);
    }
    return result;
}

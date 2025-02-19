const std = @import("std");

/// Reads the entire contents of a file into a string.
/// Caller owns the returned memory and must free it.
/// Returns an error if the file cannot be read.
pub fn readFile(allocator: std.mem.Allocator, filename: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, size);
    const bytes_read = try file.read(buffer);
    if (bytes_read != size) {
        return error.UnexpectedEndOfFile;
    }

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

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

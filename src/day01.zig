const std = @import("std");
const lib = @import("./lib.zig");

fn parse_input(allocator: std.mem.Allocator, input: []const u8) ![]i32 {
    const lines = try lib.splitLines(allocator, input);
    defer allocator.free(lines);

    const numbers = try allocator.alloc(i32, lines.len);
    errdefer allocator.free(numbers); // free if parse number error
    for (lines, numbers) |s, *v| {
        v.* = try std.fmt.parseInt(i32, s, 10);
    }
    return numbers;
}

pub fn partOne(allocator: std.mem.Allocator, input: []const u8) !i32 {
    const numbers = try parse_input(allocator, input);
    defer allocator.free(numbers);

    for (numbers[0 .. numbers.len - 1], 0..) |a, i| {
        for (numbers[i..]) |b| {
            if (a + b == 2020) return a * b;
        }
    }

    @panic("No solution found.");
}

pub fn partTwo(allocator: std.mem.Allocator, input: []const u8) !i32 {
    const numbers = try parse_input(allocator, input);
    defer allocator.free(numbers);

    for (numbers[0 .. numbers.len - 2], 0..) |a, i| {
        for (numbers[i .. numbers.len - 1], i..) |b, j| {
            for (numbers[j..]) |c| {
                if (a + b + c == 2020) return a * b * c;
            }
        }
    }

    @panic("No solution found.");
}

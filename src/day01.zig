const std = @import("std");
const aoc = @import("./aoc.zig");
const utils = @import("./utils.zig");

fn parseInput(allocator: std.mem.Allocator, input: []const u8) ![]i32 {
    const lines = try utils.splitLines(allocator, input);
    defer allocator.free(lines);

    const numbers = try allocator.alloc(i32, lines.len);
    errdefer allocator.free(numbers); // free if parse number error
    for (lines, numbers) |s, *v| {
        v.* = try std.fmt.parseInt(i32, s, 10);
    }
    return numbers;
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !i32 {
    const numbers = try parseInput(allocator, input);
    defer allocator.free(numbers);

    for (numbers[0 .. numbers.len - 1], 0..) |a, i| {
        for (numbers[i..]) |b| {
            if (a + b == 2020) return a * b;
        }
    }
    @panic("No solution found.");
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !i32 {
    const numbers = try parseInput(allocator, input);
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

//

pub fn partOne(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .i32 = try part1(allocator, input) };
}

pub fn partTwo(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .i32 = try part2(allocator, input) };
}

// Unit test
test "day 01 example" {
    const allocator = std.testing.allocator;
    const input = try utils.readExample(allocator, 1);
    defer allocator.free(input);

    const p1 = try part1(allocator, input);
    try std.testing.expectEqual(514579, p1);

    const p2 = try part2(allocator, input);
    try std.testing.expectEqual(241861950, p2);
}

const std = @import("std");
const aoc = @import("./aoc.zig");
const utils = @import("./utils.zig");

const Grid = std.ArrayList([]const u8);

fn parseInput(allocator: std.mem.Allocator, input: []const u8) ![][]const u8 {
    return utils.splitLines(allocator, input);
}

fn slope(grid: [][]const u8, dx: usize, dy: usize) usize {
    const h = grid.len;
    const w = grid[0].len;
    var x: usize = 0;
    var y: usize = 0;
    var trees: usize = 0;
    while (y < h) {
        if (grid[y][x % w] == '#') {
            trees += 1;
        }
        x += dx;
        y += dy;
    }
    return trees;
}

fn part1(allocator: std.mem.Allocator, input: []const u8) !usize {
    const grid = try parseInput(allocator, input);
    defer allocator.free(grid);
    return slope(grid, 3, 1);
}

fn part2(allocator: std.mem.Allocator, input: []const u8) !usize {
    const grid = try parseInput(allocator, input);
    defer allocator.free(grid);
    const slopes = [_][2]usize{ .{ 1, 1 }, .{ 3, 1 }, .{ 5, 1 }, .{ 7, 1 }, .{ 1, 2 } };
    var product: usize = 1;
    for (slopes) |v| {
        const trees = slope(grid, v[0], v[1]);
        product *= trees;
    }
    return product;
}

//

pub fn partOne(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .usize = try part1(allocator, input) };
}

pub fn partTwo(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .usize = try part2(allocator, input) };
}

// Unit test
test "day 03 example" {
    const allocator = std.testing.allocator;
    const input = try utils.readExample(allocator, 3);
    defer allocator.free(input);

    const p1 = try part1(allocator, input);
    try std.testing.expectEqual(7, p1);

    const p2 = try part2(allocator, input);
    try std.testing.expectEqual(336, p2);
}

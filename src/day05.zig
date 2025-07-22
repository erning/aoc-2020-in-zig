const std = @import("std");
const aoc = @import("./aoc.zig");
const utils = @import("./utils.zig");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

fn decode(s: []const u8) u16 {
    var a: u16 = 0;
    var b: u16 = switch (s.len) {
        7 => 127,
        3 => 7,
        else => unreachable,
    };
    for (s) |ch| {
        const delta = (b - a + 1) / 2;
        switch (ch) {
            'F', 'L' => b -= delta,
            'B', 'R' => a += delta,
            else => unreachable,
        }
    }
    std.debug.assert(a == b);
    return a;
}

fn getSeatID(line: []const u8) u16 {
    const row = decode(line[0..7]);
    const col = decode(line[7..10]);
    return row * 8 + col;
}

fn part1(allocator: Allocator, input: []const u8) !u16 {
    _ = allocator;
    var max_seat_id: u16 = 0;
    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) continue;
        const seat_id = getSeatID(trimmed);
        if (seat_id > max_seat_id) {
            max_seat_id = seat_id;
        }
    }
    return max_seat_id;
}

fn part2(allocator: Allocator, input: []const u8) !u16 {
    var seats = ArrayList(u16).init(allocator);
    defer seats.deinit();

    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) continue;
        try seats.append(getSeatID(trimmed));
    }

    std.mem.sort(u16, seats.items, {}, std.sort.asc(u16));

    for (seats.items[0 .. seats.items.len - 1], 0..) |seat, i| {
        if (seats.items[i + 1] != seat + 1) {
            return seat + 1;
        }
    }

    return error.NoSolution;
}

pub fn partOne(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .u16 = try part1(allocator, input) };
}

pub fn partTwo(allocator: std.mem.Allocator, input: []const u8) anyerror!aoc.Solution {
    return aoc.Solution{ .u16 = try part2(allocator, input) };
}

test "day 05 example" {
    const allocator = std.testing.allocator;
    const input = try utils.readExample(allocator, 5);
    defer allocator.free(input);

    const p1 = try part1(allocator, input);
    try std.testing.expectEqual(@as(u16, 820), p1);
}
